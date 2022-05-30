local M = {}

function M.log(v)
    if vim.g.ouroboros_debug ~= 0 then
        print(v)
    end
end

function M.ternary(condition, T, F)
    if condition then return T else return F end
end

function M.split_filename(file)
    -- Returns the Path, Filename, and Extension as 3 values
    local path, filename, extension = string.match(file, "(.-)([^\\]-)([^\\%.]+)$")
    -- pop the "." off the end of the filename - wouldn't need if my regex were better
    filename = filename:sub(1,-2)
    return path, filename, extension
end

function M.dump(arr, indentLevel)
    local str = ""
    local indentStr = "#"

    if(indentLevel == nil) then
        print(print_r(arr, 0))
        return
    end

    for i = 0, indentLevel do
        indentStr = indentStr.."\t"
    end

    for index,value in pairs(arr) do
        if type(value) == "table" then
            str = str..indentStr..index..": \n"..print_r(value, (indentLevel + 1))
        else 
            str = str..indentStr..index..": "..value.."\n"
        end
    end
    return str
end


return M
