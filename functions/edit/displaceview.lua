function ui_edit_displaceview()
    imgui.SetNextItemWidth(ui.width)
    _, vars.displaceDistance = imgui.InputInt("##DisplaceDistance", vars.displaceDistance, 1, 10)
    tooltip("Displace distance")

    imgui.Separator()

    if button("Apply") then
        local rsvs, svs = {}, {}
        local arsvs, asvs = displaceview(math.floor(vars.startTime), math.floor(vars.stopTime), vars.displaceDistance)
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

function displaceview(starttime, stoptime, distance)
    if stoptime - starttime < vars.offset * 2 then
        return {}, {}
    end
    local times = {}
    for _, note in ipairs(map["HitObjects"]) do
        if note.StartTime > starttime + vars.offset and note.StartTime < stoptime - vars.offset and
            state.SelectedScrollGroupId == note.TimingGroup and not_has(times, note.StartTime) then
            table.insert(times, note.StartTime)
        end
    end
    local rsvs = {}
    local svs = {}
    local arsvs, asvs = teleport(starttime, distance, 0)
    rsvs = join_tables(rsvs, arsvs)
    svs = join_tables(svs, asvs)
    local arsvs, asvs = displacenote(starttime, stoptime, -distance, times)
    rsvs = join_tables(rsvs, arsvs)
    svs = join_tables(svs, asvs)
    local arsvs, asvs = teleport(stoptime, -distance, 1)
    rsvs = join_tables(rsvs, arsvs)
    svs = join_tables(svs, asvs)
    return rsvs, svs
end

