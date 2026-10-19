--[[
    Decode an FFXI zone map DAT into a 32-bit BMP the image prims can load.

    A map DAT holds one image chunk (type 0x20). Its body is: flag byte,
    16-byte texture name, a 40-byte BITMAPINFOHEADER, then either
      0xA1: FourCC ("3TXD" = DXT3, stored reversed), data size, 4 unknown
            bytes and the DXT blocks (rows top-down), or
      0xB1: 256 BGRA palette entries and one index byte per pixel (rows
            bottom-up, like a BMP). FFXI alpha runs 0-0x80, so it's doubled.
]]

local image = {}

local CHUNK_IMAGE = 0x20

local function u16(s, i)
    local a, b = s:byte(i, i + 1)
    return a + b * 0x100
end

local function u32(s, i)
    local a, b, c, d = s:byte(i, i + 3)
    return a + b * 0x100 + c * 0x10000 + d * 0x1000000
end

local function le32(n)
    return string.char(n % 0x100, math.floor(n / 0x100) % 0x100,
        math.floor(n / 0x10000) % 0x100, math.floor(n / 0x1000000) % 0x100)
end

-- First image chunk in the file: body string (1-based) or nil
local function image_chunk(data)
    local off = 0
    while off + 16 <= #data do
        local info = u32(data, off + 5)
        local kind = info % 0x80
        local size = (math.floor(info / 0x80) % 0x80000) * 16
        if size == 0 then return nil end
        if kind == CHUNK_IMAGE then return data:sub(off + 17, off + size) end
        off = off + size
    end
end

-- 32-bit BGRA BMP with a V4 header so the alpha channel is honoured.
-- `rows` are already in bottom-up order.
local function bmp(width, height, rows)
    local pixels = table.concat(rows)
    local header_size = 14 + 108
    return 'BM' .. le32(header_size + #pixels) .. '\0\0\0\0' .. le32(header_size)
        .. le32(108) .. le32(width) .. le32(height)
        .. '\1\0' .. '\32\0'                 -- planes, bits per pixel
        .. le32(3)                           -- BI_BITFIELDS
        .. le32(#pixels) .. le32(2835) .. le32(2835) .. le32(0) .. le32(0)
        .. le32(0x00FF0000) .. le32(0x0000FF00) .. le32(0x000000FF) .. le32(0xFF000000)
        .. 'BGRs' .. string.rep('\0', 48)    -- colour space + endpoints/gamma
        .. pixels
end

local function rgb565(c)
    local r = math.floor(c / 0x800) % 0x20
    local g = math.floor(c / 0x20) % 0x40
    local b = c % 0x20
    return r * 8 + math.floor(r / 4), g * 4 + math.floor(g / 16), b * 8 + math.floor(b / 4)
end

local function decode_dxt3(blocks, width, height)
    local char, byte, floor = string.char, string.byte, math.floor
    local lines = {}
    for y = 1, height do lines[y] = {} end

    local bw, bh = width / 4, height / 4
    local pos = 1
    for by = 0, bh - 1 do
        for bx = 0, bw - 1 do
            local r0, g0, b0 = rgb565(u16(blocks, pos + 8))
            local r1, g1, b1 = rgb565(u16(blocks, pos + 10))
            local pr = {r0, r1, floor((2 * r0 + r1) / 3), floor((r0 + 2 * r1) / 3)}
            local pg = {g0, g1, floor((2 * g0 + g1) / 3), floor((g0 + 2 * g1) / 3)}
            local pb = {b0, b1, floor((2 * b0 + b1) / 3), floor((b0 + 2 * b1) / 3)}
            local memo = {}   -- colour index * 16 + alpha nibble -> pixel

            for i = 0, 15 do
                local ab = byte(blocks, pos + floor(i / 2))
                local a = (i % 2 == 0) and (ab % 16) or floor(ab / 16)
                local ib = byte(blocks, pos + 12 + floor(i / 4))
                local ci = floor(ib / 4 ^ (i % 4)) % 4
                local key = ci * 16 + a
                local px = memo[key]
                if not px then
                    px = char(pb[ci + 1], pg[ci + 1], pr[ci + 1], a * 17)
                    memo[key] = px
                end
                lines[by * 4 + floor(i / 4) + 1][bx * 4 + i % 4 + 1] = px
            end
            pos = pos + 16
        end
    end

    -- BMP rows run bottom-up
    local rows = {}
    for y = height, 1, -1 do rows[#rows + 1] = table.concat(lines[y]) end
    return rows
end

local function decode_palette(body, width, height)
    local pal = {}
    for i = 0, 255 do
        local b, g, r, a = body:byte(58 + i * 4, 61 + i * 4)
        pal[string.char(i)] = string.char(b, g, r, math.min(a * 2, 255))
    end
    local first = 58 + 1024
    local idx = body:sub(first, first + width * height - 1)
    return {(idx:gsub('.', pal))}
end

-- Decode `dat_path` and write it to `out_path`. Returns true or nil, reason.
function image.extract(dat_path, out_path)
    local f = io.open(dat_path, 'rb')
    if not f then return nil, 'missing ' .. dat_path end
    local data = f:read('*a')
    f:close()

    local body = image_chunk(data)
    if not body then return nil, 'no image in ' .. dat_path end

    local flag = body:byte(1)
    local width = u32(body, 22)
    local height = u32(body, 26)
    if height >= 0x80000000 then height = 0x100000000 - height end

    local rows
    if flag == 0xA1 then
        local fourcc = body:sub(58, 61):reverse()
        if fourcc ~= 'DXT3' then return nil, 'unsupported texture ' .. fourcc end
        local size = u32(body, 62)
        rows = decode_dxt3(body:sub(70, 69 + size), width, height)
    elseif flag == 0xB1 then
        rows = decode_palette(body, width, height)
    else
        return nil, string.format('unknown image flag 0x%02X', flag)
    end

    local out = io.open(out_path, 'wb')
    if not out then return nil, 'cannot write ' .. out_path end
    out:write(bmp(width, height, rows))
    out:close()
    return true
end

return image
