local scan = require("plenary.scandir")
local utils = require("ouroboros.utils")

local M = {}

-- General Plan:
-- get current filename and extension
-- get all files under path that match that filename
-- open the filename with the opposite extension h <==> c, hpp <==> cpp
-- -- if more than one file has the same filename, present a list and let user pick?

function M.list()

    local current_file = vim.api.nvim_eval('expand("%:p")')
    local path, filename, extension = utils.split_filename(current_file)

    if((extension ~= "cpp") and (extension ~= "hpp") and
       (extension ~= "c") and (extension ~= "h")) then
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
    -- if we found some results
    if next(matching_files) ~= nil then
        local desired_target = nil

        -- TODO: This only checks hpp <==> cpp and h <==> c, we conceivably want to
        -- support cpp <==> h, hpp and h <==> cpp, c  etc, etc
        if(extension == "cpp" or extension == "hpp") then
            desired_target = utils.ternary(extension == "cpp", "hpp", "cpp") 
        elseif(extension == "c" or extension == "h") then
            desired_target = utils.ternary(extension == "c", "h", "c") 
        end
        -- TODO: Filter files based on extension
       
        utils.log("Looking for an extension of: " .. desired_target)

        for index, value in ipairs(matching_files) do
            local path, filename, extension = utils.split_filename(value)

            if extension == desired_target then
                utils.log("Match found! Executing command: 'edit " .. matching_files[index] .."'")
                local command_string = "edit " .. matching_files[index]
                vim.cmd(command_string)
                return
            end
        end

        print("Ouroboros failed to find matching files for " .. filename .. "." .. extension)
    end
    return matching_files
end

return M
