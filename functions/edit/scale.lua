function ui_edit_scale()
    local modeLabels = {i18n("edit_scale_mode_sv"), i18n("edit_scale_mode_ssf")}
    imgui.SetNextItemWidth(ui.width)
    _, vars.scaleMode = imgui.Combo("##ScaleMode", vars.scaleMode, modeLabels, 2)
    tooltip(i18n("edit_scale_mode_tooltip"))

    imgui.SetNextItemWidth(ui.width)
    _, vars.scaleStart = imgui.InputFloat("##ScaleStart", vars.scaleStart, 0.1, 1.0)
    tooltip(i18n("edit_scale_start"))

    imgui.SetNextItemWidth(ui.width)
    _, vars.scaleEnd = imgui.InputFloat("##ScaleEnd", vars.scaleEnd, 0.1, 1.0)
    tooltip(i18n("edit_scale_end"))

    imgui.SetNextItemWidth(ui.width)
    _, vars.scaleBase = imgui.InputFloat("##ScaleBase", vars.scaleBase, 0.1, 1.0)
    tooltip(i18n("edit_scale_base"))

    if button(i18n("edit_scale_apply")) then
        local starttime, stoptime

        if #state.SelectedHitObjects > 1 then
            starttime = math.floor(state.SelectedHitObjects[1].startTime)
            stoptime = math.floor(state.SelectedHitObjects[#state.SelectedHitObjects].startTime)
        else
            starttime = math.floor(vars.startTime)
            stoptime = math.floor(vars.stopTime)
        end

        if vars.scaleMode == 0 then
            local rsvs, svs = scale_sv(starttime, stoptime, vars.scaleStart, vars.scaleEnd, vars.scaleBase)
            if #rsvs > 0 then
                remove_sv_batch(rsvs)
            end
            if #svs > 0 then
                add_sv_batch(svs)
            end
        else
            local rssfs, ssfs = scale_ssf(starttime, stoptime, vars.scaleStart, vars.scaleEnd, vars.scaleBase)
            if #rssfs > 0 then
                remove_ssf_batch(rssfs)
            end
            if #ssfs > 0 then
                add_ssf_batch(ssfs)
            end
        end
    end
end

function scale_sv(starttime, stoptime, scaleStart, scaleEnd, scaleBase)
    local rsvs = {}
    local svs = {}
    local range = stoptime - starttime

    for _, sv in ipairs(get_all_sv()) do
        if sv.StartTime >= starttime and sv.StartTime < stoptime then
            table.insert(rsvs, sv)
            local progress = 0
            if range > 0 then
                progress = (sv.StartTime - starttime) / range
            end
            local factor = scaleStart + (scaleEnd - scaleStart) * progress
            local newMultiplier = scaleBase + factor * (sv.Multiplier - scaleBase)
            table.insert(svs, utils.CreateScrollVelocity(sv.StartTime, newMultiplier))
        end
    end

    local hasStart = false
    for _, sv in ipairs(get_all_sv()) do
        if math.abs(sv.StartTime - starttime) < 1 then
            hasStart = true
            break
        end
    end
    if not hasStart then
        local progress = 0
        if range > 0 then
            progress = (starttime - starttime) / range
        end
        local factor = scaleBase + scaleStart + (scaleEnd - scaleStart) * progress
        local startMultiplier = get_sv(starttime) * factor
        table.insert(svs, utils.CreateScrollVelocity(starttime, startMultiplier))
    end
    local hasStop = false
    for _, sv in ipairs(get_all_sv()) do
        if math.abs(sv.StartTime - stoptime) < 1 then
            hasStop = true
            break
        end
    end
    if not hasStop then
        local stopMultiplier = get_sv(stoptime)
        table.insert(svs, utils.CreateScrollVelocity(stoptime, stopMultiplier))
    end

    return rsvs, svs
end

function scale_ssf(starttime, stoptime, scaleStart, scaleEnd, scaleBase)
    local rssfs = {}
    local ssfs = {}
    local range = stoptime - starttime

    for _, ssf in ipairs(get_all_ssf()) do
        if ssf.StartTime >= starttime and ssf.StartTime < stoptime then
            table.insert(rssfs, ssf)
            local progress = 0
            if range > 0 then
                progress = (ssf.StartTime - starttime) / range
            end
            local factor = scaleStart + (scaleEnd - scaleStart) * progress
            local newMultiplier = scaleBase + factor * (ssf.Multiplier - scaleBase)
            table.insert(ssfs, utils.CreateScrollSpeedFactor(ssf.StartTime, newMultiplier))
        end
    end

    local hasStart = false
    for _, ssf in ipairs(get_all_ssf()) do
        if math.abs(ssf.StartTime - starttime) < 1 then
            hasStart = true
            break
        end
    end
    if not hasStart then
        local progress = 0
        if range > 0 then
            progress = (starttime - starttime) / range
        end
        local factor = scaleBase + scaleStart + (scaleEnd - scaleStart) * progress
        local startMultiplier = get_ssf(starttime) * factor
        table.insert(ssfs, utils.CreateScrollSpeedFactor(starttime, startMultiplier))
    end
    local hasStop = false
    for _, ssf in ipairs(get_all_ssf()) do
        if math.abs(ssf.StartTime - stoptime) < 1 then
            hasStop = true
            break
        end
    end
    if not hasStop then
        local stopMultiplier = get_ssf(stoptime)
        table.insert(ssfs, utils.CreateScrollSpeedFactor(stoptime, stopMultiplier))
    end

    return rssfs, ssfs
end
