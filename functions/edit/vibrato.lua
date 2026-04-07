function ui_edit_vibrato()
    imgui.SetNextItemWidth(ui.width)
    _, vars.vibDist = imgui.InputInt("Vibrato Distance", vars.vibDist, 8, 10)
    tooltip("Distance between vibrato points")

    imgui.Separator()

    imgui.Text("Vibrato Items:")
    for idx = 1, #vars.vibItems do
        local item = vars.vibItems[idx]

        imgui.SetNextItemWidth((ui.width - 32 - ui.spacing * 2) / 2)
        local _, newParam = imgui.InputText("##Param_" .. idx .. "_sv", item.sv, 32)
        if _ then
            item.sv = newParam
        end
        tooltip("SV")
        imgui.SameLine()
        imgui.SetNextItemWidth((ui.width - 32 - ui.spacing * 2) / 2)
        local _, newParam = imgui.InputText("##Param_" .. idx .. "_ssf", item.ssf, 32)
        if _ then
            item.ssf = newParam
        end
        tooltip("SFF")

        imgui.SameLine()

        if button("X##Remove_" .. idx, 32) then
            table.remove(vars.vibItems, idx)
            break
        end

        imgui.Spacing()
    end

    if button("+") then
        table.insert(vars.vibItems, {
            sv = "0",
            ssf = "1"
        })
    end

    imgui.Separator()

    if button("Apply Vibrato") then
        local arsvs, asvs, assf = vibrato(math.floor(vars.startTime), math.floor(vars.stopTime), vars.vibDist,
            vars.vibItems)

        local batchActions = {}
        if #arsvs > 0 then
            table.insert(batchActions, utils.CreateEditorAction(action_type.RemoveScrollVelocityBatch, arsvs))
        end
        if #asvs > 0 then
            table.insert(batchActions, utils.CreateEditorAction(action_type.AddScrollVelocityBatch, asvs))
        end
        if #assf > 0 then
            table.insert(batchActions, utils.CreateEditorAction(action_type.AddScrollSpeedFactorBatch, assf))
        end
        if #batchActions > 0 then
            actions.PerformBatch(batchActions)
        end
    end
end

function vibrato(starttime, stoptime, vibdist, vibItems)
    local svs = {}
    local rsvs = {}
    local ssf = {}

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
        bpm = utils.CreateTimingPoint(bpm["StartTime"] - 60000 / bpm["Bpm"] / vibdist, bpm["Bpm"])
    end

    local time = bpm["StartTime"]
    while time <= starttime + vars.offset do
        time = time + 60000 / bpm["Bpm"] / vibdist
    end
    while time < stoptime - vars.offset do
        table.insert(times, select_time(time))
        time = time + 60000 / bpm["Bpm"] / vibdist
    end
    table.insert(times, stoptime)

    local lasttime = starttime
    local lastssf = get_ssf(starttime)
    for _, time in ipairs(times) do
        local t = (lasttime - starttime) / (stoptime - starttime)
        local svvibdistance = paramNumber(vibItems[(_ + 1) % #vibItems + 1].sv,
            (lasttime - starttime) / (stoptime - starttime))
        local ssfvibdistance = paramNumber(vibItems[(_ + 1) % #vibItems + 1].ssf,
            (lasttime - starttime) / (stoptime - starttime))
        if math.abs(svvibdistance) > vars.minIgnoringDistance then
            local arsvs, asvs = displaceview(lasttime, time, svvibdistance)
            rsvs = join_tables(rsvs, arsvs)
            svs = join_tables(svs, asvs)
        end
        if math.abs(ssfvibdistance - lastssf) > 0 then
            if #ssf == 0 then
                table.insert(ssf, utils.CreateScrollSpeedFactor(starttime, get_ssf(starttime)))
            end
            table.insert(ssf, utils.CreateScrollSpeedFactor(lasttime, ssfvibdistance))
            table.insert(ssf, utils.CreateScrollSpeedFactor(time, ssfvibdistance))
        end
        lasttime = time
        lastssf = ssfvibdistance
    end
    if #ssf > 0 then
        table.insert(ssf, utils.CreateScrollSpeedFactor(stoptime, get_ssf(stoptime)))
    end
    return rsvs, svs, ssf
end
