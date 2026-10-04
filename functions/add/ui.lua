function ui_add()
    imgui.SetNextItemWidth(ui.width)
    _, vars.creatSVMode = imgui.Combo("##CreatSVType", vars.creatSVMode,
        {i18n("add_ui_linear"), i18n("add_ui_bezier"), i18n("add_ui_bezier_old"), i18n("add_ui_shutter"),
         i18n("add_ui_measureline"), i18n("add_ui_oscillation")}, 6)

    imgui.Separator()

    if not (vars.creatSVMode == 3 or vars.creatSVMode == 4 or vars.creatSVMode == 6) then
        imgui.SetNextItemWidth(ui.width)
        _, vars.creatSVCount = imgui.InputInt("##CreatSVCount", vars.creatSVCount, 8, 10)
        tooltip(i18n("add_ui_count"))
    end

    imgui.SetNextItemWidth(ui.width)
    _, vars.finalSVMode = imgui.Combo("##FinalSVMode", vars.finalSVMode, {i18n("add_ui_skip"), i18n("add_ui_default"),
                                                                          i18n("add_ui_normal"), i18n("add_ui_custom")},
        4)
    tooltip(i18n("add_ui_final"))
    if vars.finalSVMode == 3 then
        imgui.SetNextItemWidth(ui.width)
        _, vars.finalSV = imgui.InputFloat("##FinalSVValue", vars.finalSV, 0.5, 1)
    end

    _, vars.addSSF = imgui.Checkbox(i18n("add_ui_scroll_speed_factor"), vars.addSSF)

    imgui.Separator()

    if vars.creatSVMode == 0 then
        ui_add_linear()
    elseif vars.creatSVMode == 1 then
        ui_add_bezier()
    elseif vars.creatSVMode == 2 then
        ui_add_bezier_old()
    elseif vars.creatSVMode == 3 then
        ui_add_shutter()
    elseif vars.creatSVMode == 4 then
        ui_add_measureline()
    elseif vars.creatSVMode == 5 then
        ui_add_oscillation()
    end
end

