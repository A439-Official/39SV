function ui_edit_teleport()

    imgui.SetNextItemWidth(ui.width)
    _, vars.teleportMode = imgui.Combo("##TeleportMode", vars.teleportMode, {"Below", "Above"}, 2)
    tooltip("Teleport position of selected notes")

    imgui.SetNextItemWidth(ui.width)
    _, vars.teleportDistance = imgui.InputFloat("##Distance", vars.teleportDistance, 1, 100)
    tooltip("Teleport distance")

    imgui.Separator()

    if button("Apply") then
        local rsvs, svs = {}, {}

        if #state.SelectedHitObjects > 0 then
            local times = {}
            for _, note in ipairs(state.SelectedHitObjects) do
                if not_has(times, note.StartTime) then
                    table.insert(times, note.StartTime)
                end
            end
            table.sort(times)
            for i = 1, #times do
                local time = times[i]
                local arsvs, asvs = teleport(time, vars.teleportDistance, vars.teleportMode)
                rsvs = join_tables(rsvs, arsvs)
                svs = join_tables(svs, asvs)
            end
        else
            local arsvs, asvs = teleport(vars.startTime, vars.teleportDistance, vars.teleportMode)
            rsvs = join_tables(rsvs, arsvs)
            svs = join_tables(svs, asvs)
        end

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

function teleport(t, d, m)
    local rsvs, svs = {}, {}
    if m == 0 then
        for _, sv in ipairs(map.ScrollVelocities) do
            if sv.StartTime >= t and sv.StartTime < t + vars.offset then
                table.insert(rsvs, sv)
            end
        end
        table.insert(svs, utils.CreateScrollVelocity(t, (d + get_sv_distance(t, t + vars.offset)) / vars.offset))
        table.insert(svs, utils.CreateScrollVelocity(t + vars.offset, get_sv(t + vars.offset)))
    else
        for _, sv in ipairs(map.ScrollVelocities) do
            if sv.StartTime >= t - vars.offset and sv.StartTime < t then
                table.insert(rsvs, sv)
            end
        end
        table.insert(svs, utils.CreateScrollVelocity(t - vars.offset,
            (d + get_sv_distance(t - vars.offset, t)) / vars.offset))
        table.insert(svs, utils.CreateScrollVelocity(t, get_sv(t)))
    end
    return rsvs, svs
end
