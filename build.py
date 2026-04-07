import os
import datetime
import pygame

version = datetime.datetime.now().strftime("%y.%m.%d+%H%M%S")
result = f'version = "{version}"\n\n'


def rgbaToUint(r, g, b, a):
    return (a << 24) | (b << 16) | (g << 8) | r


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

paths = os.walk("./functions")
for root, dirs, files in paths:
    for file in files:
        if file.endswith(".lua"):
            path_info = f"-- {"=" * 39}\n" + f"-- {os.path.join(root, file).replace("\\", "/").replace("./functions/", "")}\n" + f"-- {"=" * 39}\n\n"
            with open(os.path.join(root, file), "r", encoding="utf8") as f:
                result += path_info + f.read() + "\n"

with open("./plugin.lua", "w", encoding="utf8") as f:
    f.write(result)
