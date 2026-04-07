function ui_edit_copyandpaste()
    imgui.TextWrapped("Copied SVs: " .. tostring(#vars.copiedSVs))
    if button("Copy") then
        local count = copySVs()
    end
    if button("Paste") then
        local batchActions = {}
        local svs = {}
        if #state.SelectedHitObjects > 0 then
            local times = {}
            for _, note in ipairs(state.SelectedHitObjects) do
                if not_has(times, note.StartTime) then
                    table.insert(times, note.StartTime)
                end
            end
            table.sort(times)
            for i = 1, #times do
                local asvs = pasteSVs(times[i])
                svs = join_tables(svs, asvs)
            end
        else
            local asvs = pasteSVs(vars.startTime)
            svs = join_tables(svs, asvs)
        end
        if #svs > 0 then
            table.insert(batchActions, utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svs))
        end
        if #batchActions > 0 then
            actions.PerformBatch(batchActions)
        end
    end
end

function copySVs()
    vars.copiedSVs = {}
    local count = 0
    for _, sv in ipairs(map.ScrollVelocities) do
        if sv.StartTime >= vars.startTime and sv.StartTime < vars.stopTime then
            table.insert(vars.copiedSVs, {
                time = sv.StartTime - vars.startTime,
                multiplier = sv.Multiplier
            })
            count = count + 1
        elseif sv.StartTime >= vars.stopTime then
            break
        end
    end
    return count
end

function pasteSVs(time)
    if #vars.copiedSVs == 0 then
        return {}
    end
    local svs = {}
    for _, cached in ipairs(vars.copiedSVs) do
        local newTime = time + cached.time
        table.insert(svs, utils.CreateScrollVelocity(newTime, cached.multiplier))
    end
    return svs
end

