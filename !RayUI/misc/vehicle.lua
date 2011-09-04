--------------------------------------------------------------------------
-- move vehicle indicator
--------------------------------------------------------------------------
local R, C, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

local once = false
hooksecurefunc(VehicleSeatIndicator,"SetPoint",function(_,_,parent) -- vehicle seat indicator
    if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
		VehicleSeatIndicator:ClearAllPoints()
		VehicleSeatIndicator:Point("BOTTOMRIGHT", Minimap, "TOPRIGHT", 0, 10)
		-- VehicleSeatIndicator:Point("CENTER", UIParent, "CENTER", 0, 0)
		VehicleSeatIndicator:SetScale(0.8)
		if once == false then
			R.CreateMover(VehicleSeatIndicator, "VehicleSeatMover", "载具指示锚点")	
			once = true
		end
    end
end)