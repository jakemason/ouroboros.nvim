local scan = require("plenary.scandir")
utils = require("ouroboros.utils")
config = require("ouroboros.config")

local M = {}

-- used as cache to skip file searching if we already found it once
local dict = {}

-- needs to be exposed on the "main" plugin level then
-- we can defer to the functionality to config itself
function M.setup(user_settings)
  config.setup(user_settings)
end

function M.switch()
    local current_file = vim.api.nvim_eval('expand("%:p")')
    local path, filename, current_file_extension = utils.split_filename(current_file)


    utils.log("Currently working with:")
    utils.log("Full Path: " .. path)
    utils.log("Filename: " .. filename)
    utils.log("current_file_extension: " .. current_file_extension)

    if(utils.find_highest_preference(current_file_extension) == nil) then
        utils.log("Ouroboros doesn't work on a file ending in: ." .. current_file_extension .. ". Aborting.")
           return
    end

    -- prep needed variables     local match = ""
    local scores = {}
    local found_match = false
    local sorted_matching_files = {}
    local match = ""

    -- check cache to see if the file was already found once
    if dict[filename .. current_file_extension] then
        local file = io.open(dict[filename .. current_file_extension], 'r')
        -- check if file wasn't moved or deleted under our feet
        if file ~= nil then
            found_match = true
            match = dict[filename .. current_file_extension]
        end
    end

    -- only do search logic if we did not already find a match earlier
    if not found_match then
        -- these are our scan options, refer to plenary.scan_dir for the options available here
        local scan_opts = {
            respect_gitignore = true,
            -- Starts with anything but explicitly ends in "filename." (note the period is included!) 
            search_pattern = "^.*" .. filename .. "%..*$";
        }

        -- search 1) in the same path as the original file, and then 2) in the project tree if we still haven't found a match
        for _, p in ipairs({path, '.'}) do
        -- look for files that meet our above criteria
            local matching_files = scan.scan_dir(p, scan_opts)

            local next = next -- This is just an efficiency trick in Lua 
            -- to quickly evaluate if a table is empty

            -- if our results table isn't empty
            if next(matching_files) ~= nil then
                for _, file_path in ipairs(matching_files) do
                    local _, _, file_extension = utils.split_filename(file_path)
                    local score = utils.calculate_final_score(current_file, file_path, current_file_extension, file_extension)
                    table.insert(scores, {path = file_path, score = score})
                end

                table.sort(scores, function(a, b) return a.score > b.score end)

                for _, item in ipairs(scores) do
                    table.insert(sorted_matching_files, item.path)
                end

                for _, item in ipairs(scores) do
                    utils.log(string.format("File: %s, Score: %s", item.path, item.score))
                end

                found_match = scores[1].score >= config.settings.score_required_to_be_confident_match_is_found
                if found_match then
                    match = scores[1].path
                    -- store found file 
                    dict[filename .. current_file_extension] = match
                    break
                end
            end
        end
    end

    -- If we're confident enough we've found the file's counterpart, then we just start editing
    -- that file
    if(found_match) then
        if not utils.switch_to_open_file_if_possible(match) then
            -- If the file wasn't open in any window, open it in the current window
            utils.log("Match found! Executing command: 'edit " .. match .. "'")
            vim.cmd("edit " .. match)
        else
            utils.log("Switched to already open file.")
        end
    else
        -- Failed to find any matches, report this as a problem even when not in debug mode and
        -- offer the user an opportunity to create the file
        local could_create_at = path .. filename .. "." .. utils.find_highest_preference(current_file_extension)
        vim.ui.input({prompt = "Failed to find a matching file, would you like to create at: ", default = could_create_at}, function(input)
            if (input == nil) then
                return false
            else
                local path, filename, extension = utils.split_filename(input)
                vim.fn.mkdir(path, "p")
                local fname = input
                vim.cmd("edit " .. fname)
                -- store created file 
                dict[filename .. current_file_extension] = fname
                return true
            end
        end)
    end
    return sorted_matching_files
end

return M
