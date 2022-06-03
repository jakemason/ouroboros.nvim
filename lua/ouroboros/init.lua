local scan = require("plenary.scandir")
utils = require("ouroboros.utils")

local M = {}

function M.list()
    local current_file = vim.api.nvim_eval('expand("%:p")')
    local path, filename, extension = utils.split_filename(current_file)

    utils.log("Currently working with:")
    utils.log("Full Path: " .. path)
    utils.log("Filename: " .. filename)
    utils.log("Extension: " .. extension)

    if((extension ~= "cpp") and (extension ~= "hpp") and
       (extension ~= "c") and (extension ~= "h") and
       (extension ~= "cc")) then
        utils.log("Ouroboros doesn't work on a file ending in: ." .. extension .. ". Aborting.")
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
        local desired_extension = nil
        
        -- First pass searches for exactly hpp <==> cpp, h <==> c, cc <==> h
        if(extension == "cpp" or extension == "hpp") then
            desired_extension = utils.ternary(extension == "cpp", "hpp", "cpp") 
        elseif(extension == "c" or extension == "h") then
            desired_extension = utils.ternary(extension == "c", "h", "c")
        elseif(extension == "cc") then
            desired_extension = "h"
        end
       
        utils.log("Looking for an extension of: " .. desired_extension)
        local found_match = utils.find(matching_files, filename, extension, desired_extension)
        if(found_match) then return end

        -- Second pass searches for h <==> cpp, c <==> hpp, cc <==> hpp
        utils.log("Failed to find a perfect matched_extension counterpart")
        if(desired_extension == "cpp" or desired_extension == "hpp") then
            desired_extension = utils.ternary(desired_extension == "cpp", "c", "h") 
        elseif(desired_extension == "c" or desired_extension == "h") then
            desired_extension = utils.ternary(desired_extension == "c", "cpp", "hpp") 
        end

        utils.log("Now searching for the less likely extension: ." .. desired_extension)
        local found_match = utils.find(matching_files, filename, extension, desired_extension)
        if(found_match) then return end

        -- Third pass searches for cc <==> hpp, h
        utils.log("Failed to find a perfect matched_extension counterpart")
        if(desired_extension == "c" or desired_extension == "cpp") then
            desired_extension = "cc"
        elseif(extension == "cc") then
            desired_extension = "hpp"
        end

        utils.log("Now searching for the less likely extension: ." .. desired_extension)
        local found_match = utils.find(matching_files, filename, extension, desired_extension)
        if(found_match) then return end

        -- Failed to find any matches, report this as a problem even when not in debug mode
        print("Ouroboros failed to find matching files for " .. filename .. "." .. extension)
    end
    return matching_files
end

return M
