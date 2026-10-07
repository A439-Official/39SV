function draw()

    style()
    get_vars("39SV_", vars)
    if not vars.init then
        init()
    end

    local settings_copy = deepcopy(vars.settings)

    vars.offset = vars.settings.compatibilityMode and 1 or 2 ^ -6

    ui_main()

    async_process()

    if not async_is_running() then
        sync_map_caches()
    end

    if not deepcompare(settings_copy, vars.settings) then
        write(vars.settings)
    end

    save_vars("39SV_", vars)
end

function init()
    vars.initTime = os.time()
    vars.init = true

    local savedsettings = read()
    for key, value in pairs(vars.settings) do
        if savedsettings[key] ~= nil then
            if savedsettings[key] == "true" then
                vars.settings[key] = true
            elseif savedsettings[key] == "false" then
                vars.settings[key] = false
            elseif savedsettings[key] == "nil" then
                vars.settings[key] = nil
            else
                vars.settings[key] = savedsettings[key]
            end
        end
    end

    load_clipboard()
end
