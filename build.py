import os
import datetime
import pygame
import json

version = datetime.datetime.now().strftime("%y.%m.%d+%H%M%S")
result = f'version = "{version}"\n\n'


def rgbaToUint(r, g, b, a):
    return (a << 24) | (b << 16) | (g << 8) | r


def glyph_to_rects(hex_str):
    hex_len = len(hex_str)
    if hex_len == 32:
        hex_per_row = 2
        char_width = 8
    elif hex_len == 64:
        hex_per_row = 4
        char_width = 16
    else:
        hex_per_row = 2
        char_width = 8
        if hex_len < 32:
            hex_str = hex_str.ljust(32, "0")
        else:
            hex_str = hex_str[:32]
    rows_ints = []
    for i in range(0, hex_len, hex_per_row):
        row_hex = hex_str[i : i + hex_per_row]
        if not row_hex:
            row_hex = "0" * hex_per_row
        rows_ints.append(int(row_hex, 16))
    while len(rows_ints) < 16:
        rows_ints.append(0)
    masks = [[0] * (char_width - x + 1) for x in range(char_width)]
    for x in range(char_width):
        for w in range(1, char_width - x + 1):
            masks[x][w] = ((1 << w) - 1) << (char_width - x - w)

    rects = []
    while True:
        best_area = 0
        best_rect = None
        for y in range(16):
            for x in range(char_width):
                max_w = char_width - x
                for w in range(1, max_w + 1):
                    mask = masks[x][w]
                    max_h = 16 - y
                    if w * max_h <= best_area:
                        continue
                    for h in range(1, max_h + 1):
                        area = w * h
                        if area <= best_area:
                            continue
                        all_one = True
                        for dy in range(h):
                            if (rows_ints[y + dy] & mask) != mask:
                                all_one = False
                                break
                        if all_one:
                            best_area = area
                            best_rect = (x, y, w, h)
        if best_rect is None:
            break
        rects.append(best_rect)
        x, y, w, h = best_rect
        mask = masks[x][w]
        for dy in range(h):
            rows_ints[y + dy] &= ~mask
    return char_width, rects


paths = os.walk("./pictures")
for root, dirs, files in paths:
    for file in files:
        if file.endswith(".png"):
            path_info = f"-- {"=" * 39}\n" + f"-- {os.path.join(root, file).replace("\\", "/").replace("./pictures/", "")}\n" + f"-- {"=" * 39}\n\n"
            try:
                image = pygame.image.load(os.path.join(root, file))
                rows = []
                for y in range(image.get_height()):
                    line = []
                    prev_color = None
                    count = 0
                    for x in range(image.get_width()):
                        color = image.get_at((x, y))
                        col_val = rgbaToUint(color.r, color.g, color.b, color.a)
                        if col_val == prev_color:
                            count += 1
                        else:
                            if prev_color is not None:
                                line.append((prev_color, count))
                            prev_color = col_val
                            count = 1
                    if prev_color is not None:
                        line.append((prev_color, count))
                    row_parts = []
                    for c, cnt in line:
                        if cnt == 1:
                            row_parts.append(str(c))
                        else:
                            row_parts.append(f"{{{c},{cnt}}}")
                    row_str = "{" + ", ".join(row_parts) + "}"
                    rows.append(row_str)
                result += path_info + f"local {file.split('.')[0]} = {{{",\n".join(rows)}}}\n\n"
            except Exception as e:
                print(e)


char_maps = []

langs_path = "./langs.json"
path_info = f"-- {"=" * 39}\n" + f"-- {langs_path.replace('\\', '/').replace('./', '')}\n" + f"-- {"=" * 39}\n\n"
result += path_info + "local langs = {\n"
with open(langs_path, "r", encoding="utf8") as f:
    langs_data = json.load(f)
    for lang, translations in langs_data.items():
        result += f"{lang} = {{\n"
        for key, value in translations.items():
            oct_val = []
            for char in key:
                char = f"{ord(char):04X}"
                if char not in char_maps:
                    char_maps.append(char)
            for char in value:
                char = f"{ord(char):04X}"
                if char not in char_maps:
                    char_maps.append(char)
                oct_val.append(char)
            result += f'{key} = "{"|".join(oct_val)}",\n'
        result += "},\n"
result += "}\n\n"
char_maps.sort()


font_path = "./unifont.hex"
path_info = f"-- {"=" * 39}\n" + f"-- {font_path.replace('\\', '/').replace('./', '')}\n" + f"-- {"=" * 39}\n\n"
font_data = open(font_path, "r").read()
codepoint_to_glyph = {}
for line in font_data.split("\n"):
    if not line:
        continue
    cp_hex, hex_data = line.split(":")
    codepoint_to_glyph[cp_hex] = hex_data


result += "local fonts = {\n"
for char in char_maps:
    glyph = codepoint_to_glyph.get(char)
    if glyph is None:
        glyph = "AAAA00018000000180004A51EA505A51C99E0001800000018000000180005555"
    char_width, rects = glyph_to_rects(glyph)
    rects_str = f"{{{char_width}"
    for rect in rects:
        rects_str += f", {{{rect[0]},{rect[1]},{rect[2]},{rect[3]}}}"
    rects_str += "}"
    result += f'["{char}"] = {rects_str},\n'
result += "}\n\n"


paths = os.walk("./functions")
for root, dirs, files in paths:
    for file in files:
        if file.endswith(".lua"):
            path_info = f"-- {"=" * 39}\n" + f"-- {os.path.join(root, file).replace("\\", "/").replace("./functions/", "")}\n" + f"-- {"=" * 39}\n\n"
            with open(os.path.join(root, file), "r", encoding="utf8") as f:
                result += path_info + f.read() + "\n"


with open("./plugin.lua", "w", encoding="utf8") as f:
    f.write(result)
