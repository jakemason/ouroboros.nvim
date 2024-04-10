local config = {
    settings = {
        extension_preferences_table = {
            c = {h = 2, hpp = 1},
            h = {c = 2, cpp = 1},
            cpp = {hpp = 2, h = 1},
            hpp = {cpp = 1, c = 2},
        },
        -- this number may need to be tweaked, will need to test drive
        -- for a while and see
        score_required_to_be_confident_match_is_found = 10
    }
}

local function deep_merge(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                deep_merge(t1[k], t2[k]) -- Merge sub-tables
            else
                t1[k] = v -- Assign if t1 doesn't have this sub-table
            end
        else
            t1[k] = v -- Overwrite or assign simple values
        end
    end
    return t1
end

function config.setup(user_settings)
   config.settings = deep_merge(config.settings, user_settings)
end

return config
