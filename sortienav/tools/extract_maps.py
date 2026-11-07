"""Extract FFXI in-game map images from the game DATs to PNG.

    python extract_maps.py                 # all Outer Ra'Kaznar maps
    python extract_maps.py --all           # every zone + data/zone_maps.lua
    python extract_maps.py --zone 230      # one zone's maps
    python extract_maps.py ROM/311/110.DAT # any single map DAT
    python extract_maps.py --ffxi "D:/Games/FINAL FANTASY XI" ...

Output goes to ../maps/ as <zone>_<map>.png (e.g. 275_01.png), or
<rom>_<file>.png for a DAT given on the command line.

Which DAT holds which zone map comes from Remapster's scripts/dat_list.json
(github.com/AkadenTK/remapster_maps). A map DAT is one image chunk:
flag 0xA1, 16-byte texture name, a 40-byte BITMAPINFOHEADER, then
FourCC ("3TXD" = DXT3, stored reversed), data size, 4 unknown bytes and
the compressed blocks.
"""

import os
import struct
import sys

import numpy as np
from PIL import Image

DEFAULT_FFXI = r"C:\Program Files (x86)\PlayOnline\SquareEnix\FINAL FANTASY XI"
HERE = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.join(HERE, "..", "maps")

# zone id -> [(map index, DAT path)], from Remapster's dat_list.json.
# 275 is "Outer Ra'Kaznar [U]" there (Windower now calls it [U1]); 274 is
# the normal Outer Ra'Kaznar.
KNOWN = {
    274: [(i, f"ROM/311/{107 + i}.DAT") for i in range(1, 3)],
    275: [(i, f"ROM/311/{109 + i}.DAT") for i in range(1, 17)],
}

CHUNK_IMAGE = 0x20


def chunks(data):
    off = 0
    while off + 16 <= len(data):
        info = struct.unpack_from("<I", data, off + 4)[0]
        kind, size = info & 0x7F, ((info >> 7) & 0x7FFFF) * 16
        if size == 0:
            return
        yield kind, data[off + 16: off + size]
        off += size


def rgb565(c):
    c = c.astype(np.uint32)
    r = (c >> 11) & 0x1F
    g = (c >> 5) & 0x3F
    b = c & 0x1F
    return np.stack([(r << 3) | (r >> 2), (g << 2) | (g >> 4), (b << 3) | (b >> 2)], -1).astype(np.int32)


def decode_dxt(blocks, width, height, fourcc):
    """Decode DXT1/DXT3 into an RGBA uint8 array, vectorised over blocks."""
    bw, bh = width // 4, height // 4
    n = bw * bh
    stride = 16 if fourcc == "DXT3" else 8
    raw = np.frombuffer(blocks[: n * stride], dtype=np.uint8).reshape(n, stride)

    if fourcc == "DXT3":
        alpha_bits = raw[:, :8].copy().view("<u8")[:, 0]
        shifts = np.arange(16, dtype=np.uint64) * 4
        alpha = ((alpha_bits[:, None] >> shifts) & 0xF).astype(np.int32) * 17
        color = raw[:, 8:]
    else:
        alpha = np.full((n, 16), 255, dtype=np.int32)
        color = raw

    c0 = color[:, 0:2].copy().view("<u2")[:, 0]
    c1 = color[:, 2:4].copy().view("<u2")[:, 0]
    idx_bits = color[:, 4:8].copy().view("<u4")[:, 0]
    p0, p1 = rgb565(c0), rgb565(c1)

    # DXT3 always uses 4-colour mode; DXT1 switches to 3-colour + black
    # (transparent) when c0 <= c1.
    four = np.ones(n, dtype=bool) if fourcc == "DXT3" else (c0 > c1)
    p2 = np.where(four[:, None], (2 * p0 + p1) // 3, (p0 + p1) // 2)
    p3 = np.where(four[:, None], (p0 + 2 * p1) // 3, 0)
    palette = np.stack([p0, p1, p2, p3], 1)                     # n x 4 x 3

    idx = ((idx_bits[:, None] >> (np.arange(16, dtype=np.uint32) * 2)) & 3).astype(np.intp)
    rgb = np.take_along_axis(palette, idx[:, :, None].repeat(3, 2), 1)  # n x 16 x 3
    if fourcc == "DXT1":
        alpha = np.where((~four[:, None]) & (idx == 3), 0, alpha)

    px = np.concatenate([rgb, alpha[:, :, None]], 2).astype(np.uint8)  # n x 16 x 4
    px = px.reshape(bh, bw, 4, 4, 4).transpose(0, 2, 1, 3, 4).reshape(height, width, 4)
    return px


def decode_palette(body, width, height):
    """Flag 0xB1: 256 BGRA palette entries, then one index byte per pixel,
    rows bottom-up like a BMP. FFXI alpha runs 0-0x80, so it is doubled."""
    pal = np.frombuffer(body[57: 57 + 1024], dtype=np.uint8).reshape(256, 4).astype(np.int32)
    rgba = np.stack([pal[:, 2], pal[:, 1], pal[:, 0], np.minimum(pal[:, 3] * 2, 255)], 1).astype(np.uint8)
    idx = np.frombuffer(body[57 + 1024: 57 + 1024 + width * height], dtype=np.uint8)
    return rgba[idx].reshape(height, width, 4)[::-1]


def extract(dat_path):
    data = open(dat_path, "rb").read()
    for kind, body in chunks(data):
        if kind != CHUNK_IMAGE:
            continue
        flag = body[0]
        name = body[1:17].split(b"\0")[0].decode("ascii", "replace")
        _, width, height = struct.unpack_from("<Iii", body, 17)
        height = abs(height)
        if flag == 0xA1:
            fourcc = body[57:61][::-1].decode("ascii")
            size = struct.unpack_from("<I", body, 61)[0]
            img = decode_dxt(body[69: 69 + size], width, height, fourcc)
        elif flag == 0xB1:
            img = decode_palette(body, width, height)
        else:
            raise ValueError(f"{dat_path}: unknown image flag {flag:#x}")
        return name, Image.fromarray(img)
    raise ValueError(f"{dat_path}: no image chunk")


def save_png(img, dest):
    # 256 colours is plenty for parchment and cuts each map from ~330 KB to
    # roughly a third, which matters across every zone.
    img.quantize(256, method=Image.Quantize.FASTOCTREE).save(dest, optimize=True)


def zone_names():
    """Zone id -> English name, from Windower's res/zones.lua."""
    import re
    path = os.path.join(HERE, "..", "..", "..", "res", "zones.lua")
    names = {}
    try:
        for m in re.finditer(r'\[(\d+)\] = \{id=\d+,en="((?:[^"\\]|\\.)*)"', open(path, encoding="utf-8").read()):
            names[int(m.group(1))] = m.group(2).replace('\\"', '"')
    except OSError:
        pass
    return names


def write_zone_maps(done):
    """data/zone_maps.lua: every extracted zone's maps as sortienav floors.
    Hand-written entries in data/zones.lua still win over these."""
    names = zone_names()
    lines = [
        "-- GENERATED by tools/extract_maps.py --all. Don't edit; put overrides",
        "-- in data/zones.lua, which wins for any zone listed there.",
        "local GRID = {u0 = 16, v0 = 16, cell = 32}",
        "return {",
    ]
    for zone in sorted(done):
        name = names.get(zone, f"zone {zone}").replace('"', '\\"')
        lines.append(f'    [{zone}] = {{name = "{name}", floors = {{')
        for idx, image in sorted(done[zone]):
            lines.append(f"        {{id = '{idx}', label = 'Map {idx}', "
                         f"map = {{image = '{image}', width = 512, height = 512, grid = GRID}}}},")
        lines.append("    }},")
    lines.append("}")
    path = os.path.join(HERE, "..", "data", "zone_maps.lua")
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    print(f"wrote data/zone_maps.lua ({len(done)} zones)")


def main(argv):
    ffxi = DEFAULT_FFXI
    if "--ffxi" in argv:
        i = argv.index("--ffxi")
        ffxi = argv[i + 1]
        del argv[i: i + 2]

    # (output name, DAT path, zone, map index); zone is None for a bare DAT.
    jobs = []
    all_zones = "--all" in argv
    only_zone = None
    if "--zone" in argv:
        i = argv.index("--zone")
        only_zone = int(argv[i + 1])
        del argv[i: i + 2]
    if all_zones or only_zone is not None:
        import json
        seen = set()
        for e in json.load(open(os.path.join(HERE, "dat_list.json"))):
            key = (e["zone"], e["map"])
            if key in seen or (only_zone is not None and e["zone"] != only_zone):
                continue
            if not os.path.exists(os.path.join(ffxi, e["dat"])):
                continue
            seen.add(key)
            jobs.append((f"{e['zone']}_{e['map']:02d}", e["dat"], e["zone"], e["map"]))
    elif argv:
        for rel in argv:
            parts = rel.replace("\\", "/").split("/")
            jobs.append((f"{parts[-2]}_{parts[-1].split('.')[0]}", rel, None, None))
    else:
        for zone, maps in KNOWN.items():
            for idx, rel in maps:
                jobs.append((f"{zone}_{idx:02d}", rel, zone, idx))

    os.makedirs(OUT_DIR, exist_ok=True)
    done = {}
    for out_name, rel, zone, idx in jobs:
        src = os.path.join(ffxi, rel)
        try:
            name, img = extract(src)
        except (OSError, ValueError) as e:
            print(f"skip {rel}: {e}")
            continue
        save_png(img, os.path.join(OUT_DIR, out_name + ".png"))
        if zone is not None:
            done.setdefault(zone, []).append((idx, out_name + ".png"))
        if not all_zones:
            print(f"{rel} -> maps/{out_name}.png  ({name}, {img.width}x{img.height})")

    if all_zones:
        print(f"extracted {sum(len(v) for v in done.values())} maps")
        write_zone_maps(done)


if __name__ == "__main__":
    main(sys.argv[1:])
