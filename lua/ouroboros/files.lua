local scan = require("plenary.scandir")
local utils = require("ouroboros.utils")

local M = {}


function M.list()
    local all_files = scan.scan_dir('.')
    local current_file = vim.api.nvim_eval('expand("%:p")')
    local path, file, extension = utils.split_filename(current_file)
    print(current_file)
    print(path,file,extension)
--  utils.dump(all_files)
    return all_files
end

return M
