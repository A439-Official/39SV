function ui_edit_vibrato()
    imgui.SetNextItemWidth(ui.width)
    _, vars.vibDist = imgui.InputFloat("##VibratoDistance", vars.vibDist)
    tooltip(i18n("edit_vibrato_distance"))
    local bpm = get_bpm(vars.startTime)
    imgui.SetNextItemWidth(ui.width)
    local _, newFPS = imgui.InputFloat("##VibratoFPS", vars.vibDist * bpm / 60)
    if _ then
        vars.vibDist = newFPS / bpm * 60
    end
    tooltip(i18n("edit_vibrato_fps"))

    imgui.Separator()

    imgui.Text(i18n("edit_vibrato_items"))
    for idx = 1, #vars.vibItems do
        local item = vars.vibItems[idx]

        imgui.SetNextItemWidth((ui.width - 32 - ui.spacing * 2) / 2)
        local _, newParam = imgui.InputText("##Param_" .. idx .. "_sv", item.sv, 32)
        if _ then
            item.sv = newParam
        end
        tooltip(i18n("edit_vibrato_sv"))
        imgui.SameLine()
        imgui.SetNextItemWidth((ui.width - 32 - ui.spacing * 2) / 2)
        local _, newParam = imgui.InputText("##Param_" .. idx .. "_ssf", item.ssf, 32)
        if _ then
            item.ssf = newParam
        end
        tooltip(i18n("edit_vibrato_sff"))

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

    if button(i18n("edit_vibrato_apply")) then
        vibrato(math.floor(vars.startTime), math.floor(vars.stopTime), vars.vibDist, vars.vibItems)
    end
end

function vibrato(starttime, stoptime, vibdist, vibItems)
    local times = {}
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
    while bpm["StartTime"] > starttime do
        bpm = utils.CreateTimingPoint(bpm["StartTime"] - 60000 / bpm["Bpm"] / vibdist, bpm["Bpm"])
    end

    local time = bpm["StartTime"]
    local lasttime = starttime
    while time <= starttime do
        time = time + 60000 / bpm["Bpm"] / vibdist
    end
    while time < stoptime do
        if time - lasttime > 0 then
            table.insert(times, select_time(time))
        end
        lasttime = time
        time = time + 60000 / bpm["Bpm"] / vibdist
    end
    table.insert(times, stoptime)

    local ambient = get_ssf(starttime)
    local base = ambient
    local lasttime = starttime
    local enablessf = false
    local mult = {}
    for i, time in ipairs(times) do
        local item = vibItems[i % #vibItems + 1]
        local t = (lasttime - starttime) / (stoptime - starttime)
        local svvibdistance = paramNumber(item.sv, t)
        if math.abs(svvibdistance) > 1 then
            displaceview(lasttime, time, svvibdistance)
        end
        if item.ssf ~= "" and base ~= 0 then
            enablessf = true
            local factor = paramNumber(item.ssf, t) / base
            if math.abs(factor - 1) > 2 ^ -6 then
                mult_ssf(lasttime, time, factor)
            end
        end
        lasttime = time
    end

end
