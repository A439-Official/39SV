function rgbaToUint(r, g, b, a)
    return a * 16 ^ 6 + b * 16 ^ 4 + g * 16 ^ 2 + r
end

function uintToRgba(uint)
    local r = uint % 256
    local g = math.floor(uint / 256) % 256
    local b = math.floor(uint / 65536) % 256
    local a = math.floor(uint / 16777216) % 256
    return r, g, b, a
end

function drawRect(drawlist, x, y, w, h, color)
    drawlist.AddRectFilled({x, y}, {x + w, y + h}, color)
end

function drawCircle(drawlist, x, y, radius, color)
    drawlist.AddCircleFilled({x, y}, radius, color)
end

function drawRing(drawlist, x, y, inner_radius, outer_radius, color)
    drawlist.AddCircle({x, y}, inner_radius + (outer_radius - inner_radius) / 2, color, 0, (outer_radius - inner_radius))
end

function drawLine(drawlist, x1, y1, x2, y2, color, thickness)
    drawlist.AddLine({x1, y1}, {x2, y2}, color, thickness)
end

function getImageSize(texture)
    local rows = #texture
    if rows == 0 then
        return 0, 0
    end
    local width = 0
    for _, item in ipairs(texture[1]) do
        if type(item) == "number" then
            width = width + 1
        else
            width = width + item[2]
        end
    end
    return width, rows
end

function drawImage(drawlist, x, y, w, h, texture, alpha)
    if not alpha then
        alpha = 255
    end
    if not texture then
        return
    end
    local rows = #texture
    local row_height = h / rows
    for yi = 1, rows do
        local row = texture[yi]
        local total_pixels = 0
        for _, item in ipairs(row) do
            if type(item) == "number" then
                total_pixels = total_pixels + 1
            else
                total_pixels = total_pixels + item[2]
            end
        end
        local pixel_width = w / total_pixels
        local current_x = x
        for _, item in ipairs(row) do
            local color_val, count
            if type(item) == "number" then
                color_val = item
                count = 1
            else
                color_val = item[1]
                count = item[2]
            end
            local r, g, b, a = uintToRgba(color_val)
            local final_color = rgbaToUint(r, g, b, math.floor(alpha * a / 255))
            local rect_width = count * pixel_width
            drawRect(drawlist, current_x, y + (yi - 1) * row_height, rect_width, row_height, final_color)
            current_x = current_x + rect_width
        end
    end
end
