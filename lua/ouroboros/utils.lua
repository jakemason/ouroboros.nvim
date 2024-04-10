local M = {}

-- logs info to :messages if ouroboros_debug is true
function M.log(v)
    if vim.g.ouroboros_debug ~= 0 then
        print(v)
    end
end

-- quick and dirty means of doing a ternary in Lua
function M.ternary(condition, T, F)
    if condition then return T else return F end
end

-- Returns the Path, Filename, and Extension as 3 values
function M.split_filename(file)
    local path, filename, extension = string.match(file, "(.-)([^\\/]-)([^\\/%.]+)$")

    -- pop the "." off the end of the filename - wouldn't need if my regex were better
    filename = filename:sub(1,-2)

    return path, filename, extension
end

function M.split_path_into_directories(path)
    local dirs = {}
    local sep = package.config:sub(1,1) -- Get the directory separator from package.config for current OS
    for dir in path:gmatch("([^" .. sep .. "]+)") do
        table.insert(dirs, dir)
    end
    return dirs
end

function M.calculate_similarity(path1, path2)
    local dirs1 = M.split_path_into_directories(path1)
    local dirs2 = M.split_path_into_directories(path2)

    local count = 0
    local length1 = #dirs1
    local length2 = #dirs2
    -- Start comparing from the last element (closest to the file name) backwards
    for i = 0, math.min(length1, length2) - 1 do
        if dirs1[length1 - i] == dirs2[length2 - i] then
            count = count + 1
        end
    end
    M.log(string.format("Path 1: %s, Path 2: %s, Score %d", path1, path2, count))
    return count
end

function M.find_highest_preference(extension, preferences_table)
    local preferences = preferences_table[extension]

    if not preferences or next(preferences) == nil then
        return nil 
    end

    local highest_score = 0
    local preferred_extension = nil
    for ext, score in pairs(preferences) do
        if score > highest_score then
            highest_score = score
            preferred_extension = ext
        end
    end

    return preferred_extension, highest_score
end

function M.get_extension_score(current_extension, file_extension, extension_preferences_table)
    M.log(string.format("current_extension [%s], file_extension [%s]", current_extension, file_extension))
    local preferences = extension_preferences_table[current_extension] or {}

    M.log(string.format("preferences[file_extension] = [%s]", preferences[file_extension]))
    return preferences[file_extension] or 0
end

function M.calculate_final_score(path1, path2, current_extension, file_extension, extension_preferences_table)
    local path_similarity = M.calculate_similarity(path1, path2)
    local extension_score_weight = 10
    local extension_score = M.get_extension_score(current_extension, file_extension, extension_preferences_table) * extension_score_weight
   
    M.log(string.format("Path similarity: %s, Extension score: %d", path_similarity, extension_score))
    return path_similarity + extension_score
end

return M
