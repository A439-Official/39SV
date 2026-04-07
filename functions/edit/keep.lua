function ui_edit_keep()
    imgui.SetNextItemWidth(ui.width)
    _, vars.keepScale = imgui.InputFloat("##BaseScale", vars.keepScale, 0.25, 0.5)
    tooltip("Scale SVs to range")

    if button("Current", 64) and vars.stopTime > vars.startTime then
        vars.keepScale = ((state.SelectedHitObjects[1] and state.SelectedHitObjects[1].StartTime or state.SongTime) -
                             vars.startTime) / (vars.stopTime - vars.startTime)
    end
    imgui.SameLine()
    imgui.SetNextItemWidth(ui.width - 64 - ui.spacing)
    _, vars.keepBaseTime = imgui.InputFloat("##BaseTime", vars.keepBaseTime, 0.5, 1)
    tooltip("Base time for SVs")

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
            for i = 1, #times - 1 do
                local arsvs, asvs = keep(times[i], times[i + 1], vars.keepScale, vars.keepBaseTime)
                rsvs = join_tables(rsvs, arsvs)
                svs = join_tables(svs, asvs)
            end
        else
            local arsvs, asvs = keep(vars.startTime, vars.stopTime, vars.keepScale, vars.keepBaseTime)
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

function keep(starttime, endtime, basescale, base)
    if starttime == endtime then
        return
    end
    local hitobjects = {}
    for _, hitobject in ipairs(map["HitObjects"]) do
        if hitobject["StartTime"] > starttime and hitobject["StartTime"] < endtime and state.SelectedScrollGroupId ==
            hitobject.TimingGroup and not_has(hitobjects, hitobject) then
            offset = get_sv_distance(starttime + (endtime - starttime) * base, hitobject["StartTime"]) -
                         (hitobject["StartTime"] - (starttime + (endtime - starttime) * base)) * basescale
            if math.abs(offset) > vars.minIgnoringDistance then
                table.insert(hitobjects, {hitobject["StartTime"], offset})
            end
        end
        if hitobject["EndTime"] > starttime and hitobject["EndTime"] < endtime and state.SelectedScrollGroupId ==
            hitobject.TimingGroup and not_has(hitobjects, hitobject) then
            offset = get_sv_distance(starttime + (endtime - starttime) * base, hitobject["EndTime"]) -
                         (hitobject["EndTime"] - (starttime + (endtime - starttime) * base)) * basescale
            if math.abs(offset) > vars.minIgnoringDistance then
                table.insert(hitobjects, {hitobject["EndTime"], offset})
            end
        end
    end
    local rsvs, svs = {}, {}
    for _, hitobject in ipairs(hitobjects) do
        local arsvs, asvs = teleport(hitobject[1], -hitobject[2], 1)
        rsvs = join_tables(rsvs, arsvs)
        svs = join_tables(svs, asvs)
        local arsvs, asvs = teleport(hitobject[1], hitobject[2], 0)
        rsvs = join_tables(rsvs, arsvs)
        svs = join_tables(svs, asvs)
    end
    sdist = get_sv_distance(starttime + (endtime - starttime) * base, starttime) -
                (starttime - (starttime + (endtime - starttime) * base)) * basescale
    if math.abs(sdist) > vars.minIgnoringDistance then
        local arsvs, asvs = teleport(starttime, sdist, 0)
        rsvs = join_tables(rsvs, arsvs)
        svs = join_tables(svs, asvs)
    end
    edist = get_sv_distance(endtime, starttime + (endtime - starttime) * base) -
                ((starttime + (endtime - starttime) * base) - endtime) * basescale
    if math.abs(edist) > vars.minIgnoringDistance then
        local arsvs, asvs = teleport(endtime, edist, 1)
        rsvs = join_tables(rsvs, arsvs)
        svs = join_tables(svs, asvs)
    end
    return rsvs, svs
end
