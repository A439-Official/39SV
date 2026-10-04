function ui_edit_keep()
    imgui.SetNextItemWidth(ui.width)
    _, vars.keepScale = imgui.InputFloat("##BaseScale", vars.keepScale, 0.25, 0.5)
    tooltip(i18n("edit_keep_scale"))

    if button(i18n("edit_keep_current"), 64) and vars.stopTime > vars.startTime then
        vars.keepBase = ((state.SelectedHitObjects[1] and state.SelectedHitObjects[1].StartTime or state.SongTime) -
                            vars.startTime) / (vars.stopTime - vars.startTime)
    end
    imgui.SameLine()
    imgui.SetNextItemWidth(ui.width - 64 - ui.spacing)
    _, vars.keepBase = imgui.InputFloat("##Base", vars.keepBase, 0.5, 1)
    tooltip(i18n("edit_keep_base"))

    imgui.Separator()

    if button(i18n("edit_keep_apply")) then

        if #state.SelectedHitObjects > 0 then
            local times = {}
            for _, note in ipairs(state.SelectedHitObjects) do
                if not_has(times, note.StartTime) then
                    table.insert(times, note.StartTime)
                end
            end
            table.sort(times)
            for i = 1, #times - 1 do
                keep(times[i], times[i + 1], vars.keepScale, vars.keepBase)
            end
        else
            keep(vars.startTime, vars.stopTime, vars.keepScale, vars.keepBase)
        end
    end
end

function keep(starttime, endtime, basescale, base)
    if starttime == endtime then
        return
    end
    local times = {}
    local offsets = {}
    for _, hitobject in ipairs(map["HitObjects"]) do
        if hitobject.StartTime > starttime and hitobject.StartTime < endtime and state.SelectedScrollGroupId ==
            hitobject.TimingGroup and not_has(times, hitobject.StartTime) then
            offset = get_sv_distance(starttime + (endtime - starttime) * base, hitobject.StartTime) -
                         (hitobject.StartTime - (starttime + (endtime - starttime) * base)) * basescale
            if math.abs(offset) > vars.minIgnoringDistance then
                table.insert(times, hitobject.StartTime)
                table.insert(offsets, offset)
            end
        end
        if hitobject.EndTime > starttime and hitobject.EndTime < endtime and state.SelectedScrollGroupId ==
            hitobject.TimingGroup and not_has(times, hitobject.EndTime) then
            offset = get_sv_distance(starttime + (endtime - starttime) * base, hitobject.EndTime) -
                         (hitobject.EndTime - (starttime + (endtime - starttime) * base)) * basescale
            if math.abs(offset) > vars.minIgnoringDistance then
                table.insert(times, hitobject.EndTime)
                table.insert(offsets, offset)
            end
        end
    end
    for _, time in ipairs(times) do
        teleport(time, -offsets[_], 1)
        teleport(time, offsets[_], 0)
    end
    sdist = get_sv_distance(starttime + (endtime - starttime) * base, starttime) -
                (starttime - (starttime + (endtime - starttime) * base)) * basescale
    if math.abs(sdist) > vars.minIgnoringDistance then
        teleport(starttime, sdist, 0)
    end
    edist = get_sv_distance(endtime, starttime + (endtime - starttime) * base) -
                ((starttime + (endtime - starttime) * base) - endtime) * basescale
    if math.abs(edist) > vars.minIgnoringDistance then
        teleport(endtime, edist, 1)
    end
end
