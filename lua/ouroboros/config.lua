local config = {
    settings = {
        -- Default settings
        extension_preferences_table = {
            c = {h = 2, hpp = 1},
            h = {c = 2, cpp = 1},
            cpp = {hpp = 2, h = 1},
            hpp = {cpp = 1, c = 2},
        },
        score_required_to_be_confident_match_is_found = 10
    }
}

function config.setup(user_preferences)
    user_preferences = user_preferences or {}
    for k, v in pairs(defaults) do
        if user_preferences[k] == nil then
            user_preferences[k] = v
        else
            for kk, vv in pairs(v) do
                if user_preferences[k][kk] == nil then
                    user_preferences[k][kk] = vv
                end
            end
        end
    end
    config.settings = user_preferences
end

return config
