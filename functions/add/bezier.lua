function ui_add_bezier()
    _, vars.useBezierDistance = imgui.Checkbox("Use Bezier Distance", vars.useBezierDistance)
    tooltip("When checked, uses bezier distance instead of start/stop values")

    if vars.useBezierDistance then
        imgui.SetNextItemWidth(ui.width)
        _, vars.bezierDistance = imgui.InputFloat("##BezierDistance", vars.bezierDistance, 0.5, 1)
        tooltip("Bezier distance factor")
    else
        setValue()
    end

    imgui.Separator()

    imgui.SetNextItemWidth((ui.width - ui.spacing) / 2)
    _, vars.x1 = imgui.SliderFloat("##X1", vars.x1, 0, 1)
    tooltip("x1")
    imgui.SameLine()
    imgui.SetNextItemWidth((ui.width - ui.spacing) / 2)
    _, vars.y1 = imgui.DragFloat("##Y1", vars.y1, 0.01, 0.0625)
    tooltip("y1")

    imgui.SetNextItemWidth((ui.width - ui.spacing) / 2)
    _, vars.x2 = imgui.SliderFloat("##X2", vars.x2, 0, 1)
    tooltip("x2")
    imgui.SameLine()
    imgui.SetNextItemWidth((ui.width - ui.spacing) / 2)
    _, vars.y2 = imgui.DragFloat("##Y2", vars.y2, 0.01, 0.0625)
    tooltip("y2")

    local lines = {}
    for t = 0, 1, 1 / math.min(vars.creatSVCount, 50) do
        table.insert(lines, bezier(t, vars.x1, vars.y1, vars.x2, vars.y2))
    end
    imgui.PlotLines("##BezierPreview", lines, #lines, 0, "", min(lines), max(lines), {ui.width, 0})
    tooltip("Preview")

    if button("Swap") then
        vars.x1, vars.x2 = 1 - vars.x2, 1 - vars.x1
        vars.y1, vars.y2 = 1 - vars.y2, 1 - vars.y1
    end

    imgui.Separator()

    if button("Add") then
        local svs, ssf = {}, {}

        local function get_time_ranges()
            if #state.SelectedHitObjects > 1 then
                local times = {}
                for _, note in ipairs(state.SelectedHitObjects) do
                    if not_has(times, note.StartTime) then
                        table.insert(times, note.StartTime)
                    end
                end
                table.sort(times)
                return times
            else
                return {vars.startTime, vars.stopTime}
            end
        end

        local time_range = get_time_ranges()
        for i = 1, #time_range - 1 do
            local t1, t2 = time_range[i], time_range[i + 1]
            local final_mode = (i < #time_range - 1) and 0 or vars.finalSVMode

            if vars.addSSF then
                local new_ssf = add_bezier_ssf(t1, t2, vars.creatSVCount, vars.start, vars.stop, vars.x1, vars.y1,
                    vars.x2, vars.y2, vars.useBezierDistance, final_mode, vars.finalSV, vars.bezierDistance)
                ssf = join_tables(ssf, new_ssf, false)
            else
                local new_svs = add_bezier_sv(t1, t2, vars.creatSVCount, vars.start, vars.stop, vars.x1, vars.y1,
                    vars.x2, vars.y2, vars.useBezierDistance, final_mode, vars.finalSV, vars.bezierDistance)
                svs = join_tables(svs, new_svs)
            end
        end

        local batchActions = {}
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

function add_bezier_sv(starttime, endtime, count, start, stop, x1, y1, x2, y2, ubd, fmode, finalSV, bscale)
    local svs = {}
    if starttime >= endtime or count == 0 then
        return {}
    end
    for i = 0, count - 1 do
        local t = select_time(starttime + (i / count) * (endtime - starttime))
        local s = start + (bezier((i + 0.5) / count, x1, y1, x2, y2)) * (stop - start)
        if ubd then
            s = (bezier((i + 1) / count, x1, y1, x2, y2) - bezier(i / count, x1, y1, x2, y2)) * count * bscale
        end
        table.insert(svs, utils.CreateScrollVelocity(t, s))
    end
    if fmode > 0 then
        if fmode == 1 then
            table.insert(svs, utils.CreateScrollVelocity(endtime, 1))
        elseif fmode == 2 then
            table.insert(svs, utils.CreateScrollVelocity(endtime, stop))
        elseif fmode == 3 then
            table.insert(svs, utils.CreateScrollVelocity(endtime, finalSV))
        end
    end
    return svs
end

function add_bezier_ssf(starttime, endtime, count, start, stop, x1, y1, x2, y2, ubd, fmode, finalSV, bscale)
    local ssfs = {}
    if starttime >= endtime or count == 0 then
        return {}
    end
    table.insert(ssfs, utils.CreateScrollSpeedFactor(starttime, get_ssf(starttime)))
    for i = 0, count - 1 do
        local t = select_time(starttime + (i / count) * (endtime - starttime))
        local s = start + (bezier((i + 0.5) / count, x1, y1, x2, y2)) * (stop - start)
        if ubd then
            s = (bezier((i + 1) / count, x1, y1, x2, y2) - bezier(i / count, x1, y1, x2, y2)) * count * bscale
        end
        table.insert(ssfs, utils.CreateScrollSpeedFactor(t, s))
    end
    if fmode > 0 then
        if fmode == 1 then
            table.insert(ssfs, utils.CreateScrollSpeedFactor(endtime, 1))
        elseif fmode == 2 then
            table.insert(ssfs, utils.CreateScrollSpeedFactor(endtime, stop))
        elseif fmode == 3 then
            table.insert(ssfs, utils.CreateScrollSpeedFactor(endtime, finalSV))
        end
    end
    return ssfs
end

