local scan = require("plenary.scandir")
local utils = require("ouroboros.utils")

local M = {}

function M.list()

    local current_file = vim.api.nvim_eval('expand("%:p")')
    local path, filename, extension = utils.split_filename(current_file)

    utils.log("Currently working with:")
    utils.log("Full Path: " .. path)
    utils.log("Filename: " .. filename)
    utils.log("Extension: " .. extension)

    if((extension ~= "cpp") and (extension ~= "hpp") and
       (extension ~= "c") and (extension ~= "h")) then
        utils.log("Ouroboros doesn't work on a file ending in: " .. extension .. ". Aborting.")
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
        local desired_target = nil

        -- TODO: This only checks hpp <==> cpp and h <==> c, we conceivably want to
        -- support cpp <==> h, hpp and h <==> cpp, c  etc, etc
        if(extension == "cpp" or extension == "hpp") then
            desired_target = utils.ternary(extension == "cpp", "hpp", "cpp") 
        elseif(extension == "c" or extension == "h") then
            desired_target = utils.ternary(extension == "c", "h", "c") 
        end
       
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
