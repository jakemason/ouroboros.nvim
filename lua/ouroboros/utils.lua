config = require("ouroboros.config")

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

function M.switch_to_open_file_if_possible(file_path)
    if not config.settings.switch_to_open_pane_if_possible then
      return false
    end

    local windows = vim.api.nvim_list_wins()
    -- Normalize the target file path to be absolute
    local absolute_file_path = vim.fn.fnamemodify(file_path, ":p")
    for _, win in ipairs(windows) do
        local buf = vim.api.nvim_win_get_buf(win)
        local buf_path = vim.api.nvim_buf_get_name(buf)
        -- Normalize the buffer file path to be absolute
        local absolute_buf_path = vim.fn.fnamemodify(buf_path, ":p")
        if absolute_buf_path == absolute_file_path then
            vim.api.nvim_set_current_win(win)
            return true
        end
    end
    return false 
end

function M.find_highest_preference(extension)
    local preferences = config.settings.extension_preferences_table[extension]

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

function M.get_filename_score(path1, path2)
    -- We take the filename into account because otherwise we could sometimes open the wrong
    -- file if there were a similarly named file that came first alphabetically. Consider the case:
    --
    --      MyDirectory/Child/ArguablyMyFile.hpp
    --      MyDirectory/Child/ArguablyMyFile.cpp
    --      MyDirectory/Child/MyFile.hpp
    --      MyDirectory/Child/MyFile.cpp
    --
    -- Without taking filename into account, calling :Ouroboros from within MyFile.(c/h)pp would
    -- open ArguablyMyFile.(c/h)pp as we did not weight the filename at all, only the path to it.
    local _path1, filename1, _ext1 = M.split_filename(path1)
    local _path2, filename2, _ext2 = M.split_filename(path2)

    -- For now, I think we can just "add one" if the filename is an exact match and that's been good
    -- enough as a tiebreaker in every case I've seen so far.
    return (filename1 == filename2 and 1 or 0)
end

function M.get_extension_score(current_extension, file_extension)
    M.log(string.format("current_extension [%s], file_extension [%s]", current_extension, file_extension))
    local preferences = config.settings.extension_preferences_table[current_extension] or {}

    M.log(string.format("preferences[file_extension] = [%s]", preferences[file_extension]))
    return preferences[file_extension] or 0
end

function M.calculate_final_score(path1, path2, current_extension, file_extension)
    local path_similarity = M.calculate_similarity(path1, path2)
    local extension_score_weight = 10
    local extension_score = M.get_extension_score(current_extension, file_extension) * extension_score_weight
    local filename_score = M.get_filename_score(path1, path2)

   
    M.log(
      string.format("Path similarity: %s, Extension score: %d, Filename score: %d", 
                      path_similarity, 
                      extension_score, 
                      filename_score
                    )
    )

    return path_similarity + extension_score + filename_score
end

return M
