-- Copyright 2026 renzler
-- Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
-- 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
-- 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.name = 'AutoSilc'
_addon.author = 'renzler'
_addon.version = '0.0.1'
_addon.commands = {'autosilc'}

-- AutoSilc is MagianWS with one thing swapped out: it does not choose its own
-- target. It watches a party member - the party leader by default - and attacks
-- whatever they are attacking. Everything else (weaponskill at TP, skillchain
-- closing, buffs, food, ammo, Provoke, the overlay) behaves exactly as it does
-- in MagianWS. See the "Assist" block below for how the target is resolved.

config = require('config')
texts = require('texts')
local res = require('resources')
local packets = require('packets')
local sc_data = require('sc_data')

local COLOR_PAT = '[' .. string.char(0x1e, 0x1f) .. '].'
local COLOR_RESET = string.char(0x7f)
local function strip_colors(s)
    return (s:gsub(COLOR_PAT, ''):gsub(COLOR_RESET, ''))
end

-- Settings keys become XML element names, so they must contain only characters
-- legal in an XML name. Spaces become underscores; apostrophes and anything else
-- illegal (e.g. "Corsair's Roll") are dropped. The real name lives in the `name` field.
local function settings_key(name)
    return (name:gsub(' ', '_'):gsub('[^%w_%-%.]', ''))
end

local function has_flag(n, f)
    return math.floor(n / f) % 2 == 1
end

local function is_player_or_trust(spawn_type)
    return has_flag(spawn_type, 0x01) or has_flag(spawn_type, 0x04)
end

local defaults = {}
defaults.ws_name = 'Piercing Arrow'
defaults.ws2_name = ''
defaults.tp_threshold = 1000
defaults.food_name = ''
defaults.ammo_name = ''
defaults.buff_sets = {}
defaults.active_buff_set = ''
defaults.provoke = false
defaults.follow = false
defaults.target_names = {}
-- Who to copy. Empty means "whoever the game says is the party leader"; set a
-- character name to pin the assist to that player instead.
defaults.assist_name = ''
defaults.pull_mode = false
defaults.pull_range = 25
defaults.pull_method = 'ra'
defaults.home_set = false
defaults.home_x = 0
defaults.home_y = 0
defaults.home_z = 0
defaults.trial_remaining = -1
defaults.mode = 'trials'
defaults.target_spells = {}
defaults.use_item = ''
defaults.scan_range = 40
defaults.display = {}
defaults.display.pos = {}
defaults.display.pos.x = 100
defaults.display.pos.y = 50
defaults.display.bg = {}
defaults.display.bg.red = 0
defaults.display.bg.green = 0
defaults.display.bg.blue = 0
defaults.display.bg.alpha = 160
defaults.display.bg.visible = true
defaults.display.text = {}
defaults.display.text.font = 'Consolas'
defaults.display.text.size = 11
defaults.display.text.red = 255
defaults.display.text.green = 255
defaults.display.text.blue = 255
defaults.display.text.alpha = 255
defaults.display.flags = {}
defaults.display.flags.draggable = true

local settings = config.load(defaults)

-- A settings.xml carried over from MagianWS can have pull_mode true. Nothing in
-- AutoSilc should ever take the pull path - the leader pulls - so pin it off
-- once, here, rather than guarding every branch that reads it.
settings.pull_mode = false

local display = texts.new('', settings.display, settings)
local display_visible = true

local session_start = os.time()
local session_exp   = 0
local session_cp    = 0
local session_ep    = 0

local _init_player  = windower.ffxi.get_player()
local player_name_lower = _init_player and _init_player.name and _init_player.name:lower() or ''

local last_provoke_time = 0
local PROVOKE_RECAST = 30

local function parse_trial_remaining(lower_text)
    return tonumber(lower_text:match('trial %d+: (%d+) objectives? remain'))
        or tonumber(lower_text:match('(%d+) objectives? remain'))
        or tonumber(lower_text:match('(%d+) more'))
        or tonumber(lower_text:match('(%d+) remaining'))
        or tonumber(lower_text:match('remaining[^%d]*(%d+)'))
end

local ATTACK_RANGE_SQ = 400  -- 20 yalms; mob.distance is squared
-- PULL_RANGE_SQ derived from settings.pull_range at use time (mob.distance is squared)
local HOME_RANGE      = 10   -- yalms; within this = considered at home

local function home_distance()
    if not settings.home_set then return nil end
    local me = windower.ffxi.get_mob_by_target('me')
    if not me then return nil end
    local dx = settings.home_x - me.x
    local dy = settings.home_y - me.y
    local dz = settings.home_z - me.z
    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

local function format_rate(total)
    local elapsed = os.time() - session_start
    if elapsed < 1 then return '---' end
    local n = math.floor(total / (elapsed / 3600))
    return tostring(n):reverse():gsub('(%d%d%d)', '%1,'):reverse():gsub('^,', '')
end

---------------------------------------------------------------------------
-- Assist
--
-- This is the whole difference between AutoSilc and MagianWS. MagianWS scans
-- the mob array for a name you configured; AutoSilc asks "what is the leader
-- hitting?" and copies that.
---------------------------------------------------------------------------

local ASSIST_TTL     = 30.0  -- seconds an action-derived target stays trusted
local assist_id      = 0     -- mob id the assist player was last seen acting on
local assist_seen_at = 0     -- os.clock() when that was observed

-- The party member whose target we copy.
--
-- party1_leader is a mob ID - not a name and not an index. It is only meaningful
-- against v.mob.id of a party entry, which is why this walks the party table
-- rather than calling get_mob_by_id() on it first: the party table is
-- authoritative about who is in the party, the mob array only knows who is near.
local function get_assist_player()
    local party = windower.ffxi.get_party()
    if not party then return nil end

    if settings.assist_name ~= '' then
        local want = settings.assist_name:lower()
        for _, v in pairs(party) do
            if type(v) == 'table' and v.mob and v.mob.name
                    and v.mob.name:lower() == want then
                return v.mob
            end
        end
        return nil
    end

    local lid = party.party1_leader
    if not lid or lid == 0 then return nil end
    local me = windower.ffxi.get_player()
    -- If we ARE the leader there is nobody to follow, and assisting our own
    -- target would just re-target what we already have on every scan.
    if me and lid == me.id then return nil end
    for _, v in pairs(party) do
        if type(v) == 'table' and v.mob and v.mob.id == lid then return v.mob end
    end
    -- In the party but not in our mob array (out of range, or zoning).
    return windower.ffxi.get_mob_by_id(lid)
end

local function assist_player_name()
    local m = get_assist_player()
    if m and m.name and m.name ~= '' then return m.name end
    return nil
end

-- "Do we have somebody to assist?" replaces MagianWS's "is a target name set?".
-- Every gate that used to ask whether a target list existed now asks this.
local function has_targets()
    return get_assist_player() ~= nil
end

-- The target_names list is no longer how targets are CHOSEN - the leader does
-- that. It survives as an optional whitelist: leave it empty to assist on
-- anything, or add names to refuse to assist on anything else.
local function name_whitelisted(mob_name)
    if next(settings.target_names) == nil then return true end
    local lower = mob_name:lower()
    for _, entry in pairs(settings.target_names) do
        if entry.name:lower() == lower then return true end
    end
    return false
end

-- MagianWS refuses any mob that carries a claim, because a claimed mob is
-- someone else's. That test is exactly backwards here: the mob we want is
-- claimed almost by definition, because the leader claimed it. So the question
-- becomes whether the claimer is one of ours.
local function claim_is_ours(claim_id)
    if not claim_id or claim_id == 0 then return true end
    local party = windower.ffxi.get_party()
    if not party then return false end
    for _, v in pairs(party) do
        if type(v) == 'table' and v.mob and v.mob.id == claim_id then return true end
    end
    return false
end

-- NOTE: this takes a MOB TABLE, where MagianWS's version of the same name took
-- a mob NAME. Nothing here can be decided from a name any more.
local function is_target_mob(mob)
    if not mob or not mob.id or mob.id == 0 then return false end
    if not mob.name or mob.name == '' then return false end
    if is_player_or_trust(mob.spawn_type or 0) then return false end
    if (mob.status or 0) == 2 then return false end
    if (mob.hpp or 0) <= 0 then return false end
    if not claim_is_ours(mob.claim_id) then return false end
    return name_whitelisted(mob.name)
end

-- The mob the assist player is on, or nil.
local function resolve_assist_target()
    -- Preferred source: what we have actually SEEN them do. Action packets are
    -- unambiguous - the leader swung at, cast on or shot a specific mob id.
    if assist_id ~= 0 and os.clock() - assist_seen_at <= ASSIST_TTL then
        local mob = windower.ffxi.get_mob_by_id(assist_id)
        if is_target_mob(mob) then return mob end
        assist_id = 0
    end

    -- Fallback: the leader's own target_index out of the mob array. Cheaper but
    -- weaker - another player's target_index is only populated while the server
    -- is sending it, and it lingers on a mob they have already disengaged from,
    -- which is why it comes second and why is_target_mob() re-validates it.
    local leader = get_assist_player()
    if leader and leader.target_index and leader.target_index ~= 0 then
        local mob = windower.ffxi.get_mob_by_index(leader.target_index)
        if is_target_mob(mob) then return mob end
    end
    return nil
end

-- Forward declaration: dbg() is defined further down, with the debug flag it
-- reads, but the assist hold below needs to log through it.
local dbg

-- Reacting to the leader the instant an action packet lands is inhumanly fast:
-- Silc snaps onto a new mob on the same frame the leader's first swing resolves.
-- A new target is therefore held for a random 2-12s before it is acted on.
--
-- This gates the one thing both act-on-a-new-target paths share - the answer to
-- "what mob?" - so the first engage and the mid-fight switch are both covered by
-- it without either of them knowing it exists.
--
-- While the hold runs we stay on whatever we had already committed to, rather
-- than standing still: dropping the old mob for 12s would be more conspicuous
-- than the snap it is meant to hide, not less.
local ASSIST_DELAY_MIN = 2.0
local ASSIST_DELAY_MAX = 12.0

-- Lua 5.1 seeds math.random identically on every load, which would make the
-- "random" hold the same sequence of numbers each session.
math.randomseed(os.time())
math.random(); math.random()

local assist_pending_id   = 0  -- mob id waiting out its hold
local assist_delay_until  = 0  -- os.clock() when that mob may be acted on
local assist_committed_id = 0  -- mob id we have already committed to

-- True while a new target is waiting out its hold. The caller needs this to
-- tell "the leader is on nothing" from "the leader is on something we have not
-- reacted to yet" - the first means go home, the second means stand still.
local function assist_holding()
    return assist_pending_id ~= 0 and os.clock() < assist_delay_until
end

local function assist_hold_remaining()
    return math.max(0, assist_delay_until - os.clock())
end

local function assist_target()
    local mob = resolve_assist_target()
    if not mob then
        assist_pending_id = 0
        return nil
    end

    -- Already committed to this mob: no hold, or every scan would re-hold it.
    if mob.id == assist_committed_id then
        assist_pending_id = 0
        return mob
    end

    if mob.id ~= assist_pending_id then
        assist_pending_id  = mob.id
        assist_delay_until = os.clock() + ASSIST_DELAY_MIN
            + math.random() * (ASSIST_DELAY_MAX - ASSIST_DELAY_MIN)
        dbg('assist hold: "' .. mob.name .. '" for '
            .. string.format('%.1f', assist_hold_remaining()) .. 's')
    end

    if os.clock() < assist_delay_until then
        local held = assist_committed_id ~= 0
            and windower.ffxi.get_mob_by_id(assist_committed_id) or nil
        if is_target_mob(held) then return held end
        return nil
    end

    assist_committed_id = mob.id
    assist_pending_id   = 0
    return mob
end

local function target_names_display()
    local names = {}
    for _, entry in pairs(settings.target_names) do
        names[#names+1] = entry.name
    end
    table.sort(names)
    return table.concat(names, ', ')
end

-- What the overlay and //autosilc status show: who we are assisting, and what
-- they are currently on.
local function assist_display()
    local who = assist_player_name()
    if not who then
        return settings.assist_name ~= ''
            and (settings.assist_name .. ' (not in party)')
            or 'no party leader'
    end
    local mob = resolve_assist_target()
    if mob then
        if assist_holding() and mob.id == assist_pending_id then
            return who .. ' > ' .. mob.name .. ' (holding '
                .. string.format('%.0f', assist_hold_remaining()) .. 's)'
        end
        return who .. ' > ' .. mob.name
    end
    return who .. ' (idle)'
end

local function update_display()
    if not display_visible then
        display:hide()
        return
    end
    local mode_label = settings.mode == 'exp' and '\\cs(160,220,160)Exp\\cr' or '\\cs(255,180,80)Trials\\cr'
    local rem_line = ''
    if settings.mode == 'trials' then
        local rem_str
        if settings.trial_remaining < 0 then
            rem_str = '\\cs(160,160,160)?\\cr'
        else
            rem_str = ('\\cs(100,255,100)%d\\cr'):format(settings.trial_remaining)
        end
        rem_line = '\n  Remaining: ' .. rem_str
    end
    local active_str = active and '\\cs(100,255,100)▶\\cr ' or '\\cs(160,160,160)■\\cr '
    local target_line = '\n  Assist: ' .. active_str .. '\\cs(255,180,80)' .. assist_display() .. '\\cr'
    if next(settings.target_names) ~= nil then
        target_line = target_line .. '\n  Only:   \\cs(200,220,255)' .. target_names_display() .. '\\cr'
    end
    local home_line = ''
    if settings.home_set then
        local dist = home_distance()
        if dist then
            local color = dist <= HOME_RANGE and '100,255,100' or '255,140,80'
            home_line = ('\n  Home: \\cs(%s)%.1fy\\cr'):format(color, dist)
        end
    end
    local rate_lines = ''
    if session_exp > 0 then
        rate_lines = rate_lines .. ('\n  EXP/hr:  \\cs(200,220,255)%s\\cr'):format(format_rate(session_exp))
    end
    if session_cp > 0 then
        rate_lines = rate_lines .. ('\n  CP/hr:   \\cs(200,220,255)%s\\cr'):format(format_rate(session_cp))
    end
    if session_ep > 0 then
        rate_lines = rate_lines .. ('\n  EP/hr:   \\cs(200,220,255)%s\\cr'):format(format_rate(session_ep))
    end
    local ws_display = settings.ws2_name ~= ''
        and (settings.ws_name .. ' \\cs(160,160,160)→\\cr \\cs(200,220,255)' .. settings.ws2_name .. '\\cr')
        or settings.ws_name
    display:text(('\\cs(255,200,80)[ AutoSilc | %s]\\cr\n  WS: \\cs(200,220,255)%s\\cr%s%s%s%s'):format(mode_label, ws_display, rem_line, target_line, home_line, rate_lines))
    display:show()
end

local function is_food_active()
    local player = windower.ffxi.get_player()
    for _, buff_id in ipairs(player.buffs) do
        if buff_id == 251 then
            return true
        end
    end
    return false
end

local function find_in_inventory(name)
    local items = windower.ffxi.get_items(0)
    for i = 1, items.max do
        local item = items[i]
        if item and item.id ~= 0 then
            local item_data = res.items[item.id]
            if item_data and item_data.en:lower() == name:lower() then
                return true
            end
        end
    end
    return false
end

local function find_buff_info(name)
    local lower = name:lower()
    for _, spell in pairs(res.spells) do
        if spell.en and spell.en:lower() == lower and spell.status and spell.status ~= 0 then
            return {name = spell.en, type = 'spell', buff_id = spell.status}
        end
    end
    if res.job_abilities then
        for _, ja in pairs(res.job_abilities) do
            if ja.en and ja.en:lower() == lower then
                local bid = (ja.status and ja.status ~= 0) and ja.status or 0
                return {name = ja.en, type = 'ability', buff_id = bid, recast_id = ja.recast_id}
            end
        end
    end
    return nil
end

local function find_spell_name(name)
    local lower = name:lower()
    for _, spell in pairs(res.spells) do
        if spell.en and spell.en:lower() == lower then
            return spell.en
        end
    end
    return nil
end

local function is_buff_active(buff_id)
    local target_id = tonumber(buff_id)
    local player = windower.ffxi.get_player()
    for _, id in ipairs(player.buffs) do
        if id == target_id then return true end
    end
    return false
end

local function cast_buff(name, buff_type, delay)
    local cmd
    if buff_type == 'spell' then
        cmd = 'input /ma "' .. name .. '" <me>'
    else
        cmd = 'input /ja "' .. name .. '" <me>'
    end
    if delay and delay > 0 then
        windower.send_command('wait ' .. delay .. '; ' .. cmd)
    else
        windower.send_command(cmd)
    end
end

local last_buff_attempt = {}
local BUFF_ATTEMPT_COOLDOWN = 20.0

local last_target_spell_cast = {}
local TARGET_SPELL_INTERVAL  = 60  -- default seconds between target spell recasts
local target_spell_delay_until = 0  -- os.clock() after which target spells may fire

local function get_active_buffs()
    if settings.active_buff_set == '' then return {} end
    return settings.buff_sets[settings.active_buff_set] or {}
end

local function maintain_buffs()
    local player = windower.ffxi.get_player()
    if player.status ~= 1 then return end
    local delay = 0
    local now = os.clock()
    local ab_recasts = nil
    for _, entry in pairs(get_active_buffs()) do
        local needs_cast
        if (entry.buff_id or 0) == 0 then
            -- Ability with no status effect (e.g. Meditate): cast when off recast
            if not ab_recasts then ab_recasts = windower.ffxi.get_ability_recasts() end
            local recast = entry.recast_id and (ab_recasts[entry.recast_id] or 0) or 0
            needs_cast = (recast == 0)
        else
            needs_cast = not is_buff_active(entry.buff_id)
        end
        if needs_cast then
            local last = last_buff_attempt[entry.name] or 0
            if now >= last + BUFF_ATTEMPT_COOLDOWN then
                cast_buff(entry.name, entry.type, delay)
                last_buff_attempt[entry.name] = now + delay
                delay = delay + 6
            end
        end
    end
end

-- ---------------------------------------------------------------------------
-- Songs
--
-- A fixed rotation rather than a buff set, because the buff maintainer above
-- cannot express either half of it. It identifies a buff by a single status id,
-- and both marches are status 214 (every Valor Minuet is 198) - once Advancing
-- March is up, `is_buff_active(214)` says Victory March is up too, and it is
-- never sung. It also has no way to pair a job ability with a cast, which the
-- Marcato'd minuet needs.
--
-- What is countable is how many copies of a status the player carries, so each
-- status is treated as a group: two songs on 214 means expect to see 214 twice.
-- Fewer means one of that group dropped, and songs expire in the order they
-- were sung, so the oldest is the one gone.
--
-- Unlike buffs this does not wait for //autosilc start - joining a party with
-- the addon loaded is the trigger. `//autosilc songs off` is the kill switch.
-- ---------------------------------------------------------------------------

local SONGS = {
    {name = 'Advancing March', status = 214},
    {name = 'Victory March',   status = 214},
    {name = 'Valor Minuet V',  status = 198, marcato = true},
}

-- Silc's songs run ~14 minutes with his instrument and duration gear, so that
-- is the refresh clock. A song that drops early is caught by the group-short
-- check and the 'lose buff' handler regardless, so this does not need the
-- safety margin a shorter guess would.
local SONG_DURATION   = 840
local SONG_CAST_LOCK  = 12.0 -- seconds one song cast is assumed to occupy
local MARCATO_EXTRA   = 2    -- seconds between the Marcato and the song

local songs_enabled   = true -- runtime toggle, like `active`; not persisted
local song_cast_at    = {}   -- song name -> os.clock() when we last issued it
local song_busy_until = 0    -- os.clock() before which no further song is issued
local was_in_party    = false

local MARCATO_RECAST_ID = (function()
    if not res.job_abilities then return nil end
    for _, ja in pairs(res.job_abilities) do
        if ja.en == 'Marcato' then return ja.recast_id end
    end
    return nil
end)()

local function marcato_ready()
    if not MARCATO_RECAST_ID then return false end
    local recasts = windower.ffxi.get_ability_recasts()
    return recasts ~= nil and (recasts[MARCATO_RECAST_ID] or 0) == 0
end

local function in_party()
    local party = windower.ffxi.get_party()
    if not party then return false end
    local n = 0
    for key, member in pairs(party) do
        if type(key) == 'string' and key:match('^p%d$') and type(member) == 'table' then
            n = n + 1
        end
    end
    return n > 1
end

local function sing(entry)
    local lock = SONG_CAST_LOCK
    if entry.marcato and marcato_ready() then
        windower.send_command('input /ja "Marcato" <me>')
        windower.send_command('wait ' .. MARCATO_EXTRA .. '; input /ma "' .. entry.name .. '" <me>')
        lock = lock + MARCATO_EXTRA
    else
        windower.send_command('input /ma "' .. entry.name .. '" <me>')
    end
    song_cast_at[entry.name] = os.clock()
    song_busy_until = os.clock() + lock
end

local function maintain_songs()
    if not songs_enabled then return end
    if not in_party() then return end

    local player = windower.ffxi.get_player()
    -- Idle counts as well as engaged: songs belong up before the pull, not
    -- after it. Anything else (dead, zoning, resting, mounted) is skipped.
    if not player or (player.status ~= 0 and player.status ~= 1) then return end

    -- A song is an 8s cast and the maintenance tick is 10s, so without this the
    -- next pass would start a second song on top of the first. Only one song is
    -- issued per pass; an interrupted cast recovers on the pass after the lock,
    -- because its group is still short - that path does not consult the clock.
    local now = os.clock()
    if now < song_busy_until then return end

    local up = {}
    for _, id in ipairs(player.buffs) do
        up[id] = (up[id] or 0) + 1
    end

    local short = {}
    for _, entry in ipairs(SONGS) do
        short[entry.status] = (short[entry.status] or 0) + 1
    end
    for status, want in pairs(short) do
        short[status] = want - (up[status] or 0)
    end

    -- Whichever candidate has gone longest without a cast. Never sung at all
    -- sorts first, so a fresh rotation goes out in the order listed above.
    local pick, pick_age
    for _, entry in ipairs(SONGS) do
        local cast_at  = song_cast_at[entry.name]
        local dropped  = (short[entry.status] or 0) > 0
        local expiring = (not cast_at) or (now >= cast_at + SONG_DURATION)
        -- Re-singing a Marcato song without Marcato swaps a strong song for a
        -- weak one, so on the clock alone it waits for the ability. If the song
        -- has actually dropped, a weak one still beats none.
        if entry.marcato and not dropped and not marcato_ready() then
            expiring = false
        end
        if dropped or expiring then
            local age = cast_at and (now - cast_at) or math.huge
            if not pick or age > pick_age then
                pick, pick_age = entry, age
            end
        end
    end

    if pick then sing(pick) end
end

-- Joining a party is the trigger. The rotation is not reset on join: anything
-- already up stays up, and maintain_songs sings whatever is missing.
local function check_party_join()
    local now_in_party = in_party()
    if now_in_party and not was_in_party then
        song_busy_until = 0
        maintain_songs()
    end
    was_in_party = now_in_party
end

local function maintain_target_spells()
    local player = windower.ffxi.get_player()
    if player.status ~= 1 then return end
    if os.clock() < target_spell_delay_until then return end
    if next(settings.target_spells) == nil then return end
    local now = os.time()
    local delay = 0
    for _, entry in pairs(settings.target_spells) do
        local duration = entry.duration or TARGET_SPELL_INTERVAL
        local last = last_target_spell_cast[entry.name] or 0
        if now >= last + duration then
            last_target_spell_cast[entry.name] = now + delay
            if delay > 0 then
                windower.send_command('wait ' .. delay .. '; input /ma "' .. entry.name .. '" <t>')
            else
                windower.send_command('input /ma "' .. entry.name .. '" <t>')
            end
            delay = delay + 3
        end
    end
end

local last_item_use     = 0
local ITEM_USE_COOLDOWN = 5.0

local function try_eat_food()
    if settings.food_name ~= '' and not is_food_active() and find_in_inventory(settings.food_name) then
        windower.send_command('input /item "' .. settings.food_name .. '" <me>')
    end
end

local function try_use_item()
    if settings.use_item == '' then return end
    local now = os.clock()
    if now < last_item_use + ITEM_USE_COOLDOWN then return end
    if find_in_inventory(settings.use_item) then
        last_item_use = now
        windower.send_command('input /item "' .. settings.use_item .. '" <me>')
    end
end

local function try_equip_ammo()
    if settings.ammo_name ~= '' then
        if find_in_inventory(settings.ammo_name) then
            windower.send_command('input /equip Ammo "' .. settings.ammo_name .. '"')
        else
            windower.add_to_chat(8, 'AutoSilc: Out of "' .. settings.ammo_name .. '".')
        end
    end
end

local function try_provoke()
    if not settings.provoke then return end
    local player = windower.ffxi.get_player()
    if player.status ~= 1 then return end
    if os.time() - last_provoke_time < PROVOKE_RECAST then return end
    last_provoke_time = os.time()
    windower.send_command('input /ja "Provoke" <t>')
end

-- MagianWS ranked every matching mob in range and took the closest. There is
-- nothing to rank here: there is exactly one right answer and the leader has
-- already chosen it. Kept as a wrapper so the call sites below read the same as
-- they do in MagianWS.
local function find_target_mob()
    return assist_target()
end

local sc_window = nil  -- open skillchain window: {active, delay_until, expires} or nil

local last_scan_tick  = 0
local SCAN_INTERVAL   = 2.0
local last_buff_tick  = 0
local BUFF_CHECK_INTERVAL = 10.0
local debug_target    = false
local active          = false  -- start/stop toggle (not persisted)
local returning_home  = false  -- true while windower.ffxi.run() is active toward home
local unlock_at       = 0     -- os.clock() timestamp to send the lock-off packet
local pull_sent       = false  -- true after /ra fired; reset when acquiring a new target
local pull_sent_at    = 0     -- os.clock() when /ra was sent; used for pull failsafe
local PULL_TIMEOUT    = 15.0  -- seconds before retrying a failed pull
local pull_wait_since = 0     -- os.clock() when we started waiting for a mob to enter pull range
local PULL_GIVEUP     = 10.0  -- seconds to wait on an unreachable mob before dropping it
local pull_follow_at  = 0     -- os.clock() after which we walk to a pulled mob that isn't closing
local pull_following  = false -- true while walking to a pulled mob; cleared on melee contact
-- Following is for closing the gap, not for fighting. Once a melee round has
-- gone out at a mob we are by definition in range of it, so the follow is over:
-- carrying on means walking into the mob for the rest of the fight. `/follow` is
-- a toggle, so stopping it needs to know whether it is actually on - hence both
-- of these rather than one. melee_contact_id is compared against the current
-- target's id, so switching mobs re-enables the approach on its own.
local melee_contact_id = 0     -- mob id we have landed a melee round on
local follow_active    = false -- true while the client has been told to follow
local PULL_FOLLOW_DELAY = 12.0 -- seconds after the pull lands before walking to the mob
local PULL_FOLLOW_MAX   = 15.0 -- seconds to keep walking before giving up on the mob

local DEBUG_LOG = windower.addon_path .. 'data/debug.log'
-- Bumped whenever this file is edited, so //autosilc status proves which build is
-- actually loaded (a reload is easy to forget; debug_target and active reset with it).
local BUILD_TAG = 'assist-5-followfix'

function dbg(msg)
    if not debug_target then return end
    windower.add_to_chat(8, 'AutoSilc[dbg]: ' .. msg)
    -- Mirror to disk so the log can be read outside the game. Opened per write so
    -- the file stays complete if the client crashes or the addon is unloaded.
    local f = io.open(DEBUG_LOG, 'a')
    if f then
        f:write(os.date('%Y-%m-%d %H:%M:%S ') .. msg .. '\n')
        f:close()
    end
end

local function stop_return_home()
    if returning_home then
        returning_home = false
        windower.ffxi.run(false)
    end
end

-- Cancel the approach-walk started after a pull. /follow is a toggle, so re-issuing
-- it with no target stops the client following.
local function stop_pull_follow()
    if not pull_following then return end
    pull_following = false
    pull_follow_at = 0
    follow_active  = false
    windower.send_command('input /follow')
end

local function try_return_home()
    if not settings.home_set then return end
    if settings.pull_mode then return end
    local dist = home_distance()
    if not dist then return end

    if dist <= HOME_RANGE then
        stop_return_home()
        return
    end

    local me = windower.ffxi.get_mob_by_target('me')
    if not me then return end
    local dx = settings.home_x - me.x
    local dy = settings.home_y - me.y
    local len = math.sqrt(dx*dx + dy*dy)
    if len == 0 then return end

    returning_home = true
    dbg('run[return-home] dist=' .. string.format('%.1f', dist) .. 'y')
    windower.ffxi.run(dx / len, dy / len)
end

-- mob.distance is squared, so every comparison against it has to be too.
-- scan_range was inert in AutoSilc (the leader picks the target, not distance);
-- it is now the ceiling on how far we will walk to one.
local function chase_limit_sq()
    local r = settings.scan_range or 40
    return r * r
end

local function face_mob(mob)
    local me = windower.ffxi.get_mob_by_target('me')
    if not me or not mob then return end
    -- FFXI angle convention: 0=east, π/2=south, π=west, 3π/2=north (clockwise).
    -- from_radian(r) = {cos(r), -sin(r)}, so the target angle = atan2(-(dy), dx).
    windower.ffxi.turn(math.atan2(me.y - mob.y, mob.x - me.x))
end

local function try_engage_target()
    if not active then return end
    if not has_targets() then return end
    local player = windower.ffxi.get_player()
    if not player or (player.status ~= 0 and player.status ~= 1) then return end
    local assist_mob = assist_target()
    dbg('scan | status=' .. tostring(player.status)
        .. ' assist=' .. (assist_player_name() or 'none')
        .. ' mob=' .. (assist_mob and assist_mob.name or 'none'))

    if player.status == 1 then
        -- Failsafe: normally the melee-round packet cancels the approach-walk. If that
        -- never arrives (stuck on terrain, unparsed packet), stop walking anyway.
        if pull_following and os.clock() >= pull_follow_at + PULL_FOLLOW_MAX then
            dbg('no melee contact detected — cancelling follow (timeout)')
            stop_pull_follow()
        end
        -- MagianWS, once engaged, only ever faced or followed whatever it was
        -- already on. AutoSilc has to keep watching: the leader can switch mobs
        -- mid-fight, and if we do not switch with them we sit hitting a mob
        -- nobody else is on. Re-target first, then fall through to face/follow.
        --
        -- The test is our own mob's target_index, NOT the client cursor from
        -- get_mob_by_target('t'). Those are different things: with follow on,
        -- the unlock timer in prerender deliberately clears the cursor a second
        -- after each follow, so cursor-based logic would think we had lost the
        -- target every single scan and re-issue /attack forever. target_index is
        -- who we are actually swinging at.
        local me = windower.ffxi.get_mob_by_target('me')
        local engaged_on = me and me.target_index or nil
        if assist_mob and engaged_on ~= assist_mob.index then
            dbg('leader switched targets -> "' .. assist_mob.name .. '" — retargeting')
            pcall(function()
                packets.inject(packets.new('incoming', 0x058, {
                    ['Player']       = player.id,
                    ['Target']       = assist_mob.id,
                    ['Player Index'] = player.index,
                }))
            end)
            -- '/attack <t>' and not a bare '/attack': bare /attack TOGGLES, so
            -- while engaged it would disengage us instead of switching mobs.
            windower.send_command('input /attack <t>')
        end
        local current_target = windower.ffxi.get_mob_by_target('t') or assist_mob
        if current_target then
            if settings.home_set or not settings.follow then
                face_mob(current_target)
            elseif melee_contact_id == current_target.id then
                -- In melee with this mob already. Keep facing it, but do not
                -- re-issue the follow the scan before us just cancelled.
                face_mob(current_target)
            else
                dbg('follow[engaged] target="' .. (current_target.name or '?') .. '" hpp=' .. tostring(current_target.hpp) .. ' status=' .. tostring(current_target.status))
                pcall(function()
                    packets.inject(packets.new('incoming', 0x058, {
                        ['Player']       = player.id,
                        ['Target']       = current_target.id,
                        ['Player Index'] = player.index,
                    }))
                end)
                windower.send_command('input /follow <t>')
                follow_active = true
                unlock_at = os.clock() + 1.0
            end
        end
        return
    end

    -- Already have the right mob targeted — approach or attack.
    --
    -- MagianWS asked "is my target one of the names I was told to kill, and is
    -- it unclaimed?". Both halves change here. The name no longer decides
    -- anything, and the claim test moved into is_target_mob(), which accepts a
    -- claim held by anyone in our party - the leader's claim is the whole point.
    local current_target = windower.ffxi.get_mob_by_target('t')
    if current_target and assist_mob and current_target.id == assist_mob.id
            and is_target_mob(current_target) then
        local dist_sq = current_target.distance or math.huge
        if settings.pull_mode then
            if not pull_sent then
                if dist_sq <= settings.pull_range * settings.pull_range then
                    pull_wait_since = 0
                    face_mob(current_target)
                    local method = settings.pull_method or 'ra'
                    if method == 'magic' then
                        local pull_spell = nil
                        for _, e in pairs(settings.target_spells) do pull_spell = e; break end
                        if pull_spell then
                            dbg('pull mode — magic pull: ' .. pull_spell.name .. ' (dist_sq=' .. tostring(dist_sq) .. ')')
                            windower.send_command('wait 1; input /ma "' .. pull_spell.name .. '" <t>')
                            pull_sent = true
                            pull_sent_at = os.clock() + 1
                            pull_follow_at = pull_sent_at + PULL_FOLLOW_DELAY
                            pull_following = false
                            last_target_spell_cast[pull_spell.name] = os.time()
                        else
                            windower.add_to_chat(8, 'AutoSilc: pull method is magic but no target spells configured.')
                        end
                    else
                        dbg('pull mode — RA pull (dist_sq=' .. tostring(dist_sq) .. ')')
                        windower.send_command('wait 2; input /ra <t>')
                        pull_sent = true
                        pull_sent_at = os.clock() + 2
                        pull_follow_at = pull_sent_at + PULL_FOLLOW_DELAY
                        pull_following = false
                    end
                else
                    -- Stay put; target selection already restricts to mobs within pull_range,
                    -- so this means the mob drifted out after being locked. Give it a short
                    -- grace period to wander back, then drop it so the scanner can pick a
                    -- reachable one — otherwise we stay locked on an unreachable mob forever
                    -- and never pull or attack anything again.
                    if pull_wait_since == 0 then pull_wait_since = os.clock() end
                    if os.clock() >= pull_wait_since + PULL_GIVEUP then
                        dbg('pull mode — mob never entered pull range, dropping it (dist_sq=' .. tostring(dist_sq) .. ')')
                        pull_wait_since = 0
                        pull_sent = false
                        pcall(function()
                            packets.inject(packets.new('incoming', 0x058, {
                                ['Player']       = player.id,
                                ['Target']       = 0,
                                ['Player Index'] = player.index,
                            }))
                        end)
                    else
                        dbg('pull mode — waiting for mob to enter pull range (dist_sq=' .. tostring(dist_sq) .. ')')
                    end
                end
            elseif dist_sq <= ATTACK_RANGE_SQ then
                -- Engage here, but keep any approach-walk running: 20y is the engage
                -- window, not melee range. The walk stops on the first melee round.
                dbg('in range — attacking')
                windower.send_command('input /attack')
            else
                -- Pulled, but the mob isn't closing. Walk to it after a short grace
                -- period; the 'action' handler cancels the walk on melee contact.
                local now = os.clock()
                if pull_following then
                    if now >= pull_follow_at + PULL_FOLLOW_MAX then
                        dbg('pull mode — follow timed out, dropping mob (dist_sq=' .. tostring(dist_sq) .. ')')
                        stop_pull_follow()
                        pull_sent = false
                        pull_wait_since = 0
                        pcall(function()
                            packets.inject(packets.new('incoming', 0x058, {
                                ['Player']       = player.id,
                                ['Target']       = 0,
                                ['Player Index'] = player.index,
                            }))
                        end)
                    else
                        dbg('pull mode — walking to pulled mob (dist_sq=' .. tostring(dist_sq) .. ')')
                    end
                elseif now >= pull_follow_at then
                    dbg('pull mode — mob not closing, walking to it (dist_sq=' .. tostring(dist_sq) .. ')')
                    pull_following = true
                    pull_follow_at = now
                    pcall(function()
                        packets.inject(packets.new('incoming', 0x058, {
                            ['Player']       = player.id,
                            ['Target']       = current_target.id,
                            ['Player Index'] = player.index,
                        }))
                    end)
                    windower.send_command('input /follow <t>')
                elseif now >= pull_sent_at + PULL_TIMEOUT then
                    dbg('pull timed out — retrying pull')
                    pull_sent = false
                    pull_wait_since = 0
                else
                    dbg('pull mode — waiting for mob (dist_sq=' .. tostring(dist_sq) .. ')')
                end
            end
        elseif not settings.follow then
            -- follow off means stand and fight what reaches us. This branch used
            -- to walk regardless of the setting, which is why Silc ran off with
            -- follow off: on the mob's death he drops to idle, resolves the next
            -- assist target and walked to it from here.
            dbg('approach: follow is off — holding position (dist_sq=' .. tostring(dist_sq) .. ')')
            face_mob(current_target)
            if dist_sq <= ATTACK_RANGE_SQ then
                dbg('in range — attacking')
                windower.send_command('input /attack')
            end
        elseif dist_sq > chase_limit_sq() then
            -- Even with follow on, do not cross the zone for a mob. The fallback
            -- target source is the leader's target_index, and a mob index that
            -- has been recycled resolves to something unrelated - which is what
            -- an unbounded follow turns into a sprint to the far end of the map.
            dbg('approach: target beyond scan_range — not chasing (dist_sq='
                .. tostring(dist_sq) .. ' limit=' .. tostring(chase_limit_sq()) .. ')')
            face_mob(current_target)
        else
            dbg('follow[approach] target="' .. (current_target.name or '?') .. '" hpp=' .. tostring(current_target.hpp) .. ' status=' .. tostring(current_target.status) .. ' dist_sq=' .. tostring(dist_sq))
            windower.send_command('input /follow <t>')
            follow_active = true
            if dist_sq <= ATTACK_RANGE_SQ then
                dbg('in range — attacking')
                windower.send_command('input /attack')
            end
        end
        return
    end

    -- We are holding a target that is no longer the one to be on: it died, the
    -- leader moved off it, or an outsider claimed it. Deselect to cancel follow.
    if current_target and current_target.id and current_target.id ~= 0
            and not is_player_or_trust(current_target.spawn_type or 0) then
        dbg('deselect[invalid] target="' .. current_target.name .. '" hpp=' .. tostring(current_target.hpp) .. ' status=' .. tostring(current_target.status) .. ' claim=' .. tostring(current_target.claim_id))
        pull_sent = false
        pull_wait_since = 0
        stop_pull_follow()
        -- stop_pull_follow() only fires in pull mode, so outside it an assist
        -- follow survived the mob's death: deselecting drops the cursor but the
        -- client keeps walking. Cancel it explicitly.
        melee_contact_id = 0
        if follow_active then
            dbg('deselect[invalid] — stopping follow')
            follow_active = false
            windower.send_command('input /follow')
        end
        pcall(function()
            packets.inject(packets.new('incoming', 0x058, {
                ['Player']       = player.id,
                ['Target']       = 0,
                ['Player Index'] = player.index,
            }))
        end)
        return
    end

    -- No valid target yet. MagianWS swept the whole mob array here, logging why
    -- each name match was rejected, because target selection was its own job and
    -- could fail in a dozen ways. AutoSilc has one question with one answer, so
    -- the sweep is gone; if there is no mob it is because the leader is not on
    -- one, and dbg() below says so.
    pull_sent = false
    pull_wait_since = 0
    stop_pull_follow()

    local mob = find_target_mob()
    if mob then
        stop_return_home()
        dbg('targeting id=' .. tostring(mob.id) .. ' index=' .. tostring(mob.index))
        local ok, err = pcall(function()
            packets.inject(packets.new('incoming', 0x058, {
                ['Player']       = player.id,
                ['Target']       = mob.id,
                ['Player Index'] = player.index,
            }))
        end)
        if ok then
            if settings.pull_mode then
                dbg('targeted — holding position, waiting for mob to enter pull range')
            elseif not settings.follow then
                dbg('targeted — follow is off, holding position')
            elseif (mob.distance or math.huge) > chase_limit_sq() then
                dbg('targeted — beyond scan_range, not chasing (dist_sq='
                    .. tostring(mob.distance) .. ')')
            else
                dbg('targeted — following')
                windower.send_command('input /follow <t>')
                follow_active = true
            end
        else
            dbg('packet error: ' .. tostring(err))
        end
    elseif assist_holding() then
        -- Mid-hold. Standing still is the point; going home would undo it and
        -- then walk straight back out again when the hold expires.
        dbg('holding ' .. string.format('%.1f', assist_hold_remaining())
            .. 's before assisting')
    else
        dbg('no assist target — ' .. (assist_player_name() or 'no leader')
            .. ' is not on anything we will attack')
        try_return_home()
    end
end

windower.register_event('prerender', function()
    local now = os.clock()

    if unlock_at > 0 and now >= unlock_at then
        unlock_at = 0
        local player = windower.ffxi.get_player()
        if player then
            pcall(function()
                packets.inject(packets.new('incoming', 0x058, {
                    ['Player']       = player.id,
                    ['Target']       = 0,
                    ['Player Index'] = player.index,
                }))
            end)
        end
    end

    if now >= last_scan_tick + SCAN_INTERVAL then
        last_scan_tick = now
        if settings.home_set or settings.mode == 'exp' then update_display() end
        try_engage_target()
        if active then try_use_item() end
    end

    if now >= last_buff_tick + BUFF_CHECK_INTERVAL then
        last_buff_tick = now
        -- Songs sit outside the "active" guard on purpose: the trigger is
        -- being in a party with the addon loaded, not //autosilc start.
        check_party_join()
        maintain_songs()
        if active then
            maintain_buffs()
            maintain_target_spells()
        end
    end
end)

local function print_status()
    local buff_count = 0
    for _ in pairs(get_active_buffs()) do buff_count = buff_count + 1 end
    local buff_str = settings.active_buff_set ~= '' and (settings.active_buff_set .. ' (' .. buff_count .. ')') or 'off'
    local rem_str = settings.trial_remaining >= 0 and tostring(settings.trial_remaining) or '?'
    local home_str = settings.home_set and ('(%.1f, %.1f, %.1f)'):format(settings.home_x, settings.home_y, settings.home_z) or 'off'
    windower.add_to_chat(8, 'AutoSilc: [' .. BUILD_TAG .. '] Weaponskill: "' .. settings.ws_name .. '" | TP threshold: ' .. settings.tp_threshold .. ' | Remaining: ' .. rem_str .. ' | Food: ' .. (settings.food_name ~= '' and settings.food_name or 'off') .. ' | Ammo: ' .. (settings.ammo_name ~= '' and settings.ammo_name or 'off') .. ' | Item: ' .. (settings.use_item ~= '' and settings.use_item or 'off') .. ' | Buffs: ' .. buff_str .. ' | Songs: ' .. (songs_enabled and 'on' or 'off') .. ' | Provoke: ' .. (settings.provoke and 'on' or 'off') .. ' | Follow: ' .. (settings.follow and 'on' or 'off') .. ' | Pull: ' .. (settings.pull_mode and 'on' or 'off') .. ' | Range: ' .. tostring(settings.scan_range) .. 'y | Home: ' .. home_str .. ' | Assist: ' .. assist_display()
        .. ' | Only: ' .. (next(settings.target_names) ~= nil and target_names_display() or 'any') .. ' | Active: ' .. (active and 'yes' or 'no'))
end

local function try_eat_food_if_engaged()
    local player = windower.ffxi.get_player()
    if player.status == 1 then
        try_eat_food()
    end
end

-- Returns the level of skillchain formed (1-4) if ws2_props can close the
-- resonance opened by ws1_props, or nil if no chain is possible.
local function check_sc_props(ws1_props, ws2_props)
    for _, first in ipairs(ws1_props) do
        local combo = sc_data.sc_info[first]
        if combo then
            for _, second in ipairs(ws2_props) do
                local result = combo[second]
                if result then return result[1], result[2] end
            end
        end
    end
    return nil
end

local function execute_ws()
    try_equip_ammo()
    windower.send_command('input /ws "' .. settings.ws_name .. '" <t>')
end

windower.register_event('addon command', function(cmd, ...)
    if cmd == 'ws' then
        settings.ws_name = table.concat({...}, ' ')
        settings:save()
        print_status()
    elseif cmd == 'ws2' then
        local arg = table.concat({...}, ' ')
        if arg == '' or arg:lower() == 'off' then
            settings.ws2_name = ''
            sc_window = nil
            windower.add_to_chat(8, 'AutoSilc: WS2 disabled.')
        else
            local ws_data = sc_data.ws_by_name[arg:lower()]
            if ws_data then
                settings.ws2_name = arg
                windower.add_to_chat(8, ('AutoSilc: WS2 set to "%s" (%s).'):format(arg, table.concat(ws_data.skillchain, '/')))
            else
                -- Accept the name even if not in skill data (might be a newer WS)
                settings.ws2_name = arg
                windower.add_to_chat(8, ('AutoSilc: WS2 set to "%s" (no SC data — chain detection unavailable).'):format(arg))
            end
        end
        settings:save()
        update_display()
    elseif cmd == 'tp' then
        local val = tonumber((...))
        if val then
            settings.tp_threshold = val
            settings:save()
            print_status()
        else
            windower.add_to_chat(8, 'AutoSilc: Invalid TP value.')
        end
    elseif cmd == 'food' then
        local arg = table.concat({...}, ' ')
        if arg == '' or arg:lower() == 'off' then
            settings.food_name = ''
        else
            settings.food_name = arg
            try_eat_food_if_engaged()
        end
        settings:save()
        print_status()
    elseif cmd == 'ammo' then
        local arg = table.concat({...}, ' ')
        if arg == '' or arg:lower() == 'off' then
            settings.ammo_name = ''
        else
            settings.ammo_name = arg
            try_equip_ammo()
        end
        settings:save()
        print_status()
    elseif cmd == 'item' then
        local arg = table.concat({...}, ' ')
        if arg == '' or arg:lower() == 'off' then
            settings.use_item = ''
        else
            settings.use_item = arg
        end
        settings:save()
        print_status()
    elseif cmd == 'buff' then
        local subcmd = (...)
        local rest = {select(2, ...)}
        local active_set_name = settings.active_buff_set
        if subcmd == 'add' then
            if active_set_name == '' then
                windower.add_to_chat(8, 'AutoSilc: No active buff set. Use: //autosilc buffset use <name>')
            else
                local buff_name = table.concat(rest, ' ')
                local info = find_buff_info(buff_name)
                if info then
                    local set = settings.buff_sets[active_set_name]
                    local key = settings_key(info.name)
                    set[key] = {name = info.name, type = info.type, buff_id = info.buff_id}
                    settings:save()
                    windower.add_to_chat(8, 'AutoSilc: Added "' .. info.name .. '" to set "' .. active_set_name .. '".')
                else
                    windower.add_to_chat(8, 'AutoSilc: Unknown buff "' .. buff_name .. '".')
                end
            end
        elseif subcmd == 'remove' then
            if active_set_name == '' then
                windower.add_to_chat(8, 'AutoSilc: No active buff set.')
            else
                local buff_name = table.concat(rest, ' ')
                local search_key = settings_key(buff_name)
                local set = settings.buff_sets[active_set_name]
                local found = false
                for k in pairs(set) do
                    if k:lower() == search_key:lower() then
                        local display_name = set[k].name or k
                        set[k] = nil
                        settings:save()
                        windower.add_to_chat(8, 'AutoSilc: Removed "' .. display_name .. '" from set "' .. active_set_name .. '".')
                        found = true
                        break
                    end
                end
                if not found then
                    windower.add_to_chat(8, 'AutoSilc: Buff "' .. buff_name .. '" not found in set "' .. active_set_name .. '".')
                end
            end
        elseif subcmd == 'list' then
            if active_set_name == '' then
                windower.add_to_chat(8, 'AutoSilc: No active buff set.')
            else
                local set = settings.buff_sets[active_set_name]
                local count = 0
                for _, entry in pairs(set) do
                    windower.add_to_chat(8, 'AutoSilc: "' .. entry.name .. '" (' .. entry.type .. ')')
                    count = count + 1
                end
                if count == 0 then
                    windower.add_to_chat(8, 'AutoSilc: Set "' .. active_set_name .. '" has no buffs.')
                end
            end
        end
    elseif cmd == 'buffset' then
        local subcmd = (...)
        local rest = {select(2, ...)}
        local name = table.concat(rest, ' ')
        if subcmd == 'create' then
            if name == '' then
                windower.add_to_chat(8, 'AutoSilc: Usage: buffset create <name>')
            elseif settings.buff_sets[name] then
                windower.add_to_chat(8, 'AutoSilc: Set "' .. name .. '" already exists.')
            else
                settings.buff_sets[name] = {}
                settings.active_buff_set = name
                settings:save()
                windower.add_to_chat(8, 'AutoSilc: Created buff set "' .. name .. '" (now active).')
            end
        elseif subcmd == 'use' then
            if name == '' or name:lower() == 'off' then
                settings.active_buff_set = ''
                settings:save()
                windower.add_to_chat(8, 'AutoSilc: Buff set deactivated.')
            elseif settings.buff_sets[name] then
                settings.active_buff_set = name
                settings:save()
                windower.add_to_chat(8, 'AutoSilc: Using buff set "' .. name .. '".')
            else
                windower.add_to_chat(8, 'AutoSilc: Set "' .. name .. '" not found. Use: //autosilc buffset create <name>')
            end
        elseif subcmd == 'delete' then
            if name == '' then
                windower.add_to_chat(8, 'AutoSilc: Usage: buffset delete <name>')
            elseif settings.buff_sets[name] then
                settings.buff_sets[name] = nil
                if settings.active_buff_set == name then settings.active_buff_set = '' end
                settings:save()
                windower.add_to_chat(8, 'AutoSilc: Deleted buff set "' .. name .. '".')
            else
                windower.add_to_chat(8, 'AutoSilc: Set "' .. name .. '" not found.')
            end
        elseif subcmd == 'list' then
            local count = 0
            for set_name, set in pairs(settings.buff_sets) do
                local n = 0
                for _ in pairs(set) do n = n + 1 end
                local marker = set_name == settings.active_buff_set and ' ◀' or ''
                windower.add_to_chat(8, 'AutoSilc: "' .. set_name .. '" — ' .. n .. ' buff(s)' .. marker)
                count = count + 1
            end
            if count == 0 then
                windower.add_to_chat(8, 'AutoSilc: No buff sets configured.')
            end
        else
            windower.add_to_chat(8, 'AutoSilc: Usage: buffset create|use|delete|list <name>')
        end
    elseif cmd == 'provoke' then
        local arg = (...)
        if arg == 'on' then
            settings.provoke = true
            last_provoke_time = 0
        elseif arg == 'off' then
            settings.provoke = false
        else
            windower.add_to_chat(8, 'AutoSilc: Usage: provoke on|off')
            return
        end
        settings:save()
        print_status()
    elseif cmd == 'follow' then
        local arg = (...)
        if arg == 'on' then
            settings.follow = true
        elseif arg == 'off' then
            settings.follow = false
        else
            windower.add_to_chat(8, 'AutoSilc: Usage: follow on|off')
            return
        end
        settings:save()
        print_status()
    elseif cmd == 'home' then
        local arg = (...)
        if arg == 'set' then
            local me = windower.ffxi.get_mob_by_target('me')
            if me then
                settings.home_set = true
                settings.home_x = me.x
                settings.home_y = me.y
                settings.home_z = me.z
                settings:save()
                windower.add_to_chat(8, ('AutoSilc: Home set to (%.1f, %.1f, %.1f).'):format(me.x, me.y, me.z))
                update_display()
            else
                windower.add_to_chat(8, 'AutoSilc: Could not read player position.')
            end
        elseif arg == 'clear' then
            settings.home_set = false
            settings:save()
            windower.add_to_chat(8, 'AutoSilc: Home point cleared.')
            update_display()
        else
            if settings.home_set then
                local dist = home_distance()
                local dist_str = dist and string.format('%.1f', dist) .. 'y away' or 'unknown'
                windower.add_to_chat(8, ('AutoSilc: Home at (%.1f, %.1f, %.1f) — %s.'):format(settings.home_x, settings.home_y, settings.home_z, dist_str))
            else
                windower.add_to_chat(8, 'AutoSilc: No home point set. Use //autosilc home set.')
            end
        end
    elseif cmd == 'pull' or cmd == 'pullrange' then
        -- Pull mode is a contradiction in an assist addon: the leader decides
        -- what gets pulled and when. settings.pull_mode is forced false at load,
        -- so the pull branches inside try_engage_target() are dead code kept only
        -- to keep this file a line-for-line relative of magianws.lua.
        windower.add_to_chat(8, 'AutoSilc: No pull mode - the leader pulls, AutoSilc assists.')
    elseif cmd == 'range' then
        -- Kept because the setting still exists, but it no longer gates anything:
        -- AutoSilc attacks whatever the leader attacks, however far away it is.
        local val = tonumber((...))
        if val and val > 0 then
            settings.scan_range = val
            settings:save()
            windower.add_to_chat(8, ('AutoSilc: Scan range set to %d yalms.'):format(val))
        else
            windower.add_to_chat(8, ('AutoSilc: Scan range: %d yalms. Usage: range <yalms>'):format(settings.scan_range))
        end
    elseif cmd == 'assist' then
        local arg = (...)
        local rest = {select(2, ...)}
        local name = arg and table.concat({arg, unpack(rest)}, ' ') or nil
        if name == nil or name == '' or name == 'leader' then
            settings.assist_name = ''
            settings:save()
            windower.add_to_chat(8, 'AutoSilc: Assisting the party leader.')
        elseif name == 'off' then
            windower.add_to_chat(8, 'AutoSilc: Assist cannot be turned off - it is'
                .. ' the only way this addon picks a target. Use //autosilc stop.')
        else
            settings.assist_name = name
            settings:save()
            windower.add_to_chat(8, 'AutoSilc: Assisting "' .. name .. '".')
        end
        update_display()
        print_status()
    elseif cmd == 'target' then
        local subcmd = (...)
        local rest = {select(2, ...)}
        if subcmd == nil or subcmd == 'off' then
            settings.target_names = {}
            settings:save()
            windower.add_to_chat(8, 'AutoSilc: Whitelist cleared - will assist on anything.')
            update_display()
        elseif subcmd == 'add' then
            local name = table.concat(rest, ' ')
            if name ~= '' then
                local key = settings_key(name)
                settings.target_names[key] = {name = name}
                settings:save()
                windower.add_to_chat(8, 'AutoSilc: Whitelisted "' .. name .. '".')
                update_display()
            else
                windower.add_to_chat(8, 'AutoSilc: Usage: target add <name>')
            end
        elseif subcmd == 'remove' then
            local name = table.concat(rest, ' ')
            local search = name:lower()
            local found = false
            for k, entry in pairs(settings.target_names) do
                if entry.name:lower() == search then
                    settings.target_names[k] = nil
                    settings:save()
                    windower.add_to_chat(8, 'AutoSilc: Removed "' .. entry.name .. '" from the whitelist.')
                    update_display()
                    found = true
                    break
                end
            end
            if not found then
                windower.add_to_chat(8, 'AutoSilc: Target "' .. name .. '" not found.')
            end
        elseif subcmd == 'list' then
            if next(settings.target_names) ~= nil then
                windower.add_to_chat(8, 'AutoSilc: Whitelist: ' .. target_names_display())
            else
                windower.add_to_chat(8, 'AutoSilc: Whitelist empty - will assist on anything.')
            end
        else
            -- Plain name (no subcommand) — replace all targets with this one
            local name = table.concat({subcmd, unpack(rest)}, ' ')
            settings.target_names = {}
            settings.target_names[settings_key(name)] = {name = name}
            settings:save()
            windower.add_to_chat(8, 'AutoSilc: Whitelist set to "' .. name .. '" only.')
            update_display()
        end
        print_status()
    elseif cmd == 'trial' then
        local subcmd = (...)
        local rest = {select(2, ...)}
        if subcmd == 'set' then
            local val = tonumber(rest[1])
            if val then
                settings.trial_remaining = val
                settings:save()
                update_display()
                windower.add_to_chat(8, 'AutoSilc: Trial remaining set to ' .. val .. '.')
            else
                windower.add_to_chat(8, 'AutoSilc: Usage: trial set <number>')
            end
        elseif subcmd == 'reset' then
            settings.trial_remaining = -1
            settings:save()
            update_display()
            windower.add_to_chat(8, 'AutoSilc: Trial remaining reset.')
        else
            local rem_str = settings.trial_remaining >= 0 and tostring(settings.trial_remaining) or 'unknown'
            windower.add_to_chat(8, 'AutoSilc: Trial remaining: ' .. rem_str)
        end
    elseif cmd == 'show' then
        display_visible = true
        update_display()
    elseif cmd == 'hide' then
        display_visible = false
        update_display()
    elseif cmd == 'start' then
        if not has_targets() then
            local why = settings.assist_name ~= ''
                and ('"' .. settings.assist_name .. '" is not in your party.')
                or 'no party leader found - are you in a party, and are you not the leader yourself?'
            windower.add_to_chat(8, 'AutoSilc: Cannot start: ' .. why)
            windower.add_to_chat(8, 'AutoSilc: Pick someone with //autosilc assist <name>.')
        else
            active = true
            windower.add_to_chat(8, 'AutoSilc: Started — assisting ' .. assist_display() .. '.')
            update_display()
        end
    elseif cmd == 'stop' then
        active = false
        -- Clear the commitment too, so restarting holds before the first mob
        -- rather than snapping onto whatever the leader is already on.
        assist_pending_id   = 0
        assist_committed_id = 0
        stop_return_home()
        stop_pull_follow()
        windower.add_to_chat(8, 'AutoSilc: Stopped.')
        update_display()
    elseif cmd == 'debug' then
        local arg = (...)
        if arg == 'on' then
            debug_target = true
            -- Write immediately so it is obvious whether the log file is reachable,
            -- rather than waiting for the next scan tick to find out.
            local f = io.open(DEBUG_LOG, 'a')
            if f then
                f:write(('%s ==== debug enabled (build %s) ====\n'):format(
                    os.date('%Y-%m-%d %H:%M:%S'), BUILD_TAG))
                f:close()
                windower.add_to_chat(8, 'AutoSilc: Debug ON — logging to ' .. DEBUG_LOG)
            else
                windower.add_to_chat(8, 'AutoSilc: Debug ON, but could NOT write ' .. DEBUG_LOG)
            end
        elseif arg == 'off' then
            debug_target = false
            windower.add_to_chat(8, 'AutoSilc: Target debug logging OFF.')
        elseif arg == 'clear' then
            local f = io.open(DEBUG_LOG, 'w')
            if f then f:close() end
            windower.add_to_chat(8, 'AutoSilc: Debug log cleared.')
        else
            windower.add_to_chat(8, 'AutoSilc: Usage: debug on|off|clear')
        end
    elseif cmd == 'exp' then
        local subcmd = (...)
        if subcmd == 'reset' then
            session_start = os.time()
            session_exp   = 0
            session_cp    = 0
            session_ep    = 0
            update_display()
            windower.add_to_chat(8, 'AutoSilc: Session reset.')
        else
            local elapsed = os.time() - session_start
            local mins = math.floor(elapsed / 60)
            windower.add_to_chat(8, ('AutoSilc: Session %dm — EXP/hr: %s | CP/hr: %s | EP/hr: %s'):format(
                mins, format_rate(session_exp), format_rate(session_cp), format_rate(session_ep)))
        end
    elseif cmd == 'mode' then
        local arg = (...)
        if arg == 'trials' or arg == 'exp' then
            settings.mode = arg
            settings:save()
            update_display()
            windower.add_to_chat(8, 'AutoSilc: Mode set to ' .. arg .. '.')
        else
            windower.add_to_chat(8, 'AutoSilc: Usage: mode trials|exp')
        end
    elseif cmd == 'spell' then
        local subcmd = (...)
        local rest = {select(2, ...)}
        if subcmd == 'add' then
            local spell_name = table.concat(rest, ' ')
            local found = find_spell_name(spell_name)
            if found then
                local key = settings_key(found):lower()
                settings.target_spells[key] = {name = found, duration = TARGET_SPELL_INTERVAL}
                settings:save()
                windower.add_to_chat(8, 'AutoSilc: Added target spell "' .. found .. '".')
            else
                windower.add_to_chat(8, 'AutoSilc: Unknown spell "' .. spell_name .. '". Check spelling and capitalisation.')
            end
        elseif subcmd == 'remove' then
            local spell_name = table.concat(rest, ' ')
            local search = spell_name:lower()
            local found = false
            for k, entry in pairs(settings.target_spells) do
                if entry.name:lower() == search then
                    settings.target_spells[k] = nil
                    settings:save()
                    windower.add_to_chat(8, 'AutoSilc: Removed target spell "' .. entry.name .. '".')
                    found = true
                    break
                end
            end
            if not found then
                windower.add_to_chat(8, 'AutoSilc: Spell "' .. spell_name .. '" not in list.')
            end
        elseif subcmd == 'list' then
            if next(settings.target_spells) == nil then
                windower.add_to_chat(8, 'AutoSilc: No target spells configured.')
            else
                for _, entry in pairs(settings.target_spells) do
                    windower.add_to_chat(8, 'AutoSilc: "' .. entry.name .. '" (every ' .. (entry.duration or TARGET_SPELL_INTERVAL) .. 's)')
                end
            end
        elseif subcmd == 'off' then
            settings.target_spells = {}
            settings:save()
            windower.add_to_chat(8, 'AutoSilc: All target spells cleared.')
        else
            windower.add_to_chat(8, 'AutoSilc: Usage: spell add|remove|list|off <name>')
        end
    elseif cmd == 'songs' then
        local arg = (...)
        if arg == 'off' then
            songs_enabled = false
            windower.add_to_chat(8, 'AutoSilc: Songs off.')
        elseif arg == 'on' or arg == nil then
            songs_enabled = true
            song_busy_until = 0
            maintain_songs()
            windower.add_to_chat(8, 'AutoSilc: Songs on.')
        elseif arg == 'now' then
            song_cast_at = {}
            song_busy_until = 0
            maintain_songs()
            windower.add_to_chat(8, 'AutoSilc: Re-singing.')
        else
            windower.add_to_chat(8, 'AutoSilc: Usage: songs on|off|now')
        end
    elseif cmd == 'status' then
        print_status()
    end
end)

windower.register_event('status change', function(new_status)
    if new_status == 1 then
        stop_return_home()
        if active then
            try_eat_food()
            maintain_buffs()
            last_target_spell_cast = {}
            target_spell_delay_until = pull_sent and (os.clock() + 3.0) or 0
            maintain_target_spells()
        end
    else
        sc_window = nil  -- clear any open chain window on disengage or death
    end
end)

windower.register_event('lose buff', function(buff_id)
    -- A dropped song only ever means its status group is short by one;
    -- maintain_songs works out which song that was. Calling it here just starts
    -- the re-sing without waiting out the rest of the maintenance tick.
    for _, entry in ipairs(SONGS) do
        if entry.status == buff_id then
            maintain_songs()
            break
        end
    end
    if not active then return end
    if buff_id == 251 then
        try_eat_food()
    end
    local player = windower.ffxi.get_player()
    if player.status == 1 then
        for _, entry in pairs(get_active_buffs()) do
            if tonumber(entry.buff_id) == buff_id then
                cast_buff(entry.name, entry.type)
                break
            end
        end
    end
end)

windower.register_event('incoming text', function(original, modified, mode)
    local text = strip_colors(original)
    local lower = text:lower()

    -- Trial/EXP parsing below is passive and keeps running while stopped; this
    -- re-follow is an action, so it respects `active` like everything else.
    if active and settings.follow then
        local player = windower.ffxi.get_player()
        if player.status == 1 then
            if lower:find('out of range') or lower:find('cannot see') then
                -- The mob moved off after we made contact. Clearing the latch
                -- puts the approach back on until the next round lands, which
                -- then stops it again.
                melee_contact_id = 0
                follow_active    = true
                windower.send_command('input /follow <t>')
            end
        end
    end

    local n = parse_trial_remaining(lower)
    if n then
        settings.trial_remaining = n
        settings:save()
        update_display()
    end

    if player_name_lower ~= '' then
        local pn = player_name_lower
        local exp = lower:match(pn .. ' gains (%d+) experience points')
                 or lower:match(pn .. ' gains (%d+) limit points')
        if exp then session_exp = session_exp + tonumber(exp); update_display() end

        local cp = lower:match(pn .. ' gains (%d+) capacity points')
        if cp then session_cp = session_cp + tonumber(cp); update_display() end

        local ep = lower:match(pn .. ' gains (%d+) exemplar points')
        if ep then session_ep = session_ep + tonumber(ep); update_display() end
    end
end)

-- Detect when player's weaponskill resolves and open a skillchain window.
-- Category 3 = weaponskill_finish in action packets (0x028).
windower.register_event('incoming chunk', function(id, data)
    if id ~= 0x028 then return end
    local act = windower.packets.parse_action(data)
    local player = windower.ffxi.get_player()
    if not player then return end

    -- ASSIST TRACKING. This is the primary source of "what is the leader on":
    -- an action packet names an actor and a target outright, so if the leader
    -- swung, cast, shot or used an ability at a mob, that mob is the answer.
    -- Categories are deliberately not filtered - every one of those says the
    -- same thing. Compare with resolve_assist_target(), which prefers what this
    -- records and only falls back to the leader's target_index.
    local leader = get_assist_player()
    if leader and act.actor_id == leader.id and act.targets and act.targets[1] then
        local tid = act.targets[1].id
        local mob = tid and tid ~= 0 and windower.ffxi.get_mob_by_id(tid) or nil
        if is_target_mob(mob) then
            if assist_id ~= mob.id then
                dbg('assist: ' .. (leader.name or '?') .. ' is on "' .. mob.name
                    .. '" (id=' .. tostring(mob.id) .. ')')
            end
            assist_id      = mob.id
            assist_seen_at = os.clock()
        end
    end

    if act.actor_id ~= player.id then return end

    -- Category 1 = a melee attack round by us, which only happens once we are in
    -- melee range — the signal to stop walking. This fires on the swing, not on
    -- the swing connecting: a miss took place at melee range just the same, and
    -- treating it as "not there yet" would keep us walking into the mob until we
    -- happened to land one.
    if act.category == 1 then
        if pull_following then
            dbg('melee contact — cancelling pull follow')
            stop_pull_follow()
        end
        local tid = act.targets and act.targets[1] and act.targets[1].id
        if tid then melee_contact_id = tid end
        if follow_active then
            dbg('melee contact — stopping follow')
            follow_active = false
            windower.send_command('input /follow')
        end
    end

    if settings.ws2_name == '' or act.category ~= 3 then return end
    local ws_data = sc_data.weapon_skills[act.param]
    if not ws_data then return end
    local delay = ws_data.delay or 3
    sc_window = {
        active     = ws_data.skillchain,
        delay_until= os.clock() + delay,
        expires    = os.clock() + delay + 8,
    }
    dbg('SC window opened: ' .. ws_data.en .. ' → ' .. table.concat(ws_data.skillchain, '/'))
end)

windower.register_event('tp change', function(new_tp, old_tp)
    -- Without this, //autosilc stop left weaponskills and Provoke firing for as long
    -- as you stayed engaged: every other handler gates on `active`, this one did not.
    if not active then return end
    local player = windower.ffxi.get_player()
    if not player or player.status ~= 1 then return end
    try_provoke()

    -- If a skillchain window is open, try to close it with WS2 before firing WS1
    if sc_window and settings.ws2_name ~= '' then
        local now = os.clock()
        if now >= sc_window.expires then
            sc_window = nil
        elseif now >= sc_window.delay_until and new_tp >= settings.tp_threshold then
            local ws2_data = sc_data.ws_by_name[settings.ws2_name:lower()]
            if ws2_data then
                local level, chain_name = check_sc_props(sc_window.active, ws2_data.skillchain)
                if level then
                    dbg(('SC close: %s → Lv.%d %s'):format(settings.ws2_name, level, chain_name or '?'))
                    try_equip_ammo()
                    windower.send_command('input /ws "' .. settings.ws2_name .. '" <t>')
                    sc_window = nil
                    return
                end
            end
            -- WS2 can't close the current resonance; give up and let WS1 fire below
            sc_window = nil
        else
            -- Waiting: window open but delay hasn't passed or TP not ready yet;
            -- don't fire WS1 while we still have a chance to close the chain
            if now < sc_window.expires then return end
        end
    end

    if new_tp >= settings.tp_threshold then
        execute_ws()
    end
end)

windower.register_event('zone change', function()
    -- Mob ids do not survive a zone, so a remembered assist target is worse than
    -- no target at all: it could resolve to something unrelated on the far side.
    assist_id      = 0
    assist_seen_at = 0
    assist_pending_id   = 0
    assist_committed_id = 0
    melee_contact_id    = 0
    follow_active       = false
    pull_sent = false
    pull_wait_since = 0
    stop_pull_follow()
    sc_window  = nil
    stop_return_home()
    if active then
        active = false
        windower.add_to_chat(8, 'AutoSilc: Stopped — zone change detected.')
        update_display()
    end
end)



print_status()
update_display()
