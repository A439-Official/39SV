function tooltip(text)
    if imgui.IsItemHovered() then
        local drawlist = imgui.GetOverlayDrawList()
        local mousePos = imgui.GetMousePos()

        local x = mousePos[1] + 4
        local y = mousePos[2] + -16

        local h = 16
        local w = getTextWidth(i18n(text), h)

        drawRect(drawlist, x - 2, y - 2, w + 4, h + 4, rgbaToUint(0, 0, 0, 127))
        drawText(drawlist, i18n(text), x, y, rgbaToUint(255, 255, 255, 255), h)

    end
end

function ui_value()
    imgui.SetNextItemWidth((ui.width - ui.spacing * 2) / 3)
    _, vars.start = imgui.InputFloat("##StartValue", vars.start)
    tooltip("ui_value_start")
    imgui.SameLine()
    imgui.SetNextItemWidth((ui.width - ui.spacing * 2) / 3)
    _, vars.stop = imgui.InputFloat("##StopValue", vars.stop)
    tooltip("ui_value_stop")
    imgui.SameLine()
    if button("Swap##SwapValues", (ui.width - ui.spacing * 2) / 3) then
        vars.start, vars.stop = vars.stop, vars.start
    end
end

function button(text, width)
    if text == nil then
        text = ""
    end
    if width == nil then
        width = ui.width
    end
    return imgui.Button(text, {width, 0})
end
