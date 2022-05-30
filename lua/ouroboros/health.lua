local health_start = vim.fn["health#report_start"]
local health_ok = vim.fn["health#report_ok"]
local health_error = vim.fn["health#report_error"]

local required = {
  { lib = "plenary", optional = false },
}

local function lualib_is_installed(lib_name)
  local is_installed, _ = pcall(require, lib_name)
  return is_installed
end

local M = {}

function M.check()
  health_start "Required Dependencies"
  for _, plugin in ipairs(required) do
    if lualib_is_installed(plugin.lib) then
      health_ok(plugin.lib .. " installed.")
    else
      health_error(plugin.lib .. " not found. Ouroboros will not work without it!")
    end
  end
end

return M
