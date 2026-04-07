function ui_edit()
    imgui.SetNextItemWidth(ui.width)
    _, vars.editSVMode = imgui.Combo("##EditMode", vars.editSVMode,
        {"Keep Position", "Teleport", "Vibrato", "Displace Note", "Displace View", "Auto Delete", "Line Animation",
         "Copy/Paste SVs", "Scale"}, 9)

    imgui.Separator()

    if vars.editSVMode == 0 then
        ui_edit_keep()
    elseif vars.editSVMode == 1 then
        ui_edit_teleport()
    elseif vars.editSVMode == 2 then
        ui_edit_vibrato()
    elseif vars.editSVMode == 3 then
        ui_edit_displacenote()
    elseif vars.editSVMode == 4 then
        ui_edit_displaceview()
    elseif vars.editSVMode == 5 then
        ui_edit_autodelete()
    elseif vars.editSVMode == 6 then
        ui_edit_lineanim()
    elseif vars.editSVMode == 7 then
        ui_edit_copyandpaste()
    elseif vars.editSVMode == 8 then
        ui_edit_scale()
    end
end
