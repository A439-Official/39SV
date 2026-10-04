function ui_add_bezier_old()
    imgui.SetNextItemWidth((ui.width - ui.spacing) / 2)
    _, vars.x1 = imgui.SliderFloat("##X1", vars.x1, 0, 1)
    tooltip(i18n("add_bezierold_x1"))
    imgui.SameLine()
    imgui.SetNextItemWidth((ui.width - ui.spacing) / 2)
    _, vars.y1 = imgui.DragFloat("##Y1", vars.y1, 0.01, 0.0625)
    tooltip(i18n("add_bezierold_y1"))

    imgui.SetNextItemWidth((ui.width - ui.spacing) / 2)
    _, vars.x2 = imgui.SliderFloat("##X2", vars.x2, 0, 1)
    tooltip(i18n("add_bezierold_x2"))
    imgui.SameLine()
    imgui.SetNextItemWidth((ui.width - ui.spacing) / 2)
    _, vars.y2 = imgui.DragFloat("##Y2", vars.y2, 0.01, 0.0625)
    tooltip(i18n("add_bezierold_y2"))

    local lines = {}
    for t = 0, 1, 1 / math.min(vars.creatSVCount, 50) do
        table.insert(lines, bezier(t, vars.x1, vars.y1, vars.x2, vars.y2))
    end
    imgui.PlotLines("##BezierPreview", lines, #lines, 0, "", min(lines), max(lines), {(ui.width - ui.spacing) / 2, 0})
    tooltip(i18n("add_bezierold_preview"))

    imgui.SameLine()

    if button(i18n("add_bezierold_swap"), (ui.width - ui.spacing) / 2) then
        vars.x1, vars.x2 = 1 - vars.x2, 1 - vars.x1
        vars.y1, vars.y2 = 1 - vars.y2, 1 - vars.y1
    end

    imgui.Separator()

    imgui.SetNextItemWidth(ui.width)
    _, vars.bezierOldScale = imgui.InputFloat("##BezierOldScale", vars.bezierOldScale, 0.1, 1, "%.3f")
    tooltip(i18n("add_bezierold_scale"))

    imgui.Separator()

    if button(i18n("add_bezierold_apply")) then
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
                add_bezier_old_ssf(t1, t2, vars.creatSVCount, vars.x1, vars.y1, vars.x2, vars.y2,
                    final_mode, vars.finalSV, vars.bezierOldScale)
            else
                add_bezier_old_sv(t1, t2, vars.creatSVCount, vars.x1, vars.y1, vars.x2, vars.y2, final_mode,
                    vars.finalSV, vars.bezierOldScale)
            end
        end
    end
end

function add_bezier_old_sv(starttime, endtime, count, x1, y1, x2, y2, fmode, finalSV, scale)
    local svs = {}
    if starttime >= endtime or count == 0 then
        return {}
    end
    for i = 0, count - 1 do
        local t = select_time(starttime + (i / count) * (endtime - starttime))
        local s = (bezier((i + 1) / count, x1, y1, x2, y2) - bezier(i / count, x1, y1, x2, y2)) * count * scale
        table.insert(svs, utils.CreateScrollVelocity(t, s))
    end
    if fmode > 0 then
        if fmode == 1 then
            table.insert(svs, utils.CreateScrollVelocity(endtime, 1))
        elseif fmode == 2 then
            table.insert(svs, utils.CreateScrollVelocity(endtime, get_sv(endtime)))
        elseif fmode == 3 then
            table.insert(svs, utils.CreateScrollVelocity(endtime, finalSV))
        end
    end
    add_sv_batch(svs)
end

function add_bezier_old_ssf(starttime, endtime, count, x1, y1, x2, y2, fmode, finalSV, scale)
    local ssfs = {}
    if starttime >= endtime or count == 0 then
        return
    end
    table.insert(ssfs, utils.CreateScrollSpeedFactor(starttime, get_ssf(starttime)))
    for i = 0, count - 1 do
        local t = select_time(starttime + (i / count) * (endtime - starttime))
        local s = (bezier((i + 0.5) / count, x1, y1, x2, y2)) * scale
        table.insert(ssfs, utils.CreateScrollSpeedFactor(t, s))
    end
    table.insert(ssfs, utils.CreateScrollSpeedFactor(endtime - vars.offset, get_ssf(endtime)))
    if fmode > 0 then
        if fmode == 1 then
            table.insert(ssfs, utils.CreateScrollSpeedFactor(endtime, 1))
        elseif fmode == 2 then
            table.insert(ssfs, utils.CreateScrollSpeedFactor(endtime, get_ssf(endtime)))
        elseif fmode == 3 then
            table.insert(ssfs, utils.CreateScrollSpeedFactor(endtime, finalSV))
        end
    end
    add_ssf_batch(ssfs)
end
