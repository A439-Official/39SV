function ui_edit_lineanim()

    imgui.SetNextItemWidth(ui.width)
    _, vars.frameCount = imgui.InputInt("##FrameCount", vars.frameCount, 8, 10)
    tooltip(i18n("edit_lineanim_frame_count"))

    imgui.SetNextItemWidth(ui.width)
    _, vars.frameDistance = imgui.InputText("##FrameDistance", vars.frameDistance, 32)
    tooltip(i18n("edit_lineanim_frame_distance"))

    _, vars.maxFrame = imgui.Checkbox(i18n("edit_lineanim_max_frame"), vars.maxFrame)
    tooltip(i18n("edit_lineanim_max_frame"))

    _, vars.teleportAtEnd = imgui.Checkbox(i18n("edit_lineanim_end_teleport"), vars.teleportAtEnd)

    imgui.Separator()

    imgui.Text(i18n("edit_lineanim_animation_list"))
    local typeNames = {i18n("edit_lineanim_line"), i18n("edit_lineanim_lines"), i18n("edit_lineanim_random"),
                       i18n("edit_lineanim_note")}
    local typeValues = {"line", "lines", "random", "note"}
    for idx = 1, #vars.lineAnimItems do
        local item = vars.lineAnimItems[idx]
        local typeIdx = indexof(typeValues, item.type) - 1
        if typeIdx == -1 then
            typeIdx = 0
        end

        imgui.SetNextItemWidth(ui.width - 32 - ui.spacing)
        local _, newType = imgui.Combo("##Type_" .. idx, typeIdx, typeNames, #typeNames)
        if _ then
            item.type = typeValues[newType + 1]
            if item.type == "line" then
                item.params = {"100"}
                -- 值
            elseif item.type == "lines" then
                item.params = {"4", "0", "100"}
                -- 数量
                -- 起始值
                -- 结束值
            elseif item.type == "random" then
                item.params = {"4", "0", "100"}
                -- 数量
                -- 最小值
                -- 最大值
            elseif item.type == "note" then
                item.params = {0, "0,0,1,1", "1"}
                -- 方向
                -- 缓动
                -- 缩放
            end
        end

        imgui.SameLine()

        if button("X##Remove_" .. idx, 32) then
            table.remove(vars.lineAnimItems, idx)
            break
        end

        imgui.SetNextItemWidth((ui.width - ui.spacing * 1) / 2)
        local _, nsp = imgui.InputFloat("##SP_" .. idx, item.sp)
        if _ then
            item.sp = nsp
        end
        imgui.SameLine()
        imgui.SetNextItemWidth((ui.width - ui.spacing * 1) / 2)
        local _, nep = imgui.InputFloat("##EP_" .. idx, item.ep)
        if _ then
            item.ep = nep
        end

        if item.type == "line" then
            imgui.SetNextItemWidth(ui.width)
            local _, newParam = imgui.InputText("##Param_" .. idx .. "_1", item.params[1], 32)
            tooltip(i18n("edit_lineanim_line_position"))
            if _ then
                item.params[1] = newParam
            end
        elseif item.type == "lines" then
            imgui.SetNextItemWidth((ui.width - ui.spacing * 1.5) / 3)
            local _, newParam = imgui.InputText("##Param_" .. idx .. "_1", item.params[1], 32)
            tooltip(i18n("edit_lineanim_lines_count"))
            if _ then
                item.params[1] = newParam
            end
            imgui.SameLine()
            imgui.SetNextItemWidth((ui.width - ui.spacing * 1.5) / 3)
            local _, newParam = imgui.InputText("##Param_" .. idx .. "_2", item.params[2], 32)
            tooltip(i18n("edit_lineanim_lines_start"))
            if _ then
                item.params[2] = newParam
            end
            imgui.SameLine()
            imgui.SetNextItemWidth((ui.width - ui.spacing * 1.5) / 3)
            local _, newParam = imgui.InputText("##Param_" .. idx .. "_3", item.params[3], 32)
            tooltip(i18n("edit_lineanim_lines_end"))
            if _ then
                item.params[3] = newParam
            end
        elseif item.type == "random" then
            imgui.SetNextItemWidth((ui.width - ui.spacing * 1.5) / 3)
            local _, newParam = imgui.InputText("##Param_" .. idx .. "_1", item.params[1], 32)
            tooltip(i18n("edit_lineanim_random_count"))
            if _ then
                item.params[1] = newParam
            end
            imgui.SameLine()
            imgui.SetNextItemWidth((ui.width - ui.spacing * 1.5) / 3)
            local _, newParam = imgui.InputText("##Param_" .. idx .. "_2", item.params[2], 32)
            tooltip(i18n("edit_lineanim_random_min"))
            if _ then
                item.params[2] = newParam
            end
            imgui.SameLine()
            imgui.SetNextItemWidth((ui.width - ui.spacing * 1.5) / 3)
            local _, newParam = imgui.InputText("##Param_" .. idx .. "_3", item.params[3], 32)
            tooltip(i18n("edit_lineanim_random_max"))
            if _ then
                item.params[3] = newParam
            end
        elseif item.type == "note" then
            imgui.SetNextItemWidth((ui.width - ui.spacing * 1.5) / 3)
            local _, a = imgui.Combo("##InOut_" .. idx, item.params[1],
                {i18n("edit_lineanim_note_in"), i18n("edit_lineanim_note_out")}, 2)
            tooltip(i18n("edit_lineanim_note_direction"))
            if _ then
                item.params[1] = a
            end
            imgui.SameLine()
            imgui.SetNextItemWidth((ui.width - ui.spacing * 1.5) / 3)
            local _, newBez = imgui.InputText("##Bez_" .. idx, item.params[2], 32)
            tooltip(i18n("edit_lineanim_note_easing"))
            if _ then
                item.params[2] = newBez
            end
            imgui.SameLine()
            imgui.SetNextItemWidth((ui.width - ui.spacing * 1.5) / 3)
            local _, newScale = imgui.InputText("##Scale_" .. idx, item.params[3], 32)
            tooltip(i18n("edit_lineanim_note_scale"))
            if _ then
                item.params[3] = newScale
            end
        end

        imgui.Spacing()

    end

    if button("+") then
        table.insert(vars.lineAnimItems, {
            type = "line",
            params = {"100"},
            sp = 0,
            ep = 1
        })
    end

    imgui.Separator()

    if button(i18n("edit_lineanim_apply")) then
        local tps, rsvs, svs = lineanim(math.floor(vars.startTime), math.floor(vars.stopTime), vars.frameCount,
            vars.frameDistance, vars.teleportAtEnd, vars.maxFrame)

        local batchActions = {}
        if #rsvs > 0 then
            remove_sv_batch(rsvs)
        end
        if #svs > 0 then
            add_sv_batch(svs)
        end
        if #tps > 0 then
            table.insert(batchActions, utils.CreateEditorAction(action_type.AddTimingPointBatch, tps))
        end
        local ts = {}
        for _, item in ipairs(vars.lineAnimItems) do
            table.insert(ts, item.type .. ": " .. table.concat(item.params, "  "))
        end
        local bookmark = utils.CreateBookmark(math.floor(vars.startTime), table.concat(ts, " || "))
        table.insert(batchActions, utils.CreateEditorAction(action_type.AddBookmark, bookmark))
        if #batchActions > 0 then
            actions.PerformBatch(batchActions)
        end
    end
end

function lineanim(starttime, stoptime, count, stepdistance, endteleport, saveFrameTime)
    local animdelay = 1
    local animspacing = 1 + vars.offset * 2 ^ 1
    local lines = {}
    local rsvs = {}
    local svs = {}
    local animdistance = (stoptime - starttime) / count

    local lastframe = starttime
    for ii = 1, count do
        local i = ii
        local time = lastframe
        if saveFrameTime then
            i = (lastframe - starttime) / (stoptime - starttime) * count
        else
            i = i - 1
            time = animdistance * i + starttime
            lastframe = time
        end
        table.insert(svs, utils.CreateScrollVelocity(time, paramNumber(stepdistance, i / count) / vars.offset))
        table.insert(svs, utils.CreateScrollVelocity(time + vars.offset, 0))
        time = time + vars.offset * 1
        lastframe = lastframe + vars.offset * 1
        local times = {}

        for _, item in ipairs(vars.lineAnimItems) do
            if i / count >= item.sp and i / count <= item.ep then
                local progress = (i / count - item.sp) / (item.ep - item.sp)
                if item.type == "line" then
                    table.insert(times, paramNumber(item.params[1], progress))
                elseif item.type == "lines" then
                    for j = 1, math.floor(paramNumber(item.params[1], progress)) do
                        table.insert(times,
                            paramNumber(item.params[2], progress) + (j - 1) /
                                (paramNumber(item.params[1], progress) - 1) *
                                (paramNumber(item.params[3], progress) - paramNumber(item.params[2], progress)))
                    end
                elseif item.type == "random" then
                    for j = 1, math.floor(paramNumber(item.params[1], progress)) do
                        table.insert(times, math.random(paramNumber(item.params[2], progress),
                            paramNumber(item.params[3], progress)))
                    end
                elseif item.type == "note" then
                    local hitobjects = {}
                    for _, hitobject in ipairs(map["HitObjects"]) do
                        if hitobject["StartTime"] >= starttime and hitobject["StartTime"] <= stoptime and
                            not_has(hitobjects, hitobject["StartTime"]) then
                            table.insert(hitobjects, hitobject["StartTime"])
                        end
                    end
                    table.insert(hitobjects, stoptime)
                    if item.params[1] == 1 then
                        table.sort(hitobjects, function(a, b)
                            return a > b
                        end)
                    end

                    local lasttime = starttime
                    local scale = paramNumber(item.params[3], progress)
                    if item.params[1] == 0 then
                        table.insert(times, 0)
                    elseif item.params[1] == 1 then
                        table.insert(times, (stoptime - starttime) * scale)
                    end
                    for _, hitobject in ipairs(hitobjects) do
                        if item.params[1] == 0 then
                            if hitobject < time then
                                table.insert(times, (hitobject - starttime) * scale)
                            elseif lasttime < time then
                                local a = (time - lasttime)
                                a = (hitobject - lasttime) * paramNumber(item.params[2], a / (hitobject - lasttime))
                                table.insert(times, (lasttime - starttime + a) * scale)
                            end
                        elseif item.params[1] == 1 then
                            if hitobject > time then
                                table.insert(times, (hitobject - starttime) * scale)
                            elseif lasttime > time then
                                local a = (time - lasttime)
                                a = (hitobject - lasttime) *
                                        (1 - paramNumber(item.params[2], 1 - a / (hitobject - lasttime)))
                                table.insert(times, (lasttime - starttime + a) * scale)
                            end
                        end
                        lasttime = hitobject
                    end
                end
            end
        end

        for i, msx in pairs(times) do
            local speed = msx / vars.offset
            lastframe = lastframe + animspacing
            table.insert(lines, utils.CreateTimingPoint(lastframe, get_bpm(lastframe)))
            table.insert(svs, utils.CreateScrollVelocity(lastframe, speed * -1))
            table.insert(svs, utils.CreateScrollVelocity(lastframe - vars.offset, speed))
            table.insert(svs, utils.CreateScrollVelocity(lastframe + vars.offset, 0))
            if lastframe > stoptime - vars.offset then
                goto b
            end
        end
    end
    ::b::
    table.insert(svs, utils.CreateScrollVelocity(stoptime, get_sv(stoptime)))
    table.insert(lines, utils.CreateTimingPoint(stoptime, get_bpm(stoptime)))
    if endteleport then
        table.insert(svs, utils.CreateScrollVelocity(stoptime - vars.offset, 10000 / vars.offset))
    end
    return lines, rsvs, svs
end
