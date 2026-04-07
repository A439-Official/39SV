function ui_edit_scale()
    imgui.SetNextItemWidth(ui.width)
    _, vars.scaleFactor = imgui.InputFloat("##ScaleFactor", vars.scaleFactor, 0.1, 1.0)
    tooltip("Scale factor")

    if button("Apply") then
        local rsvs, svs, ssf = scale(math.floor(vars.startTime), math.floor(vars.stopTime), vars.scaleFactor)

        local batchActions = {}
        if #rsvs > 0 then
            table.insert(batchActions, utils.CreateEditorAction(action_type.RemoveScrollVelocityBatch, rsvs))
        end
        if #svs > 0 then
            table.insert(batchActions, utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svs))
        end
        if #ssf > 0 then
            table.insert(batchActions, utils.CreateEditorAction(action_type.AddScrollSpeedFactorBatch, ssf))
        end
        if #batchActions > 0 then
            actions.PerformBatch(batchActions)
        end
    end
end

function scale(starttime, stoptime, scaleFactor)
    local rsvs = {}
    local svs = {}
    local ssf = {}

    for _, sv in ipairs(map.ScrollVelocities) do
        if sv.StartTime >= starttime and sv.StartTime < stoptime then
            table.insert(rsvs, sv)
            local newMultiplier = sv.Multiplier * scaleFactor
            table.insert(svs, utils.CreateScrollVelocity(sv.StartTime, newMultiplier))
        end
    end

    local hasStart = false
    for _, sv in ipairs(map.ScrollVelocities) do
        if math.abs(sv.StartTime - starttime) < 1 then
            hasStart = true
            break
        end
    end
    if not hasStart then
        local startMultiplier = get_sv(starttime) * scaleFactor
        table.insert(svs, utils.CreateScrollVelocity(starttime, startMultiplier))
    end
    local hasStop = false
    for _, sv in ipairs(map.ScrollVelocities) do
        if math.abs(sv.StartTime - stoptime) < 1 then
            hasStop = true
            break
        end
    end
    if not hasStop then
        local stopMultiplier = get_sv(stoptime)
        table.insert(svs, utils.CreateScrollVelocity(stoptime, stopMultiplier))
    end

    return rsvs, svs, ssf
end
