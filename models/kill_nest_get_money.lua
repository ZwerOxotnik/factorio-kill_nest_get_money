---@class KNGM : module
local M = {}


--#region Constants
local match = string.match
local call = remote.call
--#endregion


--#region Settings
local income = settings.global["KNGM_income"].value
--#endregion


--#region Functions of events

local function on_entity_died(event)
	local entity = event.entity
	local force = event.force
	if force == entity.force then return end

	call("EasyAPI", "deposit_force_money", force, income)
end

local mod_settings = {
	["KNGM_income"] = function(value) income = value end,
}
local function on_runtime_mod_setting_changed(event)
	if event.setting_type ~= "runtime-global" then return end
	if not match(event.setting, "^KNGM_") then return end

	local f = mod_settings[event.setting]
	if f then f(settings.global[event.setting].value) end
end

--#endregion


--#region Pre-game stage

local function set_filters()
	local filters = {{filter = "type", type = "unit-spawner"}}
	script.set_event_filter(defines.events.on_entity_died, filters)
end

local function add_remote_interface()
	-- https://lua-api.factorio.com/latest/LuaRemote.html
	remote.remove_interface("kill_nest_get_money") -- For safety
	remote.add_interface("kill_nest_get_money", {})
end

M.on_init = set_filters
M.on_load = set_filters
M.add_remote_interface = add_remote_interface

--#endregion


M.events = {
	[defines.events.on_runtime_mod_setting_changed] = on_runtime_mod_setting_changed,
	[defines.events.on_entity_died] = function(event)
		pcall(on_entity_died, event)
	end
}

return M
