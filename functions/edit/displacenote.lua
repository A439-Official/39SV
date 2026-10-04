function ui_edit_displacenote()
    imgui.SetNextItemWidth(ui.width)
    _, vars.displaceDistance = imgui.InputInt("##DisplaceDistance", vars.displaceDistance, 1, 10)
    tooltip(i18n("edit_displacenote_distance"))

    imgui.Separator()

    if button(i18n("edit_displacenote_apply")) then
        local times = {}
        for _, note in ipairs(state.SelectedHitObjects) do
            table.insert(times, note.StartTime)
        end
        displacenote(vars.displaceDistance, times)

    end
end

function displacenote(distance, times)
    for _, time in ipairs(times) do
        teleport(time, distance, 1)
        teleport(time, -distance, 0)
    end
end

