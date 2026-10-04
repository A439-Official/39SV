ui = {
    spacing = 4,
    width = 256
}

function ui_main()
    imgui.SetNextWindowSize({ui.width + 16, 0})
    imgui.Begin("39SV")

    if async_is_running() then
        local progress = async_get_progress()
        imgui.ProgressBar(progress, {ui.width, 0})
        if button(i18n("ui_cancel")) then
            async_cancel()
        end
        imgui.Separator()
    end

    imgui.TextDisabled(i18n("ui_version") .. version)
    if button(i18n("ui_current_time") .. "##StartCurrentTime", 64) then
        vars.startTime = state.SelectedHitObjects[1] and state.SelectedHitObjects[1].StartTime or
                             select_time(state.SongTime)
    end
    imgui.SameLine()
    imgui.SetNextItemWidth(ui.width - 64 - ui.spacing)
    _, vars.startTime = imgui.InputFloat("##StartTime", vars.startTime, 1)
    tooltip(i18n("ui_start_time"))
    if button(i18n("ui_current_time") .. "##StopCurrentTime", 64) then
        vars.stopTime = state.SelectedHitObjects[1] and state.SelectedHitObjects[1].StartTime or
                            select_time(state.SongTime)
    end
    imgui.SameLine()
    imgui.SetNextItemWidth(ui.width - 64 - ui.spacing)
    _, vars.stopTime = imgui.InputFloat("##StopTime", vars.stopTime, 1)
    tooltip(i18n("ui_stop_time"))
    imgui.SetNextItemWidth(ui.width)
    imgui.InputText("##Distance", (vars.stopTime - vars.startTime), 1)
    tooltip(i18n("ui_distance"))
    imgui.SetNextItemWidth(ui.width)
    _, vars.mode = imgui.Combo("##Mode", vars.mode, {i18n("ui_create"), i18n("ui_edit"), i18n("ui_options")}, 3)
    imgui.Separator()
    if vars.mode == 0 then
        ui_add()
    elseif vars.mode == 1 then
        ui_edit()
    elseif vars.mode == 2 then
        ui_options()
    end

    draw_overlay()
    imgui.End()

end
