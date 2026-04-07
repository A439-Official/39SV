function linear(x, a, b)
    return (b - a) * x + a
end

function bezier(x, p1x, p1y, p2x, p2y, e)
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
