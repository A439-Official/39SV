function draw_overlay()
    local launchTime = os.time() - vars.initTime

    local drawlist = imgui.GetOverlayDrawList()
    local w, h = state.WindowSize[1], state.WindowSize[2]
    local wx, wy = imgui.GetWindowPos()[1], imgui.GetWindowPos()[2]
    local ww, wh = imgui.GetWindowSize()[1], imgui.GetWindowSize()[2]

    local logoH, logoW = getImageSize(logo)
    local logoAspect = logoH / logoW

    if launchTime > 0 and launchTime <= 2 then
        drawRect(drawlist, wx, wy, ww, wh, rgbaToUint(0, 0, 0, 255))
    end

    if launchTime > 1 and launchTime <= 2 then
        local lh = wh / logoAspect * bezier(launchTime - 1, 0, 1, 1, 1)
        local ly = wy + wh / 2 - lh / 2
        drawImage(drawlist, wx, ly, ww, lh, logo)
    end

    if launchTime > 2 and launchTime <= 3 then
        drawRect(drawlist, wx, wy, ww, wh, rgbaToUint(0, 0, 0, math.floor(255 * (3 - launchTime))))
        local lh = wh / logoAspect
        local ly = wy + wh / 2 - lh / 2
        drawImage(drawlist, wx, ly, ww, lh, logo, math.floor(255 * (3 - launchTime)))
    end

    if launchTime > 0 and launchTime <= 3 then
        sx = 0.25 + 0.5 * bezier(launchTime % 1.5 / 1.5, 0, 0, 0.25, 1)
        ex = 0.25 + 0.5 * bezier(launchTime % 1.5 / 1.5, 0.75, 0, 1, 1)
        drawLine(drawlist, wx + ww * sx, wy + wh * 0.75, wx + ww * ex, wy + wh * 0.75, rgbaToUint(57, 197, 187, 255), 5)
    end
end
