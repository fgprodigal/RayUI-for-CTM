--------------------------------------------------------------------------
-- move vehicle indicator
--------------------------------------------------------------------------
local R, C, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

hooksecurefunc(VehicleSeatIndicator,"SetPoint",function(_,_,parent) -- vehicle seat indicator
    if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
		VehicleSeatIndicator:ClearAllPoints()
		if VehicleSeatMover then
			VehicleSeatIndicator:Point("BOTTOMRIGHT", VehicleSeatMover, "BOTTOMRIGHT", 0, 0)
		else
			VehicleSeatIndicator:Point("BOTTOMRIGHT", Minimap, "TOPRIGHT", 0, 10)
			R.CreateMover(VehicleSeatIndicator, "VehicleSeatMover", "载具指示锚点")	
		end
		VehicleSeatIndicator:Point("BOTTOMRIGHT", Minimap, "TOPRIGHT", 0, 10)
    end
end)