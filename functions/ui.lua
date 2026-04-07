ui = {
    spacing = 4,
    width = 256
}

function ui_main()
    imgui.SetNextWindowSize({ui.width + 16, 0})
    imgui.Begin("39SV")
    imgui.TextDisabled("Version: " .. version)
    if button("Start Time", 64) then
        vars.startTime = state.SelectedHitObjects[1] and state.SelectedHitObjects[1].StartTime or
                             select_time(state.SongTime)
    end
    imgui.SameLine()
    imgui.SetNextItemWidth(ui.width - 64 - ui.spacing)
    _, vars.startTime = imgui.InputFloat("##StartTime", vars.startTime, 1)
    if button("Stop Time", 64) then
        vars.stopTime = state.SelectedHitObjects[1] and state.SelectedHitObjects[1].StartTime or
                            select_time(state.SongTime)
    end
    imgui.SameLine()
    imgui.SetNextItemWidth(ui.width - 64 - ui.spacing)
    _, vars.stopTime = imgui.InputFloat("##StopTime", vars.stopTime, 1)
    imgui.SetNextItemWidth(ui.width)
    imgui.InputText("##Distance", (vars.stopTime - vars.startTime), 1)
    tooltip("Distance between start and stop time")
    imgui.SetNextItemWidth(ui.width)
    _, vars.mode = imgui.Combo("##Mode", vars.mode, {"Create", "Edit", "Options"}, 3)
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
