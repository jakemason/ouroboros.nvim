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

    if(vim.g.ouroboros_debug) then
        print(scan_opts.search_pattern)
        print(current_file)
        print(path,filename,extension)
        utils.dump(matching_files)
    end


    local next = next -- This is just an efficiency trick in Lua 
                      -- to quickly evaluate if a table is empty
    -- if we found some results
    if next(matching_files) ~= nil then
        -- TODO: Filter files based on extension
        print(matching_files[1])
        local command_string = "edit " .. matching_files[1]
        print(command_string)
        vim.cmd(command_string)
    elseif(vim.g.ouroboros_debug) then
        print("Ouroboros failed to find matching files for " .. scan_opts.search_pattern)
    end
    return matching_files
end

return M
