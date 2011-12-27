----------------------------------------------------------------------------
-- Copyrights Elv
----------------------------------------------------------------------------
local R, C, L, DB = unpack(select(2, ...))

--Convert default database
for group,options in pairs(DB) do
	if not C[group] then C[group] = {} end
	for option, value in pairs(options) do
		C[group][option] = value
	end
end

if IsAddOnLoaded("!RayUI_Config") then
	local RayUIConfig = LibStub("AceAddon-3.0"):GetAddon("RayUIConfig")
	RayUIConfig:Load()

	--Load settings from RayUIConfig database
	for group, options in pairs(RayUIConfig.db.profile) do
		if C[group] then
			for option, value in pairs(options) do
				C[group][option] = value
			end
		end
	end
	
	R.SavePath = RayUIConfig.db.profile
end