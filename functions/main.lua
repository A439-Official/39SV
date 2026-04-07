function draw()
    style()
    get_vars("39SV_", vars)
    if not vars.init then
        init()
    end

    ui_main()

    save_vars("39SV_", vars)
end

function init()
    vars.initTime = os.time()
    vars.init = true
end
