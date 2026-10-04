import os
import datetime
import pygame
import json
import math


def py2lua(var_name, data, indent="    "):
    def encode_string(s):
        return '"' + (s.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t")) + '"'

    def is_flat(obj):
        if isinstance(obj, (list, tuple)):
            return len(obj) <= 8 and all(not isinstance(x, (list, tuple, dict)) for x in obj)
        if isinstance(obj, dict):
            return len(obj) <= 8 and all(not isinstance(v, (list, tuple, dict)) for v in obj.values())
        return True

    def encode(obj, level=0):
        if obj is None:
            return "nil"
        if isinstance(obj, bool):
            return "true" if obj else "false"
        if isinstance(obj, (int, float)):
            if isinstance(obj, float):
                if math.isnan(obj) or math.isinf(obj):
                    raise ValueError("Lua 不支持 NaN 或 Infinity")
            return repr(obj)
        if isinstance(obj, str):
            return encode_string(obj)
        if isinstance(obj, (list, tuple)):
            if not obj:
                return "{}"
            if len(obj) == 1 and isinstance(obj[0], (list, tuple)) and is_flat(obj[0]):
                return "{ " + encode(obj[0], level) + " }"
            if is_flat(obj):
                return "{ " + ", ".join(encode(v, level) for v in obj) + " }"
            inner = ",\n".join(indent * (level + 1) + encode(v, level + 1) for v in obj)
            return "{\n" + inner + "\n" + indent * level + "}"
        if isinstance(obj, dict):
            if not obj:
                return "{}"
            items = []
            for k, v in obj.items():
                if isinstance(k, str) and k.isidentifier():
                    key = k
                else:
                    key = "[" + encode(k, level + 1) + "]"
                items.append((key, v))
            if is_flat(obj):
                return "{ " + ", ".join(f"{k} = {encode(v, level)}" for k, v in items) + " }"
            inner = ",\n".join(indent * (level + 1) + f"{k} = {encode(v, level + 1)}" for k, v in items)
            return "{\n" + inner + "\n" + indent * level + "}"
        raise TypeError(f"不支持类型: {type(obj).__name__}")

    return f"{var_name} = {encode(data)}\n"


version = datetime.datetime.now().strftime("%y.%m.%d+%H%M%S")
plugin = py2lua("version", version) + "\n"


def rgbaToUint(r, g, b, a):
    return (a << 24) | (b << 16) | (g << 8) | r


paths = os.walk("./pictures")
for root, dirs, files in paths:
    for file in files:
        if file.endswith(".png"):
            path_info = f"-- {"=" * 39}\n" + f"-- {os.path.join(root, file).replace("\\", "/").replace("./pictures/", "")}\n" + f"-- {"=" * 39}\n\n"
            try:
                image = pygame.image.load(os.path.join(root, file))
                rows_list = []
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
                                if count == 1:
                                    line.append(prev_color)
                                else:
                                    line.append([prev_color, count])
                            prev_color = col_val
                            count = 1
                    if prev_color is not None:
                        if count == 1:
                            line.append(prev_color)
                        else:
                            line.append([prev_color, count])
                    rows_list.append(line)
                name = file.split(".")[0]
                plugin += path_info + py2lua(f"{name}", rows_list) + "\n"
            except Exception as e:
                print(e)


fonts = {}
char_maps = []

langs_path = "./langs.json"
path_info = f"-- {"=" * 39}\n" + f"-- {langs_path.replace('\\', '/').replace('./', '')}\n" + f"-- {"=" * 39}\n\n"
plugin += path_info
with open(langs_path, "r", encoding="utf8") as f:
    langs_data = json.load(f)
    langs_dict = {}
    for lang, translations in langs_data.items():
        langs_dict[lang] = {}
        for key, value in translations.items():
            for ch in key:
                code = f"{ord(ch):04X}"
                if code not in char_maps:
                    char_maps.append(code)
            oct_vals = []
            for ch in value:
                code = f"{ord(ch):04X}"
                if code not in char_maps:
                    char_maps.append(code)
                oct_vals.append(code)
            langs_dict[lang][key] = value
    plugin += py2lua("langs", langs_dict) + "\n\n"
    char_maps.sort()


paths = os.walk("./functions")
for root, dirs, files in paths:
    for file in files:
        if file.endswith(".lua"):
            path_info = f"-- {"=" * 39}\n" + f"-- {os.path.join(root, file).replace("\\", "/").replace("./functions/", "")}\n" + f"-- {"=" * 39}\n\n"
            with open(os.path.join(root, file), "r", encoding="utf8") as f:
                plugin += path_info + f.read() + "\n"


with open("./plugin.lua", "w", encoding="utf8") as f:
    f.write(plugin)
