function ui_edit_resetoffset()

    if button(i18n("edit_resetoffset_apply")) then
        if async_is_running() then
            return
        end
        local svs = get_all_sv()
        async_run(map.HitObjects, function(h, idx, total)
            teleport(h.StartTime, 0, 0)
            teleport(h.StartTime, 0, 1)
        end, function()
        end)
    end
end
