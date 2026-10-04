function ui_edit_alpha()
    imgui.SetNextItemWidth(ui.width)
    _, vars.alphaDist = imgui.InputFloat("##AlphaDistance", vars.alphaDist)
    tooltip(i18n("edit_alpha_distance"))

    imgui.Text(i18n("edit_alpha_fps_label") .. math.ceil(get_bpm(vars.startTime) / 60 * vars.alphaDist * 100) / 100)

    imgui.Separator()

    imgui.SetNextItemWidth(ui.width)
    _, vars.alphaDistance1 = imgui.InputText("##Distance1", vars.alphaDistance1, 32)

    imgui.SetNextItemWidth(ui.width)
    _, vars.alphaDistance2 = imgui.InputText("##Distance2", vars.alphaDistance2, 32)

    imgui.Separator()

    if button(i18n("edit_alpha_apply")) then
        alpha(math.floor(vars.startTime), math.floor(vars.stopTime), vars.alphaDist, vars.alphaDistance1,
            vars.alphaDistance2)

    end
end

function alpha(starttime, stoptime, alphadist, distance1, distance2)

    local times = {}
    local bpm = nil

    for _, timepoint in ipairs(map["TimingPoints"]) do
        if timepoint["StartTime"] <= starttime then
            bpm = timepoint
        else
            break
        end
    end

    if bpm == nil then
        if #map["TimingPoints"] > 0 then
            bpm = map["TimingPoints"][1]
        else
            bpm = utils.CreateTimingPoint(0, 100)
        end
    end

    while bpm["StartTime"] > starttime do
        bpm = utils.CreateTimingPoint(bpm["StartTime"] - 60000 / bpm["Bpm"] / alphadist, bpm["Bpm"])
    end

    local time = bpm["StartTime"]

    while time <= starttime + vars.offset do
        time = time + 60000 / bpm["Bpm"] / alphadist
    end

    while time < stoptime - vars.offset do
        table.insert(times, select_time(time))
        time = time + 60000 / bpm["Bpm"] / alphadist
    end

    table.insert(times, stoptime)

    local lasttime = starttime
    for idx, time in ipairs(times) do

        local progress = (idx - 1) / math.max(#times - 1, 1)

        local splittime = lasttime + (time - lasttime) * (1 - progress)

        d1 = paramNumber(distance1, progress)
        d2 = paramNumber(distance2, progress)

        if math.abs(d1) > 1 then
            displaceview(lasttime, splittime, d1)
        end

        if math.abs(d2) > 1 then
            displaceview(splittime, time, d2)
        end

        lasttime = time
    end

end
