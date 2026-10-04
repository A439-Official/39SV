function ui_edit_displaceview()
    imgui.SetNextItemWidth(ui.width)
    _, vars.displaceDistance = imgui.InputInt("##DisplaceDistance", vars.displaceDistance, 1, 10)
    tooltip(i18n("edit_displaceview_distance"))

    imgui.Separator()

    if button(i18n("edit_displaceview_apply")) then
        displaceview(math.floor(vars.startTime), math.floor(vars.stopTime), vars.displaceDistance)
    end
end

function displaceview(starttime, stoptime, distance)
    if math.abs(stoptime - starttime) < 1 then
        return
    end
    local times = {}
    for _, note in ipairs(map["HitObjects"]) do
        if note.StartTime > starttime + vars.offset and note.StartTime < stoptime - vars.offset and
            state.SelectedScrollGroupId == note.TimingGroup and not_has(times, note.StartTime) then
            table.insert(times, note.StartTime)
        end
        if note.EndTime > starttime + vars.offset and note.EndTime < stoptime - vars.offset and
            state.SelectedScrollGroupId == note.TimingGroup and not_has(times, note.EndTime) then
            table.insert(times, note.EndTime)
        end
        if note.StartTime >= stoptime - vars.offset then
            break
        end
    end
    teleport(starttime, distance, 0)
    if (#times > 0) then
        displacenote(-distance, times)
    end
    teleport(stoptime, -distance, 1)
end

