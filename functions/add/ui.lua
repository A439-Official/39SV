function ui_add()
    imgui.SetNextItemWidth(ui.width)
    _, vars.creatSVMode = imgui.Combo("##CreatSVType", vars.creatSVMode, {"Linear", "Bezier"}, 2)

    imgui.Separator()

    imgui.SetNextItemWidth(ui.width)
    _, vars.creatSVCount = imgui.InputInt("##CreatSVCount", vars.creatSVCount, 8, 10)
    tooltip("Number of SVs")

    imgui.SetNextItemWidth(ui.width)
    _, vars.finalSVMode = imgui.Combo("##FinalSVMode", vars.finalSVMode, {"Skip", "Default", "Normal", "Custom"}, 4)
    tooltip("Final SV mode")
    if vars.finalSVMode == 3 then
        imgui.SetNextItemWidth(ui.width)
        _, vars.finalSV = imgui.InputFloat("##FinalSVValue", vars.finalSV, 0.5, 1)
    end

    _, vars.addSSF = imgui.Checkbox("Scroll Speed Factor", vars.addSSF)

    imgui.Separator()

    if vars.creatSVMode == 0 then
        ui_add_linear()
    elseif vars.creatSVMode == 1 then
        ui_add_bezier()
    end
end

