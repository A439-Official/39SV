function tooltip(text)
    if imgui.IsItemHovered() then
        imgui.SetTooltip(text)
    end
end

function setValue()
    imgui.SetNextItemWidth((ui.width - ui.spacing) / 2)
    _, vars.start = imgui.InputFloat("##StartValue", vars.start, 0.5, 1)
    tooltip("Start value")
    imgui.SameLine()
    imgui.SetNextItemWidth((ui.width - ui.spacing) / 2)
    _, vars.stop = imgui.InputFloat("##StopValue", vars.stop, 0.5, 1)
    tooltip("Stop value")
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
