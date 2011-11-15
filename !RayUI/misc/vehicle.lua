--------------------------------------------------------------------------
-- move vehicle indicator
--------------------------------------------------------------------------
local R, C, L, DB = unpack(select(2, ...))

hooksecurefunc(VehicleSeatIndicator,"SetPoint",function(_,_,parent) -- vehicle seat indicator
    if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
		VehicleSeatIndicator:ClearAllPoints()
		if VehicleSeatMover then
			VehicleSeatIndicator:Point("LEFT", VehicleSeatMover, "LEFT", 0, 0)
		else
			VehicleSeatIndicator:Point("LEFT", UIParent, "LEFT", 40, 120)
			R.CreateMover(VehicleSeatIndicator, "VehicleSeatMover", L["载具指示锚点"])	
		end
    end
end)