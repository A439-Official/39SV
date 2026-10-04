function ui_add_measureline()
    imgui.SetNextItemWidth(ui.width)
    _, vars.measurelineBeat = imgui.InputInt("##MeasurelineBeat", vars.measurelineBeat, 1, 2)
    tooltip(i18n("add_measureline_beat"))

    if vars.measurelineBeat < 1 then
        vars.measurelineBeat = 1
    end

    imgui.Separator()

    if button(i18n("add_measureline_apply")) then
        add_measureline(math.floor(vars.startTime), math.floor(vars.stopTime), vars.measurelineBeat)
    end
end

function add_measureline(starttime, stoptime, beatCount)
    if starttime >= stoptime or beatCount < 1 then
        return
    end

    local bpm = nil
    for _, timepoint in ipairs(get_all_tp()) do
        if timepoint["StartTime"] <= starttime then
            bpm = timepoint
        else
            break
        end
    end
    if bpm == nil then
        if #get_all_tp() > 0 then
            bpm = get_all_tp()[1]
        else
            return
        end
    end

    local tps = {}
    local beatInterval = 60000 / bpm["Bpm"]
    local measureInterval = beatInterval * beatCount

    local time = bpm["StartTime"]
    while time <= starttime do
        time = time + beatInterval * beatCount
    end
    local beatsFromBpm = math.floor((time - bpm["StartTime"]) / beatInterval)
    local remainder = beatsFromBpm % beatCount
    if remainder > 0 then
        time = time - beatInterval * remainder
    end
    while time <= starttime do
        time = time + measureInterval
    end

    while time < stoptime do
        bpmtime = math.floor(time)
        nearesttime = 1
        for _, hitobject in ipairs(map["HitObjects"]) do
            if math.abs(hitobject.StartTime - time) <= nearesttime then
                bpmtime = hitobject.StartTime
                nearesttime = math.abs(hitobject.StartTime - time)
            end
        end
        table.insert(tps, utils.CreateTimingPoint(math.floor(bpmtime), get_bpm(time)))
        time = time + measureInterval
    end

    if #tps > 0 then
        add_tp_batch(tps)
    end
end
