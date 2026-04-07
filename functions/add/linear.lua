function ui_add_linear()
    setValue()

    imgui.Separator()

    if button("Add") then
        local batchActions = {}
        local svs, ssfs = {}, {}
        if #state.SelectedHitObjects > 1 then
            local times = {}
            for _, note in ipairs(state.SelectedHitObjects) do
                if not_has(times, note.StartTime) then
                    table.insert(times, note.StartTime)
                end
            end
            table.sort(times)
            for i = 1, #times - 1 do
                if vars.addSSF then
                    local assfs = add_linear_ssf(times[i], times[i + 1], vars.creatSVCount, vars.start, vars.stop,
                        i == #times - 1 and vars.finalSVMode or 0, vars.finalSV)
                    ssfs = join_tables(ssfs, assfs, false)
                else
                    local asvs = add_linear_sv(times[i], times[i + 1], vars.creatSVCount, vars.start, vars.stop,
                        i == #times - 1 and vars.finalSVMode or 0, vars.finalSV)
                    svs = join_tables(svs, asvs)
                end
            end
        else
            if vars.addSSF then
                local assfs = add_linear_ssf(vars.startTime, vars.stopTime, vars.creatSVCount, vars.start, vars.stop,
                    vars.finalSVMode, vars.finalSV)
                ssfs = join_tables(ssfs, assfs, false)
            else
                local asvs = add_linear_sv(vars.startTime, vars.stopTime, vars.creatSVCount, vars.start, vars.stop,
                    vars.finalSVMode, vars.finalSV)
                svs = join_tables(svs, asvs)
            end
        end
        if #svs > 0 then
            table.insert(batchActions, utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svs))
        end
        if #ssfs > 0 then
            table.insert(batchActions, utils.CreateEditorAction(action_type.AddScrollSpeedFactorBatch, ssfs))
        end
        if #batchActions > 0 then
            actions.PerformBatch(batchActions)
        end
    end
end

function add_linear_sv(starttime, endtime, count, start, stop, fmode, finalSV)
    local svs = {}
    if starttime >= endtime or count == 0 then
        return {}
    end
    for i = 0, count - 1 do
        local t = select_time(starttime + (i / count) * (endtime - starttime))
        local s = start + (i + 0.5) / count * (stop - start)
        table.insert(svs, utils.CreateScrollVelocity(t, s))
    end
    if fmode > 0 then
        if fmode == 1 then
            table.insert(svs, utils.CreateScrollVelocity(endtime, get_sv(endtime)))
        elseif fmode == 2 then
            table.insert(svs, utils.CreateScrollVelocity(endtime, stop))
        elseif fmode == 3 then
            table.insert(svs, utils.CreateScrollVelocity(endtime, finalSV))
        end
    end
    return svs
end

function add_linear_ssf(starttime, endtime, count, start, stop, fmode, finalSV)
    local ssfs = {}
    if starttime >= endtime or count == 0 then
        return {}
    end
    table.insert(ssfs, utils.CreateScrollSpeedFactor(starttime, get_ssf(starttime)))
    for i = 0, count - 1 do
        local t = select_time(starttime + (i / count) * (endtime - starttime))
        local s = start + (i + 0.5) / count * (stop - start)
        table.insert(ssfs, utils.CreateScrollSpeedFactor(t, s))
    end
    if fmode > 0 then
        table.insert(ssfs, utils.CreateScrollSpeedFactor(endtime, stop))
        if fmode == 1 then
            table.insert(ssfs, utils.CreateScrollSpeedFactor(endtime, get_ssf(endtime)))
        elseif fmode == 2 then
            table.insert(ssfs, utils.CreateScrollSpeedFactor(endtime, stop))
        elseif fmode == 3 then
            table.insert(ssfs, utils.CreateScrollSpeedFactor(endtime, finalSV))
        end
    end
    return ssfs
end

