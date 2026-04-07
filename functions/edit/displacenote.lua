function ui_edit_displacenote()
    imgui.SetNextItemWidth(ui.width)
    _, vars.displaceDistance = imgui.InputInt("##DisplaceDistance", vars.displaceDistance, 1, 10)
    tooltip("Displace distance")

    imgui.Separator()

    if button("Apply") then
        local rsvs, svs = {}, {}
        local times = {}
        for _, note in ipairs(state.SelectedHitObjects) do
            table.insert(times, note.StartTime)
        end
        local arsvs, asvs = displacenote(math.floor(vars.startTime), math.floor(vars.stopTime), vars.displaceDistance,
            times)
        rsvs = join_tables(rsvs, arsvs)
        svs = join_tables(svs, asvs)

        local batchActions = {}
        if #rsvs > 0 then
            table.insert(batchActions, utils.CreateEditorAction(action_type.RemoveScrollVelocityBatch, rsvs))
        end
        if #svs > 0 then
            table.insert(batchActions, utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svs))
        end
        if #batchActions > 0 then
            actions.PerformBatch(batchActions)
        end
    end
end

function displacenote(starttime, stoptime, distance, times)
    local rsvs = {}
    local svs = {}
    for _, time in ipairs(times) do
        local arsvs, asvs = teleport(time, distance, 1)
        rsvs = join_tables(rsvs, arsvs)
        svs = join_tables(svs, asvs)
        local arsvs, asvs = teleport(time, -distance, 0)
        rsvs = join_tables(rsvs, arsvs)
        svs = join_tables(svs, asvs)
    end
    return rsvs, svs
end

