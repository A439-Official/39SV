function ui_edit()
    imgui.SetNextItemWidth(ui.width)
    _, vars.editSVMode = imgui.Combo("##EditMode", vars.editSVMode,
        {i18n("edit_ui_keep_position"), i18n("edit_ui_teleport"), i18n("edit_ui_vibrato"), i18n("edit_ui_alpha"),
         i18n("edit_ui_displace_note"), i18n("edit_ui_displace_view"), i18n("edit_ui_auto_delete"),
         i18n("edit_ui_line_animation"), i18n("edit_ui_copy_paste"), i18n("edit_ui_scale"),
         i18n("edit_ui_reset_offset")}, 11)

    imgui.Separator()

    if vars.editSVMode == 0 then
        ui_edit_keep()
    elseif vars.editSVMode == 1 then
        ui_edit_teleport()
    elseif vars.editSVMode == 2 then
        ui_edit_vibrato()
    elseif vars.editSVMode == 3 then
        ui_edit_alpha()
    elseif vars.editSVMode == 4 then
        ui_edit_displacenote()
    elseif vars.editSVMode == 5 then
        ui_edit_displaceview()
    elseif vars.editSVMode == 6 then
        ui_edit_autodelete()
    elseif vars.editSVMode == 7 then
        ui_edit_lineanim()
    elseif vars.editSVMode == 8 then
        ui_edit_copyandpaste()
    elseif vars.editSVMode == 9 then
        ui_edit_scale()
    elseif vars.editSVMode == 10 then
        ui_edit_resetoffset()
    end
end
