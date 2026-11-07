-- Meter bar display for GearInfo (replaces the tile grid from Image_processing.lua).
-- Lines are fixed-width monospace text so values line up; bars are prims under the text.
-- Colours: grey = under cap, green = at cap, amber = over cap (wasted).

meters = {}

local FONT = 'Consolas'
local FONT_SIZE = 10
local LINE_H = 16
local COLS = 40            -- every text line is padded to this many characters
local PAD = 8
local BAR_H = 7
local TITLE_H = 20

local C = {
	label = '(215,222,240)',
	dim   = '(140,150,175)',
	idle  = '(170,180,205)',
	ok    = '(110,210,140)',
	warn  = '(240,180,76)',
	title = '(217,180,90)',
	gear  = '(224,96,96)',
	magic = '(91,143,224)',
	ja    = '(217,180,90)',
}
local RGB = {
	bg     = {215, 14, 22, 52},
	edge   = {255, 143, 166, 216},
	head   = {120, 38, 58, 112},
	track  = {150, 0, 0, 0},
	idle   = {255, 170, 180, 205},
	ok     = {255, 110, 210, 140},
	warn   = {255, 240, 180, 76},
	gear   = {255, 224, 96, 96},
	magic  = {255, 91, 143, 224},
	ja     = {255, 217, 180, 90},
	tick   = {255, 217, 180, 90},
	tip_bg = {235, 11, 15, 29},
}

-- Sections each job shows by default. //gi show <section> changes it for the current job.
meters.SECTIONS = {'haste', 'dw', 'ma', 'tp', 'acc', 'att', 'stp', 'dt', 'eva', 'def'}
local PRESETS = {
	WAR = 'haste dw tp acc dt', SAM = 'haste tp acc dt', DRK = 'haste tp acc dt', DRG = 'haste tp acc dt',
	NIN = 'haste dw tp dt', DNC = 'haste dw tp dt', THF = 'haste dw tp dt', BLU = 'haste dw tp dt',
	COR = 'haste dw tp dt', RDM = 'haste dw tp dt', BRD = 'haste dw tp dt', BST = 'haste dw tp dt',
	MNK = 'haste ma tp dt', PUP = 'haste ma tp dt',
	PLD = 'haste tp dt def eva', RUN = 'haste tp dt def eva',
	RNG = 'tp acc att stp dt',
	WHM = 'dt', BLM = 'dt', SCH = 'dt', GEO = 'dt', SMN = 'dt',
}
local DEFAULT_PRESET = 'haste dw tp dt'

local used = {}
local made = {}
local hits = {}
local tip_text = nil
local dragging = nil
local last_data = nil
local box_w = COLS * 7.4 + PAD * 2
local box_h = 0

local function origin()
	return settings.display.pos.x, settings.display.pos.y
end

local function text(id, str, x, y, bold)
	local name = 'gi_m_t_' .. id
	if not made[name] then
		windower.text.create(name)
		windower.text.set_font(name, FONT)
		windower.text.set_font_size(name, FONT_SIZE)
		windower.text.set_color(name, 255, 235, 238, 248)
		windower.text.set_bg_visibility(name, false)
		windower.text.set_stroke_width(name, 1)
		windower.text.set_stroke_color(name, 160, 0, 0, 0)
		made[name] = 'text'
	end
	windower.text.set_bold(name, bold or false)
	windower.text.set_text(name, str)
	windower.text.set_location(name, x, y)
	windower.text.set_visibility(name, true)
	used[name] = true
	return name
end

local function rect(id, x, y, w, h, rgb)
	local name = 'gi_m_r_' .. id
	if not made[name] then
		windower.prim.create(name)
		made[name] = 'prim'
	end
	windower.prim.set_color(name, rgb[1], rgb[2], rgb[3], rgb[4])
	windower.prim.set_position(name, x, y)
	windower.prim.set_size(name, math.max(0, w), h)
	windower.prim.set_visibility(name, w > 0)
	used[name] = true
	return name
end

local function hide_unused()
	for name, kind in pairs(made) do
		if not used[name] then
			if kind == 'text' then windower.text.set_visibility(name, false)
			else windower.prim.set_visibility(name, false) end
		end
	end
end

local function color(c, s)
	return '\\cs' .. c .. s .. '\\cr'
end

-- Left label + right value on one fixed-width line. Parts are {plain, colour} pairs.
local function line(left, right)
	local function join(parts)
		local plain, out = '', ''
		for _, p in ipairs(parts) do
			plain = plain .. p[1]
			out = out .. (p[2] and color(p[2], p[1]) or p[1])
		end
		return plain, out
	end
	local lp, lo = join(left)
	local rp, ro = join(right or {})
	local gap = math.max(1, COLS - #lp - #rp)
	return lo .. string.rep(' ', gap) .. ro
end

-- under / at / over cap. `lower_is_more` is for DT, where -55 is past a -50 cap.
local function status(v, cap, lower_is_more)
	if lower_is_more then v, cap = -v, -cap end
	if v > cap + 0.05 then return 'warn' end
	if v >= cap - 0.05 then return 'ok' end
	return 'idle'
end

local function pct(raw)
	return raw / 1024 * 100
end

local function fmt(n)
	if math.abs(n - math.floor(n + 0.5)) < 0.05 then return tostring(math.floor(n + 0.5)) end
	return string.format('%.1f', n)
end

function meters.layout_for(job)
	local s = settings.layout and settings.layout[job]
	if type(s) ~= 'string' then s = PRESETS[job] or DEFAULT_PRESET end
	local set = {}
	for w in s:gmatch('%S+') do set[w] = true end
	return set
end

function meters.toggle(job, section)
	local set = meters.layout_for(job)
	set[section] = not set[section] or nil
	local list = {}
	for _, k in ipairs(meters.SECTIONS) do
		if set[k] then list[#list + 1] = k end
	end
	settings.layout = settings.layout or {}
	settings.layout[job] = #list > 0 and table.concat(list, ' ') or 'none'
	settings:save('all')
	return set[section] == true
end

function meters.reset_layout(job)
	if settings.layout then settings.layout[job] = nil end
	settings:save('all')
end

-- data: values worked out in update(); see GearInfo.lua
function meters.render(d)
	used, hits = {}, {}
	if settings.display.hidden then
		hide_unused()
		return
	end

	last_data = d
	local x0, y0 = origin()
	-- prims draw in creation order, so the window has to exist before the bars
	rect('edge', x0 - 1, y0 - 1, box_w + 2, box_h + 2, RGB.edge)
	rect('bg', x0, y0, box_w, box_h, RGB.bg)
	rect('head', x0, y0, box_w, TITLE_H, RGB.head)
	local cx = x0 + PAD
	local y = y0 + TITLE_H + 4
	local bar_w = box_w - PAD * 2
	local show = meters.layout_for(d.job)
	local n = 0

	local function add_line(str, tip)
		n = n + 1
		text(n, str, cx, y)
		if tip then hits[#hits + 1] = {x = x0, y = y, w = box_w, h = LINE_H, tip = tip} end
		y = y + LINE_H
	end
	local function minibar(id, frac, st)
		rect(id .. '_trk', cx, y + 1, bar_w, BAR_H - 2, RGB.track)
		rect(id .. '_fil', cx, y + 1, bar_w * math.min(math.max(frac, 0), 1), BAR_H - 2, RGB[st])
		y = y + BAR_H + 3
	end
	local function gap() y = y + 5 end

	-- Haste: one bar split gear / magic / ability, cap tick at 80%
	if show.haste then
		local g, m, j, t = d.haste.gear, d.haste.magic, d.haste.ja, d.haste.total
		local st = status(t, 820)
		add_line(line({{'Haste', C.label}}, {{fmt(pct(t)) .. '%', C[st]}, {' / 80%', C.dim}}),
			'Total haste: gear + magic + job ability. Weapon delay cannot drop more than 80%.')
		rect('h_trk', cx, y, bar_w, BAR_H, RGB.track)
		local seg_x = cx
		for _, s in ipairs({{'g', math.min(g, 256), RGB.gear}, {'m', math.min(m, 448), RGB.magic}, {'j', math.min(j, 256), RGB.ja}}) do
			local w = math.min(bar_w * s[2] / 820, cx + bar_w - seg_x)
			rect('h_' .. s[1], seg_x, y, w, BAR_H, s[3])
			seg_x = seg_x + math.max(w, 0)
		end
		rect('h_tick', cx + bar_w - 2, y - 2, 2, BAR_H + 4, RGB.tick)
		y = y + BAR_H + 3
		local function part(name, col, raw, cap, cap_txt)
			return {{name .. ' ', col}, {fmt(pct(raw)), C[status(raw, cap)]}, {'/' .. cap_txt, C.dim}}
		end
		local parts = {}
		for _, p in ipairs({part('Gear', C.gear, g, 256, '25'), {{'  '}}, part('Magic', C.magic, m, 448, '43.8'), {{'  '}}, part('JA', C.ja, j, 256, '25')}) do
			for _, q in ipairs(p) do parts[#parts + 1] = q end
		end
		add_line(line(parts),
			'Gear haste caps at 25%, magic haste (Haste, March, Geo) at 43.75%, job ability haste (Hasso, Samba, Last Resort) at 25%. Amber = over cap, wasted.')
		gap()
	end

	-- Dual Wield: gear DW you have vs gear DW needed for the delay cap at current haste
	if show.dw then
		if d.dw then
			local have, need = d.dw.have, d.dw.need
			local st = status(have, need)
			local note = st == 'ok' and 'capped' or st == 'warn' and (have - need) .. ' over' or (need - have) .. ' short'
			add_line(line({{'Dual Wield', C.label}, {'  ' .. note, C[st]}}, {{tostring(have), C[st]}, {' / ' .. need, C.dim}}),
				'Dual Wield from gear vs. the gear DW you need to hit the 80% delay cap at your current haste. Job traits are already counted. Over cap lowers TP per hit.')
			minibar('dw', need > 0 and have / need or 1, st)
		else
			add_line(line({{'Dual Wield', C.label}}, {{'not dual wielding', C.dim}}))
		end
		gap()
	end

	-- Martial Arts (hand-to-hand only)
	if show.ma then
		if d.ma then
			local st = d.ma.need > 0 and 'idle' or d.ma.need == 0 and 'ok' or 'warn'
			local note = d.ma.need > 0 and ('need ' .. d.ma.need .. ' more') or d.ma.need == 0 and 'capped' or (-d.ma.need .. ' over')
			add_line(line({{'Martial Arts', C.label}, {'  gear ' .. d.ma.gear, C.dim}}, {{note, C[st]}}),
				'Martial Arts still needed (beyond job traits and gear) to reach the delay cap at your current haste.')
		else
			add_line(line({{'Martial Arts', C.label}}, {{'not hand-to-hand', C.dim}}))
		end
		gap()
	end

	-- TP
	if show.tp then
		local tp = d.tp
		local hits_ws = tp.melee > 0 and math.ceil(10000 / tp.melee) / 10 or 0
		add_line(line({{'TP per hit', C.label}}, {{tostring(tp.melee)}, {'  ' .. fmt(hits_ws) .. ' hits to WS', C.dim}}),
			'TP gained per melee hit with your current delay and Store TP, and hits needed to go from 0 to 1000 TP.')
		if tp.wstp > 0 and tp.melee > 0 then
			add_line(line({{'  after a WS', C.dim}}, {{fmt(math.ceil((10000 - tp.wstp * 10) / tp.melee) / 10) .. ' hits', C.label}}),
				'Hits to 1000 TP after a weapon skill, using the value saved with //gi save wstp. Clear it with //gi delete wstp.')
		end
		if tp.range > 0 then
			add_line(line({{'Ranged TP/shot', C.label}}, {{tostring(tp.range)}, {'  ' .. fmt(math.ceil(10000 / tp.range) / 10) .. ' shots', C.dim}}),
				'TP gained per ranged attack and shots to 1000 TP.')
		end
		gap()
	end

	if show.acc and d.acc then
		local a = d.acc
		local r = {{tostring(a.main)}}
		if a.sub > 0 then r = {{tostring(a.main)}, {' / ' .. a.sub, C.dim}} end
		add_line(line({{a.sub > 0 and 'Accuracy main/off' or 'Accuracy', C.label}}, r), 'Melee accuracy with current gear and buffs.')
		if a.range > 0 then add_line(line({{'Ranged accuracy', C.label}}, {{tostring(a.range)}}), 'Ranged accuracy with current gear and buffs.') end
	end
	if show.att and d.att then
		local a = d.att
		local r = {{tostring(a.main)}}
		if a.sub > 0 then r = {{tostring(a.main)}, {' / ' .. a.sub, C.dim}} end
		add_line(line({{a.sub > 0 and 'Attack main/off' or 'Attack', C.label}}, r), 'Melee attack with current gear and buffs.')
		if a.range > 0 then add_line(line({{'Ranged attack', C.label}}, {{tostring(a.range)}}), 'Ranged attack with current gear and buffs.') end
	end
	if show.stp then
		add_line(line({{'Store TP', C.label}}, {{tostring(d.stp)}}), 'Store TP from gear and buffs (job traits not included).')
	end
	if (show.acc and d.acc) or (show.att and d.att) or show.stp then gap() end

	-- Damage taken: one bar each against its cap
	if show.dt then
		for _, row in ipairs(d.dt) do
			local st = status(row.v, row.cap, true)
			add_line(line({{row.label, C.label}}, {{fmt(row.v) .. '%', C[st]}, {' / ' .. fmt(row.cap) .. '%', C.dim}}), row.tip)
			minibar('dt_' .. row.key, row.cap ~= 0 and row.v / row.cap or 0, st)
		end
		gap()
	end

	if show.eva then add_line(line({{'Evasion', C.label}}, {{tostring(d.eva)}}), 'Evasion with current gear and buffs.') end
	if show.def then add_line(line({{'Defense', C.label}}, {{tostring(d.def)}}), 'Defense with current gear and buffs.') end

	if n == 0 then
		add_line(line({{'Nothing shown for ' .. d.job, C.dim}}), 'Use //gi show haste (or dw, tp, dt...) to add a section for this job.')
	end
	if not d.update_gs then
		add_line(line({{'GearSwap updates off', C.warn}}, {{'//gi ugs', C.dim}}), 'GearInfo is not sending haste/DW to GearSwap. Turn it back on with //gi ugs.')
	end

	-- Title and window
	box_h = y - y0 + 2
	local title = text('title', line({{'GearInfo', C.title}, {'  ' .. d.job .. (d.sub_job and ('/' .. d.sub_job) or ''), C.label}}, {{'drag', C.dim}}), cx, y0 + 3, true)
	local w = windower.text.get_extents(title)
	if w and w > 0 then box_w = w + PAD * 2 end
	rect('edge', x0 - 1, y0 - 1, box_w + 2, box_h + 2, RGB.edge)
	rect('bg', x0, y0, box_w, box_h, RGB.bg)
	rect('head', x0, y0, box_w, TITLE_H, RGB.head)

	-- Tooltip (drawn last so it sits on top)
	if tip_text then
		local name = text('tip', tip_text.str, tip_text.x + 8, tip_text.y + 6)
		local tw, th = windower.text.get_extents(name)
		tw, th = (tw and tw > 0) and tw or 300, (th and th > 0) and th or 50
		rect('tip_bg', tip_text.x, tip_text.y, tw + 16, th + 12, RGB.tip_bg)
	end

	hide_unused()
end

-- Word-wrap a tooltip to about 46 characters per line
local function wrap(s)
	local out, cur = {}, ''
	for word in s:gmatch('%S+') do
		if #cur + #word + 1 > 46 then out[#out + 1] = cur; cur = word
		else cur = (#cur > 0 and (cur .. ' ') or '') .. word end
	end
	if #cur > 0 then out[#out + 1] = cur end
	return table.concat(out, '\n')
end

function meters.destroy()
	for name, kind in pairs(made) do
		if kind == 'text' then windower.text.delete(name) else windower.prim.delete(name) end
	end
	made, used = {}, {}
end

windower.register_event('mouse', function(type, x, y, delta, blocked)
	if blocked or not settings or settings.display.hidden then return end
	local x0, y0 = origin()

	if type == 0 then
		if dragging then
			settings.display.pos.x = x - dragging.dx
			settings.display.pos.y = y - dragging.dy
			tip_text = nil
			if last_data then meters.render(last_data) end
			return true
		end
		local found
		for _, h in ipairs(hits) do
			if x >= h.x and x <= h.x + h.w and y >= h.y and y < h.y + h.h then found = h break end
		end
		if found then
			-- show the tooltip beside the window, on whichever side has room
			local ui = windower.get_windower_settings().ui_x_res or 1920
			local tx = (x0 + box_w + 320 < ui) and (x0 + box_w + 6) or (x0 - 330)
			if not tip_text or tip_text.tip ~= found.tip then
				tip_text = {tip = found.tip, str = wrap(found.tip), x = tx, y = found.y - 4}
				if last_data then meters.render(last_data) end
			end
		elseif tip_text then
			tip_text = nil
			if last_data then meters.render(last_data) end
		end
	elseif type == 1 then
		if x >= x0 and x <= x0 + box_w and y >= y0 and y <= y0 + TITLE_H then
			dragging = {dx = x - x0, dy = y - y0}
			return true
		end
	elseif type == 2 then
		if dragging then
			dragging = nil
			settings:save('all')
			return true
		end
	end
end)
