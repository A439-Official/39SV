function deepcopy(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for k, v in pairs(orig) do
            copy[deepcopy(k)] = deepcopy(v)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function get_vars(n, v)
    for k, _ in pairs(v) do
        local val = state.GetValue(n .. k)
        if val ~= nil then
            v[k] = deepcopy(val)
        end
    end
end

function save_vars(n, v)
    for k, val in pairs(v) do
        state.SetValue(n .. k, deepcopy(val))
    end
end
