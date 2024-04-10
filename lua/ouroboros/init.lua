local scan = require("plenary.scandir")
utils = require("ouroboros.utils")
config = require("ouroboros.config")

local M = {}

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

    -- these are our scan options, refer to plenary.scan_dir for the options available here
    local scan_opts = {
        respect_gitignore = true,
        -- Starts with anything but explicitly ends in "filename." (note the period is included!) 
        search_pattern = "^.*" .. filename .. "%..*$";
    }

    -- look for files that meet our above criteria
    local matching_files = scan.scan_dir('.', scan_opts)

    local next = next -- This is just an efficiency trick in Lua 
                      -- to quickly evaluate if a table is empty
                      
    -- if our results table isn't empty
    if next(matching_files) ~= nil then
       local scores = {}
        for _, file_path in ipairs(matching_files) do
            local _, _, file_extension = utils.split_filename(file_path)
            local score = utils.calculate_final_score(current_file, file_path, current_file_extension, file_extension)
            table.insert(scores, {path = file_path, score = score})
        end

        table.sort(scores, function(a, b) return a.score > b.score end)

        local sorted_matching_files = {}
        for _, item in ipairs(scores) do
            table.insert(sorted_matching_files, item.path)
        end

        for _, item in ipairs(scores) do
          utils.log(string.format("File: %s, Score: %s", item.path, item.score))
        end

        found_match = scores[1].score >= config.settings.score_required_to_be_confident_match_is_found

        -- If we're confident enough we've found the file's counterpart, then we just start editing
        -- that file
        if(found_match) then 
            local match = scores[1].path;
            utils.log("Match path: " .. match);
            utils.log("Match found! Executing command: 'edit " .. match .."'")
            local command_string = "edit " .. match
            vim.cmd(command_string)
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
              vim.cmd("edit " .. input)
              return true
            end
          end)
        end
    end
    return sorted_matching_files
end

return M
