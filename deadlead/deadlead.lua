_addon.name     = 'deadlead'
_addon.author   = 'Adam'
_addon.version  = '1.0'
_addon.commands = {'deadlead', 'dl'}

-- Pass party (or alliance) leader while dead.
--
-- The client refuses to send /pcmd leader while you are KO'd - the block is in
-- the client's command handler, not in the packet itself. This builds the same
-- packet the client would have built and injects it directly.
--
-- Packet: outgoing 0x077 "Change Permissions"
--   (definition: addons/libs/packets/fields.lua:825)
--     Target Name   char[16]          exact character name
--     Party Type    unsigned char     0 = party, 1 = linkshell, 2 = alliance
--     Permissions   unsigned short    0 = party leader, 1 = alliance leader
--                                     (2 = LS pearl, 3 = LS sack - not used here)
--
-- CAVEAT: this only removes the CLIENT-side restriction. If the server also
-- validates that the sender is alive, the packet will simply be ignored and
-- nothing will happen - there is no way to tell from this side except by
-- trying it. The party-leader path is the one built from the documented field
-- comments; the alliance path is inferred from the same comments and is the
-- less certain of the two.
--
-- Commands:
--   //dl                  list party members and mark the current leader
--   //dl <name>           give party leader to <name> (partial name is fine)
--   //dl -a <name>        give alliance leader to <name>

packets = require('packets')

local PARTY_TYPE = {party = 0, alliance = 2}
local PERMISSION = {party = 0, alliance = 1}

local function msg(colour, s)
    windower.add_to_chat(colour, 'deadlead: ' .. s)
end

-- Walk the party table rather than the mob array: the party table is
-- authoritative about who is actually in your party, and carries a name even
-- for members who are out of zone. v.mob only exists when they are nearby.
local function party_members()
    local out = {}
    local party = windower.ffxi.get_party()
    if not party then return out, nil end
    for key, v in pairs(party) do
        if type(v) == 'table' and v.name then
            out[#out + 1] = {key = key, name = v.name, id = v.mob and v.mob.id or nil}
        end
    end
    table.sort(out, function(a, b) return a.key < b.key end)
    return out, party.party1_leader
end

-- Exact match wins over a partial one, so "Char" cannot pick "Char12" when
-- "Char" is really in the party.
local function resolve(query)
    local q = query:lower()
    local members = party_members()
    local partial
    for _, m in ipairs(members) do
        local n = m.name:lower()
        if n == q then
            return m.name
        end
        if not partial and n:find(q, 1, true) then
            partial = m.name
        end
    end
    return partial
end

local function list()
    local members, leader_id = party_members()
    if #members == 0 then
        msg(123, 'you are not in a party.')
        return
    end
    msg(207, 'party members:')
    for _, m in ipairs(members) do
        local tag = ''
        if leader_id and m.id and m.id == leader_id then
            tag = '   <- current leader'
        end
        windower.add_to_chat(8, ('   %-6s %s%s'):format(m.key, m.name, tag))
    end
end

local function give_lead(name, kind)
    local packet = packets.new('outgoing', 0x077, {
        ['Target Name'] = name,
        ['Party Type']  = PARTY_TYPE[kind],
        ['Permissions'] = PERMISSION[kind],
    })
    packets.inject(packet)
    msg(207, ('sent %s leader -> %s'):format(kind, name))
end

windower.register_event('addon command', function(...)
    local args = {...}

    local kind = 'party'
    local first = args[1] and args[1]:lower() or ''
    if first == '-a' or first == 'alliance' or first == 'ally' then
        kind = 'alliance'
        table.remove(args, 1)
    end

    local query = table.concat(args, ' '):gsub('^%s+', ''):gsub('%s+$', '')
    if query == '' then
        list()
        return
    end

    local name = resolve(query)
    if not name then
        msg(123, ('no party member matching "%s". //dl with no name lists them.'):format(query))
        return
    end

    give_lead(name, kind)
end)
