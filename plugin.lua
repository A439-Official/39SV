vars = {
    mode = 0,
    starttime = 0,
    stoptime = 0,
    start = 0,
    stop = 1,
    creatSVmode = 0,
    creatSVcount = 16,
    x1 = 0,
    y1 = 0,
    x2 = 1,
    y2 = 1,
    advancedtext = "",
    finalSV = 0,
    finalSVmode = 1,
    editSVmode = 0,
    base = 1,
    baseoffset = 2 ^ -5,
    basescale = 1,
    keepstartpos = true,
    keepwithnotes = false,
    teleportmode = 0,
    teleportdistance = 10000,
    addssf = false,
    blacount = 32,
    blatext = "",
    lessframetime = false,
    framedist = 2439,
    endteleport = true,
    minignoringdistance = 8,
    compatibilitymode = false,
    usebezierdistance = true,
    bezierdistance = 1,
    vibtext = "",
    vibdist = 16,
    initstyle = false,
    displacedistance = 0
}

function draw()
    if not vars.initstyle then
        style()
        vars.initstyle = true
    end
    GETVARS("39SV_", vars)
    imgui.Begin("39SV - Simple SV Editor", nil, imgui_window_flags.AlwaysAutoResize)
    if imgui.Checkbox("Compatibility Mode", vars.compatibilitymode) then
        vars.compatibilitymode = not vars.compatibilitymode
        vars.baseoffset = vars.compatibilitymode and 1 or 2 ^ -5
    end
    imgui.SameLine()
    imgui.TextDisabled("(?)")
    if imgui.IsItemHovered() then
        imgui.SetTooltip("Provide support for sv of osu!mania, malody, etc")
    end
    imgui.Separator()
    imgui.PushStyleColor(imgui_col.Text, {200 / 255, 220 / 255, 240 / 255, 1})
    imgui.Text("Time Settings")
    imgui.PopStyleColor()
    imgui.BeginGroup()
    if imgui.Button("Current##Start") then
        vars.starttime = state.SelectedHitObjects[1] and state.SelectedHitObjects[1].StartTime or
                             select_time(state.SongTime)
    end
    imgui.SameLine()
    imgui.SetNextItemWidth(200)
    _, vars.starttime = imgui.InputFloat("Start Time", vars.starttime, 1)
    if imgui.Button("Current##Stop") then
        vars.stoptime = state.SelectedHitObjects[1] and state.SelectedHitObjects[1].StartTime or
                            select_time(state.SongTime)
    end
    imgui.SameLine()
    imgui.SetNextItemWidth(200)
    _, vars.stoptime = imgui.InputFloat("Stop Time", vars.stoptime, 1)
    imgui.SetNextItemWidth(250)
    imgui.InputText("Time Distance", (vars.stoptime - vars.starttime), 1)
    imgui.EndGroup()
    imgui.Separator()
    imgui.PushStyleColor(imgui_col.Text, {200 / 255, 220 / 255, 240 / 255, 1})
    imgui.Text("Operation Mode")
    imgui.PopStyleColor()
    imgui.SetNextItemWidth(150)
    _, vars.mode = imgui.Combo("Mode", vars.mode, {"Create SV", "Edit SV"}, 2)
    imgui.Separator()
    if vars.mode == 0 then
        imgui.PushStyleColor(imgui_col.Text, {180 / 255, 210 / 255, 230 / 255, 1})
        imgui.Text("SV Creation Settings")
        imgui.PopStyleColor()
        imgui.SetNextItemWidth(120)
        _, vars.creatSVmode = imgui.Combo("SV Type", vars.creatSVmode, {"Linear", "Bezier", "Advanced"}, 3)
        if vars.creatSVmode == 0 then
            vars.x1, vars.y1, vars.x2, vars.y2 = 0, 0, 1, 1
        end
        if vars.creatSVmode == 0 or not vars.usebezierdistance then
            imgui.BeginGroup()
            imgui.SetNextItemWidth(100)
            _, vars.start = imgui.InputFloat("Start Value", vars.start, 0.5, 1)
            imgui.SameLine()
            imgui.SetNextItemWidth(100)
            _, vars.stop = imgui.InputFloat("Stop Value", vars.stop, 0.5, 1)
            imgui.EndGroup()
        end
        if vars.creatSVmode == 0 or vars.creatSVmode == 1 then
            if imgui.Button("Swap Values##Swap") then
                vars.start, vars.stop = vars.stop, vars.start
                vars.x1, vars.x2 = 1 - vars.x2, 1 - vars.x1
                vars.y1, vars.y2 = 1 - vars.y2, 1 - vars.y1
            end
        end
        if vars.creatSVmode == 1 then
            imgui.Spacing()
            _, vars.usebezierdistance = imgui.Checkbox("Use Bezier Distance", vars.usebezierdistance)
            if vars.usebezierdistance then
                imgui.SetNextItemWidth(150)
                _, vars.bezierdistance = imgui.InputFloat("Bezier Distance", vars.bezierdistance, 0.5, 1)
            end
            imgui.BeginGroup()
            imgui.SetNextItemWidth(120)
            _, vars.x1 = imgui.SliderFloat("Control X1", vars.x1, 0, 1)
            imgui.SetNextItemWidth(120)
            _, vars.y1 = imgui.DragFloat("Control Y1", vars.y1, 0.01, 0.0625)
            imgui.EndGroup()
            imgui.BeginGroup()
            imgui.SetNextItemWidth(120)
            _, vars.x2 = imgui.SliderFloat("Control X2", vars.x2, 0, 1)
            imgui.SetNextItemWidth(120)
            _, vars.y2 = imgui.DragFloat("Control Y2", vars.y2, 0.01, 0.0625)
            imgui.EndGroup()
            lines = {}
            local t = 0
            while t <= 1 do
                table.insert(lines, BS(t, vars.x1, vars.y1, vars.x2, vars.y2))
                t = t + 1 / math.min(vars.creatSVcount, 50)
            end
            imgui.PlotLines("Bezier Preview", lines, nil, nil, nil, 0, 1, 150, 80)
        elseif vars.creatSVmode == 2 then
            imgui.BeginGroup()
            imgui.SetNextItemWidth(120)
            _, vars.advancedtext = imgui.InputTextMultiline("##Advanced", vars.advancedtext, 10000, {225, 225})
            imgui.EndGroup()
        end
        imgui.Spacing()
        imgui.Separator()
        imgui.PushStyleColor(imgui_col.Text, {180 / 255, 210 / 255, 230 / 255, 1})
        imgui.Text("SV Properties")
        imgui.PopStyleColor()
        imgui.SetNextItemWidth(100)
        _, vars.creatSVcount = imgui.InputInt("SV Count", vars.creatSVcount, 8, 10)
        if not vars.skipfinalSV then
            imgui.SetNextItemWidth(120)
            _, vars.finalSVmode = imgui.Combo("Final SV Type", vars.finalSVmode,
                {"Skip", "Default (1x)", "Normal (Stop Value)", "Custom"}, 4)
            if vars.finalSVmode == 3 then
                imgui.SetNextItemWidth(100)
                _, vars.finalSV = imgui.InputFloat("Final SV Value", vars.finalSV, 0.5, 1)
            end
        end
        _, vars.addssf = imgui.Checkbox("Use Scroll Speed Factor", vars.addssf)
        imgui.Spacing()
        if imgui.Button("Add SVs", 120, 30) then
            AddSVs()
        end
    elseif vars.mode == 1 then
        imgui.PushStyleColor(imgui_col.Text, {180 / 255, 210 / 255, 230 / 255, 1})
        imgui.Text("SV Editing Tools")
        imgui.PopStyleColor()
        imgui.SetNextItemWidth(150)
        _, vars.editSVmode = imgui.Combo("Edit Mode", vars.editSVmode, {"Keep Position", "Teleport", "Bar Line Anim",
                                                                        "Auto Delete", "Vibrato", "Displace Note",
                                                                        "Displace View"}, 7)
        imgui.Spacing()
        if vars.editSVmode == 0 then
            if imgui.Button("Current Scale##Scale") and vars.stoptime > vars.starttime then
                vars.basescale = ((state.SelectedHitObjects[1] and state.SelectedHitObjects[1].StartTime or
                                     state.SongTime) - vars.starttime) / (vars.stoptime - vars.starttime)
            end
            imgui.SameLine()
            imgui.SetNextItemWidth(120)
            _, vars.basescale = imgui.InputFloat("Base Scale", vars.basescale, 0.25, 0.5)
            imgui.SetNextItemWidth(120)
            _, vars.base = imgui.InputFloat("Base Value", vars.base, 0.5, 1)
            _, vars.keepstartpos = imgui.Checkbox("Keep Start Position", vars.keepstartpos)
            _, vars.keepwithnotes = imgui.Checkbox("Keep With Notes", vars.keepwithnotes)
        elseif vars.editSVmode == 1 then
            imgui.SetNextItemWidth(100)
            _, vars.teleportmode = imgui.Combo("Direction", vars.teleportmode, {"Up", "Down"}, 2)
            imgui.SetNextItemWidth(150)
            _, vars.teleportdistance = imgui.InputFloat("Distance", vars.teleportdistance, 1, 100)
        elseif vars.editSVmode == 2 then
            imgui.SetNextItemWidth(100)
            _, vars.blacount = imgui.InputInt("Frame Count", vars.blacount, 8, 10)
            imgui.SetNextItemWidth(150)
            _, vars.framedist = imgui.InputInt("Frame Distance", vars.framedist, 1, 100)
            _, vars.lessframetime = imgui.Checkbox("Less Frame Time", vars.lessframetime)
            _, vars.endteleport = imgui.Checkbox("End Teleport", vars.endteleport)
            imgui.Text("Animation Parameters:")
            -- imgui.SetNextItemWidth(350)
            _, vars.blatext = imgui.InputTextMultiline("##BLAArgs", vars.blatext, 10000, {225, 225})
        elseif vars.editSVmode == 4 then
            imgui.SetNextItemWidth(150)
            _, vars.vibdist = imgui.InputInt("Vibrato Distance", vars.vibdist, 8, 10)
            imgui.Text("Vibrato Parameters:")
            -- imgui.SetNextItemWidth(350)
            _, vars.vibtext = imgui.InputTextMultiline("##VibArgs", vars.vibtext, 10000, {225, 225})
        elseif vars.editSVmode == 5 or vars.editSVmode == 6 then
            imgui.SetNextItemWidth(150)
            _, vars.displacedistance = imgui.InputInt("Distance", vars.displacedistance, 1, 10)
        end
        imgui.Spacing()
        if imgui.Button("Apply Edit", 120, 30) then
            EditSV()
        end
    end
    SAVEVARS("39SV_", vars)
    imgui.End()
end

function EditSV()
    local rsvs, svs, rtps, tps, rssf, ssf = {}, {}, {}, {}, {}, {}
    if vars.editSVmode == 0 then
        if vars.keepwithnotes then
            local hobjs = {vars.starttime, vars.stoptime}
            for _, hobj in ipairs(map.HitObjects) do
                if hobj.StartTime > vars.starttime and hobj.StartTime < vars.stoptime and not_has(hobjs, hobj.StartTime) then
                    table.insert(hobjs, hobj.StartTime)
                end
            end
            table.sort(hobjs)
            for i, time in ipairs(hobjs) do
                if i < #hobjs then
                    local arsvs, asvs = keep(time, hobjs[i + 1], vars.basescale, vars.base)
                    rsvs = join_tables(rsvs, arsvs)
                    svs = join_tables(svs, asvs)
                end
            end
        else
            if #state.SelectedHitObjects > 0 then
                local times = {}
                for _, note in ipairs(state.SelectedHitObjects) do
                    if not_has(times, note.StartTime) then
                        table.insert(times, note.StartTime)
                    end
                end
                table.sort(times)
                for i = 1, #times - 1 do
                    local arsvs, asvs = keep(times[i], times[i + 1], vars.basescale, vars.base)
                    rsvs = join_tables(rsvs, arsvs)
                    svs = join_tables(svs, asvs)
                end
            else
                local arsvs, asvs = keep(vars.starttime, vars.stoptime, vars.basescale, vars.base)
                rsvs = join_tables(rsvs, arsvs)
                svs = join_tables(svs, asvs)
            end
        end
    elseif vars.editSVmode == 1 then
        if #state.SelectedHitObjects > 0 then
            local times = {}
            for _, note in ipairs(state.SelectedHitObjects) do
                if not_has(times, note.StartTime) then
                    table.insert(times, note.StartTime)
                end
            end
            table.sort(times)
            for i = 1, #times do
                local time = times[i]
                local arsvs, asvs = teleport(time, vars.teleportdistance, vars.teleportmode)
                rsvs = join_tables(rsvs, arsvs)
                svs = join_tables(svs, asvs)
            end
        else
            local arsvs, asvs = teleport(vars.starttime, vars.teleportdistance, vars.teleportmode)
            rsvs = join_tables(rsvs, arsvs)
            svs = join_tables(svs, asvs)
        end
    elseif vars.editSVmode == 2 then
        local atps, arsvs, asvs = barlineanim(math.floor(vars.starttime), math.floor(vars.stoptime), vars.blacount,
            vars.framedist, vars.endteleport)
        rsvs = join_tables(rsvs, arsvs)
        svs = join_tables(svs, asvs)
        tps = join_tables(tps, atps)
    elseif vars.editSVmode == 3 then
        local asvs, arsvs, artps = autodelete()
        rsvs = join_tables(rsvs, arsvs)
        svs = join_tables(svs, asvs)
        rtps = join_tables(rtps, artps)
    elseif vars.editSVmode == 4 then
        local arsvs, asvs, assf = vibrato(math.floor(vars.starttime), math.floor(vars.stoptime), vars.vibdist,
            vars.vibtext)
        rsvs = join_tables(rsvs, arsvs)
        svs = join_tables(svs, asvs)
        ssf = join_tables(ssf, assf)
    elseif vars.editSVmode == 5 then
        local times = {}
        for _, note in ipairs(state.SelectedHitObjects) do
            table.insert(times, note.StartTime)
        end
        local arsvs, asvs = displacenote(math.floor(vars.starttime), math.floor(vars.stoptime), vars.displacedistance,
            times)
        rsvs = join_tables(rsvs, arsvs)
        svs = join_tables(svs, asvs)
    elseif vars.editSVmode == 6 then
        local arsvs, asvs = displaceview(math.floor(vars.starttime), math.floor(vars.stoptime), vars.displacedistance,
            times)
        rsvs = join_tables(rsvs, arsvs)
        svs = join_tables(svs, asvs)
    end

    local batchActions = {}
    if #rsvs > 0 then
        table.insert(batchActions, utils.CreateEditorAction(action_type.RemoveScrollVelocityBatch, rsvs))
    end
    if #svs > 0 then
        table.insert(batchActions, utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svs))
    end
    if #rtps > 0 then
        table.insert(batchActions, utils.CreateEditorAction(action_type.RemoveTimingPointBatch, rtps))
    end
    if #tps > 0 then
        table.insert(batchActions, utils.CreateEditorAction(action_type.AddTimingPointBatch, tps))
    end
    if #rssf > 0 then
        table.insert(batchActions, utils.CreateEditorAction(action_type.RemoveScrollSpeedFactorBatch, rssf))
    end
    if #ssf > 0 then
        table.insert(batchActions, utils.CreateEditorAction(action_type.AddScrollSpeedFactorBatch, ssf))
    end
    if #batchActions > 0 then
        actions.PerformBatch(batchActions)
    end
end

function displaceview(starttime, stoptime, distance)
    local times = {}
    for _, note in ipairs(map["HitObjects"]) do
        if note.StartTime > starttime + vars.baseoffset and note.StartTime < stoptime - vars.baseoffset and
            state.SelectedScrollGroupId == note.TimingGroup and not_has(times, note.StartTime) then
            table.insert(times, note.StartTime)
        end
    end
    local rsvs = {}
    local svs = {}
    local arsvs, asvs = teleport(starttime, distance, 0)
    rsvs = join_tables(rsvs, arsvs)
    svs = join_tables(svs, asvs)
    local arsvs, asvs = displacenote(starttime, stoptime, -distance, times)
    rsvs = join_tables(rsvs, arsvs)
    svs = join_tables(svs, asvs)
    local arsvs, asvs = teleport(stoptime, -distance, 1)
    rsvs = join_tables(rsvs, arsvs)
    svs = join_tables(svs, asvs)
    return rsvs, svs
end

function displacenote(starttime, stoptime, distance, times)
    local rsvs = {}
    local svs = {}
    for _, time in ipairs(times) do
        local arsvs, asvs = teleport(time, distance, 1)
        rsvs = join_tables(rsvs, arsvs)
        svs = join_tables(svs, asvs)
        local arsvs, asvs = teleport(time, -distance, 0)
        rsvs = join_tables(rsvs, arsvs)
        svs = join_tables(svs, asvs)
    end
    return rsvs, svs
end

function vibrato(starttime, stoptime, vibdist, vibtext)
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
    while time <= starttime + vars.baseoffset do
        time = time + 60000 / bpm["Bpm"] / vibdist
    end
    while time < stoptime - vars.baseoffset do
        table.insert(times, select_time(time))
        time = time + 60000 / bpm["Bpm"] / vibdist
    end
    table.insert(times, stoptime)

    local lines = {}
    for vibline in vibtext:gmatch("[^\r\n]+") do
        local args = {}
        for arg in vibline:gmatch("%S+") do
            table.insert(args, arg)
        end
        table.insert(lines, args)
    end

    local lasttime = starttime
    local lastssf = SSF(starttime)
    for _, time in ipairs(times) do
        local svvibdistance = arg_parse(lines[(_ + 1) % #lines + 1][1], (lasttime - starttime) / (stoptime - starttime))
        local ssfvibdistance = SSF(lasttime)
        local svscale = 1
        if #lines[_ % #lines + 1] > 1 then
            svscale = arg_parse(lines[(_ + 1) % #lines + 1][2], (lasttime - starttime) / (stoptime - starttime))
            if #lines[_ % #lines + 1] > 2 then
                ssfvibdistance = arg_parse(lines[(_ + 1) % #lines + 1][3],
                    (lasttime - starttime) / (stoptime - starttime))
            end
        end
        if math.abs(svvibdistance) > vars.minignoringdistance / 4 then
            local arsvs, asvs = displaceview(lasttime, time, svvibdistance * svscale)
            -- if _ ~= 1 then
            --     table.remove(asvs, #asvs)
            -- end
            rsvs = join_tables(rsvs, arsvs)
            svs = join_tables(svs, asvs)
        end
        if math.abs(ssfvibdistance - lastssf) > 0 then
            if #ssf == 0 then
                table.insert(ssf, utils.CreateScrollSpeedFactor(starttime, SSF(starttime)))
            end
            table.insert(ssf, utils.CreateScrollSpeedFactor(lasttime, ssfvibdistance))
            table.insert(ssf, utils.CreateScrollSpeedFactor(time, ssfvibdistance))
        end
        lasttime = time
        lastssf = ssfvibdistance
    end
    if #ssf > 0 then
        table.insert(ssf, utils.CreateScrollSpeedFactor(stoptime, SSF(stoptime)))
    end
    return rsvs, svs, ssf
end

function autodelete()
    local rsvs, rtps, svs, lsv, ltp = {}, {}, {}, nil, nil
    for _, sv in ipairs(map.ScrollVelocities) do
        if _ ~= 1 then
            -- if sv == lsv then
            --     if not_has(rsvs, sv) then
            --         table.insert(rsvs, lsv)
            --         if not_has(svs, sv) then
            --             table.insert(svs, sv)
            --         end
            --     end
            -- else
            if sv.StartTime == lsv.StartTime then
                if not_has(rsvs, sv) then
                    table.insert(rsvs, lsv)
                end
            end
            --     if sv.Multiplier == lsv.Multiplier and math.abs(sv.StartTime - lsv.StartTime) < 1 then
            --         if not_has(rsvs, sv) then
            --             table.insert(rsvs, lsv)
            --         end
            --     end
            -- end
        end
        lsv = sv
    end
    for _, tp in ipairs(map.TimingPoints) do
        if _ ~= 1 and tp.StartTime == ltp.StartTime then
            if not_has(rtps, tp) then
                table.insert(rtps, ltp)
            end
        end
        ltp = tp
    end
    print("Remove SV Count: " .. #rsvs - #svs .. "\n TimingPoint Count: " .. #rtps)
    return svs, rsvs, rtps
end

function barlineanim(starttime, stoptime, count, stepdistance, endteleport)
    local animdelay = 1
    local animspacing = 1 + vars.baseoffset * 2 ^ 1
    local lines = {}
    local rsvs = {}
    local svs = {}
    local animdistance = (stoptime - starttime) / count
    local barlines = {}
    for barline in vars.blatext:gmatch("[^\r\n]+") do
        local args = {}
        for arg in barline:gmatch("%S+") do -- 按非空白字符分割
            table.insert(args, arg)
        end
        table.insert(barlines, args)
    end

    local lastframe = starttime
    for ii = 1, count do
        local i = ii
        local time = lastframe
        if vars.lessframetime then
            i = (lastframe - starttime) / (stoptime - starttime) * count
        else
            i = i - 1
            time = animdistance * i + starttime
            lastframe = time
        end
        table.insert(svs, utils.CreateScrollVelocity(time, stepdistance / vars.baseoffset))
        table.insert(svs, utils.CreateScrollVelocity(time + vars.baseoffset, 0))
        time = time + vars.baseoffset * 1
        lastframe = lastframe + vars.baseoffset * 1
        local times = {}

        for _, barline in pairs(barlines) do
            if barline[1] == "l" then
                table.insert(times, arg_parse(barline[2], i / count))
            elseif barline[1] == "atn" then
                local hitobjects = {}
                for _, hitobject in ipairs(map["HitObjects"]) do
                    if hitobject["StartTime"] >= starttime and hitobject["StartTime"] <= stoptime and
                        not_has(hitobjects, hitobject["StartTime"]) then
                        table.insert(hitobjects, hitobject["StartTime"])
                    end
                end
                table.insert(hitobjects, stoptime)

                local lasttime = starttime
                for _, hitobject in ipairs(hitobjects) do
                    if hitobject < time then
                        table.insert(times, (hitobject - starttime) * tonumber(barline[2]))
                    elseif lasttime < time then
                        local a = (time - lasttime)
                        if barline[3] then
                            ls = split(barline[3], ",")
                            a = (hitobject - lasttime) * BS(a / (hitobject - lasttime), ls[1], ls[2], ls[3], ls[4])
                        end
                        table.insert(times, (lasttime - starttime + a) * tonumber(barline[2]))
                    end
                    lasttime = hitobject
                end
            elseif barline[1] == "antn" then
                local hitobjects = {}
                for _, hitobject in ipairs(map["HitObjects"]) do
                    if hitobject["StartTime"] >= starttime and hitobject["StartTime"] <= stoptime and
                        not_has(hitobjects, hitobject["StartTime"]) then
                        table.insert(hitobjects, hitobject["StartTime"])
                    end
                end
                table.insert(hitobjects, stoptime)
                table.sort(hitobjects, function(a, b)
                    return a > b
                end)

                local lasttime = starttime
                for _, hitobject in ipairs(hitobjects) do
                    if hitobject > time then
                        table.insert(times, (hitobject - starttime) * tonumber(barline[2]))
                    elseif lasttime > time then
                        local a = (time - lasttime)
                        if barline[3] then
                            ls = split(barline[3], ",")
                            a = (hitobject - lasttime) *
                                    (1 - BS(1 - a / (hitobject - lasttime), ls[1], ls[2], ls[3], ls[4]))
                        end
                        table.insert(times, (lasttime - starttime + a) * tonumber(barline[2]))
                    end
                    lasttime = hitobject
                end
            elseif barline[1] == "r" then
                for j = 1, tonumber(barline[2]) do
                    table.insert(times, math.random(arg_parse(barline[3], i / count), arg_parse(barline[4], i / count)))
                end
            elseif barline[1] == "n" then
                for j = 1, tonumber(barline[2]) + 1 do
                    table.insert(times, arg_parse(barline[3], i / count) + (j - 1) / tonumber(barline[2]) *
                        (arg_parse(barline[4], i / count) - arg_parse(barline[3], i / count)))
                end
            end
        end
        for i, msx in pairs(times) do
            local speed = msx / vars.baseoffset
            lastframe = lastframe + animspacing
            table.insert(lines, utils.CreateTimingPoint(lastframe, BPM(lastframe)))
            table.insert(svs, utils.CreateScrollVelocity(lastframe, speed * -1))
            table.insert(svs, utils.CreateScrollVelocity(lastframe - vars.baseoffset, speed))
            table.insert(svs, utils.CreateScrollVelocity(lastframe + vars.baseoffset, 0))
            if lastframe > stoptime - vars.baseoffset then
                goto b
            end
        end
    end
    ::b::
    table.insert(svs, utils.CreateScrollVelocity(stoptime, SV(stoptime)))
    table.insert(lines, utils.CreateTimingPoint(stoptime, BPM(stoptime)))
    if endteleport then
        table.insert(svs, utils.CreateScrollVelocity(stoptime - vars.baseoffset, stepdistance / vars.baseoffset))
    end
    return lines, rsvs, svs
end

function teleport(t, d, m)
    local rsvs, svs = {}, {}
    if m == 0 then
        for _, sv in ipairs(map.ScrollVelocities) do
            if sv.StartTime >= t and sv.StartTime < t + vars.baseoffset then
                table.insert(rsvs, sv)
            end
        end
        table.insert(svs, utils.CreateScrollVelocity(t, (d + DISTANCE(t, t + vars.baseoffset)) / vars.baseoffset))
        table.insert(svs, utils.CreateScrollVelocity(t + vars.baseoffset, SV(t + vars.baseoffset)))
    else
        for _, sv in ipairs(map.ScrollVelocities) do
            if sv.StartTime >= t - vars.baseoffset and sv.StartTime < t then
                table.insert(rsvs, sv)
            end
        end
        table.insert(svs, utils.CreateScrollVelocity(t - vars.baseoffset,
            (d + DISTANCE(t - vars.baseoffset, t)) / vars.baseoffset))
        table.insert(svs, utils.CreateScrollVelocity(t, SV(t)))
    end
    return rsvs, svs
end

function keep(starttime, endtime, basescale, base)
    if starttime == endtime then
        return
    end
    local hitobjects = {}
    for _, hitobject in ipairs(map["HitObjects"]) do
        if hitobject["StartTime"] > starttime and hitobject["StartTime"] < endtime and state.SelectedScrollGroupId ==
            hitobject.TimingGroup and not_has(hitobjects, hitobject) then
            offset = DISTANCE(starttime + (endtime - starttime) * base, hitobject["StartTime"]) -
                         (hitobject["StartTime"] - (starttime + (endtime - starttime) * base)) * basescale
            if math.abs(offset) > vars.minignoringdistance then
                table.insert(hitobjects, {hitobject["StartTime"], offset})
            end
        end
        if hitobject["EndTime"] > starttime and hitobject["EndTime"] < endtime and state.SelectedScrollGroupId ==
            hitobject.TimingGroup and not_has(hitobjects, hitobject) then
            offset = DISTANCE(starttime + (endtime - starttime) * base, hitobject["EndTime"]) -
                         (hitobject["EndTime"] - (starttime + (endtime - starttime) * base)) * basescale
            if math.abs(offset) > vars.minignoringdistance then
                table.insert(hitobjects, {hitobject["EndTime"], offset})
            end
        end
    end
    local rsvs, svs = {}, {}
    for _, hitobject in ipairs(hitobjects) do
        local arsvs, asvs = teleport(hitobject[1], -hitobject[2], 1)
        rsvs = join_tables(rsvs, arsvs)
        svs = join_tables(svs, asvs)
        local arsvs, asvs = teleport(hitobject[1], hitobject[2], 0)
        rsvs = join_tables(rsvs, arsvs)
        svs = join_tables(svs, asvs)
    end
    sdist = DISTANCE(starttime + (endtime - starttime) * base, starttime) -
                (starttime - (starttime + (endtime - starttime) * base)) * basescale
    if math.abs(sdist) > vars.minignoringdistance then
        local arsvs, asvs = teleport(starttime, sdist, 0)
        rsvs = join_tables(rsvs, arsvs)
        svs = join_tables(svs, asvs)
    end
    edist = DISTANCE(endtime, starttime + (endtime - starttime) * base) -
                ((starttime + (endtime - starttime) * base) - endtime) * basescale
    if math.abs(edist) > vars.minignoringdistance then
        local arsvs, asvs = teleport(endtime, edist, 1)
        rsvs = join_tables(rsvs, arsvs)
        svs = join_tables(svs, asvs)
    end
    return rsvs, svs
end

function style()
    local miku = {57 / 255, 197 / 255, 187 / 255}
    local color_1 = {15 / 255, 20 / 255, 25 / 255, 255 / 255}
    local color_2 = {20 / 255, 25 / 255, 30 / 255, 245 / 255}
    local color_3 = join_tables(miku, {100 / 255})
    local color_4 = {25 / 255, 35 / 255, 40 / 255, 255 / 255}
    local color_5 = {35 / 255, 45 / 255, 50 / 255, 255 / 255}
    local color_6 = {45 / 255, 55 / 255, 60 / 255, 255 / 255}
    local color_7 = {20 / 255, 25 / 255, 30 / 255, 255 / 255}
    local color_8 = join_tables(miku, {255 / 255})
    local color_9 = join_tables(miku, {180 / 255})
    local color_10 = {70 / 255, 210 / 255, 200 / 255, 255 / 255}
    local color_11 = {30 / 255, 40 / 255, 45 / 255, 255 / 255}
    local color_12 = join_tables(miku, {150 / 255})
    local color_13 = join_tables(miku, {200 / 255})
    local color_14 = join_tables(miku, {80 / 255})
    local color_15 = join_tables(miku, {120 / 255})
    local color_16 = join_tables(miku, {160 / 255})
    local color_17 = {240 / 255, 240 / 255, 240 / 255, 255 / 255}

    imgui.pushStyleColor(imgui_col.WindowBg, color_1)
    imgui.pushStyleColor(imgui_col.PopupBg, color_2)
    imgui.pushStyleColor(imgui_col.Border, color_3)
    imgui.pushStyleColor(imgui_col.FrameBg, color_4)
    imgui.pushStyleColor(imgui_col.FrameBgHovered, color_5)
    imgui.pushStyleColor(imgui_col.FrameBgActive, color_6)
    imgui.pushStyleColor(imgui_col.TitleBg, color_7)
    imgui.pushStyleColor(imgui_col.TitleBgActive, color_8)
    imgui.pushStyleColor(imgui_col.TitleBgCollapsed, color_9)
    imgui.pushStyleColor(imgui_col.CheckMark, color_8)
    imgui.pushStyleColor(imgui_col.SliderGrab, color_8)
    imgui.pushStyleColor(imgui_col.SliderGrabActive, color_10)
    imgui.pushStyleColor(imgui_col.Button, color_11)
    imgui.pushStyleColor(imgui_col.ButtonHovered, color_12)
    imgui.pushStyleColor(imgui_col.ButtonActive, color_13)
    imgui.pushStyleColor(imgui_col.Tab, color_4)
    imgui.pushStyleColor(imgui_col.TabHovered, color_3)
    imgui.pushStyleColor(imgui_col.TabActive, color_8)
    imgui.pushStyleColor(imgui_col.Header, color_14)
    imgui.pushStyleColor(imgui_col.HeaderHovered, color_15)
    imgui.pushStyleColor(imgui_col.HeaderActive, color_16)
    imgui.pushStyleColor(imgui_col.Separator, color_3)
    imgui.pushStyleColor(imgui_col.Text, color_17)
    imgui.pushStyleColor(imgui_col.TextSelectedBg, color_3)
    imgui.pushStyleColor(imgui_col.ScrollbarGrab, color_12)
    imgui.pushStyleColor(imgui_col.ScrollbarGrabHovered, color_13)
    imgui.pushStyleColor(imgui_col.ScrollbarGrabActive, color_10)
    imgui.pushStyleColor(imgui_col.PlotLines, color_8)
    imgui.pushStyleColor(imgui_col.PlotLinesHovered, color_10)
    imgui.pushStyleColor(imgui_col.PlotHistogram, color_8)
    imgui.pushStyleColor(imgui_col.PlotHistogramHovered, color_10)
    imgui.pushStyleColor(imgui_col.TableHeaderBg, color_15)
    imgui.pushStyleVar(imgui_style_var.FrameRounding, 4.0)
    imgui.pushStyleVar(imgui_style_var.GrabRounding, 4.0)
    imgui.pushStyleVar(imgui_style_var.WindowRounding, 8.0)
    imgui.pushStyleVar(imgui_style_var.PopupRounding, 8.0)
    imgui.pushStyleVar(imgui_style_var.ScrollbarRounding, 9.0)
end

function AddSVs()
    local rsvs, svs, rtps, tps, rssf, ssf = {}, {}, {}, {}, {}, {}

    if #state.SelectedHitObjects > 1 then
        local times = {}
        for _, note in ipairs(state.SelectedHitObjects) do
            if not_has(times, note.StartTime) then
                table.insert(times, note.StartTime)
            end
        end
        table.sort(times)
        for i = 1, #times - 1 do
            local t1, t2 = times[i], times[i + 1]
            local asvs, assf = beziersv(t1, t2, vars.creatSVcount, vars.start, vars.stop, vars.x1, vars.y1, vars.x2,
                vars.y2, vars.creatSVmode, vars.usebezierdistance, vars.addssf,
                switch(i < #times - 1, 0, vars.finalSVmode), vars.finalSV, vars.bezierdistance, vars.advancedtext)
            svs = join_tables(svs, asvs)
            ssf = join_tables(ssf, assf)
        end
    else
        local asvs, assf = beziersv(vars.starttime, vars.stoptime, vars.creatSVcount, vars.start, vars.stop, vars.x1,
            vars.y1, vars.x2, vars.y2, vars.creatSVmode, vars.usebezierdistance, vars.addssf, vars.finalSVmode,
            vars.finalSV, vars.bezierdistance, vars.advancedtext)
        svs = join_tables(svs, asvs)
        ssf = join_tables(ssf, assf)
    end

    local batchActions = {}
    if #rsvs > 0 then
        table.insert(batchActions, utils.CreateEditorAction(action_type.RemoveScrollVelocityBatch, rsvs))
    end
    if #svs > 0 then
        table.insert(batchActions, utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svs))
    end
    if #rtps > 0 then
        table.insert(batchActions, utils.CreateEditorAction(action_type.RemoveTimingPointBatch, rtps))
    end
    if #tps > 0 then
        table.insert(batchActions, utils.CreateEditorAction(action_type.AddTimingPointBatch, tps))
    end
    if #rssf > 0 then
        table.insert(batchActions, utils.CreateEditorAction(action_type.RemoveScrollSpeedFactorBatch, rssf))
    end
    if #ssf > 0 then
        table.insert(batchActions, utils.CreateEditorAction(action_type.AddScrollSpeedFactorBatch, ssf))
    end
    if #batchActions > 0 then
        actions.PerformBatch(batchActions)
    end
end

function beziersv(starttime, endtime, count, start, stop, x1, y1, x2, y2, mode, ubd, ssfmode, fmode, finalSV, bscale, at)
    local svs, ssfs = {}, {}
    if starttime >= endtime or count == 0 then
        return {}, {}
    end
    if ssfmode then
        table.insert(ssfs, utils.CreateScrollSpeedFactor(starttime - vars.baseoffset, 1))
    end
    local lines = {}
    for line in at:gmatch("[^\r\n]+") do
        local args = {}
        for arg in line:gmatch("%S+") do
            table.insert(args, arg)
        end
        table.insert(lines, args)
    end
    for i = 0, count - 1 do
        local t = select_time(starttime + (i / count) * (endtime - starttime))
        local s = 1
        if mode == 0 or mode == 1 then
            s = start + (BS((i + 0.5) / count, x1, y1, x2, y2)) * (stop - start)
            if ubd and mode == 1 then
                s = (BS((i + 1) / count, x1, y1, x2, y2) - BS(i / count, x1, y1, x2, y2)) * count * bscale
            end
        elseif mode == 2 then
            if ssfmode then
                s = arg_parse(lines[1][1], (i) / count)
            else
                s = (arg_parse(lines[1][1], (i + 1) / count) - arg_parse(lines[1][1], (i) / count)) * count
            end
        end

        if ssfmode then
            table.insert(ssfs, utils.CreateScrollSpeedFactor(t, s))
        else
            table.insert(svs, utils.CreateScrollVelocity(t, s))
        end
    end
    if fmode > 0 then
        if ssfmode then
            table.insert(ssfs, utils.CreateScrollSpeedFactor(endtime - vars.baseoffset, stop))
            if fmode == 1 then
                table.insert(ssfs, utils.CreateScrollSpeedFactor(endtime, 1))
            elseif fmode == 2 then
                table.insert(ssfs, utils.CreateScrollSpeedFactor(endtime, stop))
            elseif fmode == 3 then
                table.insert(ssfs, utils.CreateScrollSpeedFactor(endtime, finalSV))
            end
        else
            if fmode == 1 then
                table.insert(svs, utils.CreateScrollVelocity(endtime, 1))
            elseif fmode == 2 then
                table.insert(svs, utils.CreateScrollVelocity(endtime, stop))
            elseif fmode == 3 then
                table.insert(svs, utils.CreateScrollVelocity(endtime, finalSV))
            end
        end
    end
    return svs, ssfs
end

function BPM(t)
    local lb
    for _, tp in ipairs(map.TimingPoints) do
        if tp.StartTime <= t then
            lb = tp.Bpm
        else
            break
        end
    end
    return lb or map.TimingPoints[1].Bpm
end
function SV(t)
    local s = 1
    for _, sv in ipairs(map.ScrollVelocities) do
        if sv.StartTime <= t then
            s = sv.Multiplier
        else
            break
        end
    end
    return s
end
function SSF(t)
    if #map.ScrollSpeedFactors == 0 then
        return 1
    end
    if t <= map.ScrollSpeedFactors[1].StartTime then
        return 1
    end
    for i = 1, #map.ScrollSpeedFactors - 1 do
        local current = map.ScrollSpeedFactors[i]
        local next = map.ScrollSpeedFactors[i + 1]
        if t >= current.StartTime and t <= next.StartTime then
            local ratio = (t - current.StartTime) / (next.StartTime - current.StartTime)
            return current.Multiplier + (next.Multiplier - current.Multiplier) * ratio
        end
    end
    return map.ScrollSpeedFactors[#map.ScrollSpeedFactors].Multiplier
end
function DISTANCE(t1, t2)
    local reverse = false
    if not t2 then
        t2 = 0
    end
    if t1 > t2 then
        t1, t2 = t2, t1
        reverse = true
    end
    local d, lt, ls = 0, t1, 1
    for _, sv in ipairs(map.ScrollVelocities) do
        if sv.StartTime > t2 then
            break
        elseif sv.StartTime > t1 then
            d = d + (sv.StartTime - lt) * ls
            lt = sv.StartTime
            ls = sv.Multiplier
        elseif sv.StartTime <= t1 then
            ls = sv.Multiplier
            lt = math.max(lt, sv.StartTime)
        end
    end
    if lt < t2 then
        d = d + (t2 - lt) * ls
    end
    if reverse then
        d = -d
    end
    return d
end
function BS(x, p1x, p1y, p2x, p2y, e)
    e = e or 10
    local function b(t, ty)
        if ty == "x" then
            return (1 - t) ^ 3 * 0 + 3 * (1 - t) ^ 2 * t * p1x + 3 * (1 - t) * t ^ 2 * p2x + t ^ 3 * 1
        else
            return (1 - t) ^ 3 * 0 + 3 * (1 - t) ^ 2 * t * p1y + 3 * (1 - t) * t ^ 2 * p2y + t ^ 3 * 1
        end
    end
    local t, m = 0.5, 0.5
    for i = 1, e do
        m = m * 0.5
        if b(t, "x") < x then
            t = t + m
        else
            t = t - m
        end
    end
    return b(t, "y")
end
function not_has(t, v)
    for _, v2 in pairs(t) do
        if v2 == v then
            return false
        end
    end
    return true
end
function split(s, d)
    local r, f = {}, 1
    local dp, dp2
    while true do
        dp, dp2 = s:find(d, f, true)
        if not dp then
            table.insert(r, s:sub(f))
            break
        end
        table.insert(r, s:sub(f, dp - 1))
        f = dp2 + 1
    end
    return r
end
function arg_parse(a, p)
    local as = split(a, ",")
    if #as == 1 then
        return tonumber(as[1])
    elseif as[1] == "0" then
        return tonumber(as[2]) + (tonumber(as[3]) - tonumber(as[2])) * p
    elseif as[1] == "1" then
        return tonumber(as[2]) + (tonumber(as[3]) - tonumber(as[2])) *
                   BS(p, tonumber(as[4]), tonumber(as[5]), tonumber(as[6]), tonumber(as[7]))
    elseif as[1] == "2" then
        if p < 0.5 then
            return tonumber(as[2]) + (tonumber(as[3]) - tonumber(as[2])) * 2 *
                       BS(2 * p, tonumber(as[4]), tonumber(as[5]), tonumber(as[6]), tonumber(as[7])) * 0.5
        else
            return tonumber(as[2]) + (tonumber(as[3]) - tonumber(as[2])) * 2 *
                       BS(2 - 2 * p, tonumber(as[4]), tonumber(as[5]), tonumber(as[6]), tonumber(as[7])) * 0.5
        end
    elseif as[1] == "3" then
        if p < 0.5 then
            return tonumber(as[3]) - (tonumber(as[3]) - tonumber(as[2])) *
                       BS(2 * p, tonumber(as[4]), tonumber(as[5]), tonumber(as[6]), tonumber(as[7])) * 0.5
        else
            return tonumber(as[2]) + (tonumber(as[3]) - tonumber(as[2])) *
                       BS(2 - 2 * p, tonumber(as[4]), tonumber(as[5]), tonumber(as[6]), tonumber(as[7])) * 0.5
        end
    elseif as[1] == "s" then
        for i = 1, tonumber(as[2]) do
            local st = tonumber(1 / as[2] * (i - 1))
            local et = tonumber(1 / as[2] * i)
            if p >= st and p < et then
                return arg_parse(table.concat(as, ",", 3), (p - st) / (et - st))
            end
        end
    end
end
function select_time(t)
    for _, h in ipairs(map.HitObjects) do
        if math.abs(h.StartTime - t) < 1 then
            return h.StartTime
        end
    end
    for _, h in ipairs(map.HitObjects) do
        if math.abs(h.EndTime - t) < 1 then
            return h.EndTime
        end
    end
    return t
end
function GETVARS(n, v)
    for k, _ in pairs(v) do
        v[k] = state.GetValue(n .. k) or v[k]
    end
end
function SAVEVARS(n, v)
    for k, val in pairs(v) do
        state.SetValue(n .. k, val)
    end
end

function join_tables(t1, t2)
    local result = {}
    local time_index = {}

    -- 处理第一个表
    for i, v in ipairs(t1) do
        if type(v) == "userdata" and v.StartTime then
            time_index[v.StartTime] = #result + 1
            table.insert(result, v)
        else
            table.insert(result, v)
        end
    end

    -- 处理第二个表
    for i, v in ipairs(t2) do
        if type(v) == "userdata" and v.StartTime then
            if time_index[v.StartTime] then
                -- 如果有相同的time，替换现有的项
                result[time_index[v.StartTime]] = v
            else
                -- 如果没有相同的time，添加新项
                time_index[v.StartTime] = #result + 1
                table.insert(result, v)
            end
        else
            table.insert(result, v)
        end
    end

    return result
end
function switch(x, a, b)
    if x then
        return a
    else
        return b
    end
end
function diff(array1, array2)
    local result = {}
    local lookup = {}
    for i = 1, #array2 do
        lookup[array2[i]] = true
    end
    for i = 1, #array1 do
        if not lookup[array1[i]] then
            table.insert(result, array1[i])
        end
    end
    return result
end
