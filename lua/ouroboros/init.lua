local scan = require("plenary.scandir")
local utils = require("ouroboros.utils")

local M = {}

-- get current filename and extension
-- get all files under path that match that filename
-- open the filename with the opposite extension h <==> c, hpp <==> cpp
-- -- if more than one file has the same filename, present a list and let user pick?

function M.list()

    local current_file = vim.api.nvim_eval('expand("%:p")')
    local path, filename, extension = utils.split_filename(current_file)

    local development = true
    if(not development) then
        if((extension ~= "cpp") and (extension ~= "hpp") and
            (extension ~= "c") and (extension ~= "h")) then
            return
        end
    end

    local scan_opts = {
        respect_gitignore = true,
        -- Starts with anything but explicitly ends in "filename."   
        search_pattern = "^.*" .. filename .. "%..*$";
    }
    print(scan_opts.search_pattern)
    local matching_files = scan.scan_dir('.', scan_opts)
    print(current_file)
    print(path,filename,extension)
    utils.dump(matching_files)
    return matching_files
end

return M
