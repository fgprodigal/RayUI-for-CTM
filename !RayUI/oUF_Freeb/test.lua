local R, C, DB = unpack(select(2, ...))

local SPAWN = function(msg)
	C["ouf"].HealthcolorClass = false
	-- C.ouf.HealthcolorClass = true
	R.Update_All()
end
SlashCmdList.SPAWN = SPAWN
SLASH_SPAWN1 = "/spawn"

local SPAW = function(msg)
	C["ouf"].HealthcolorClass = true
	-- C.ouf.HealthcolorClass = true
	R.Update_All()
end
SlashCmdList.SPAW = SPAW
SLASH_SPAW1 = "/spaw"

local CheckHealer = CreateFrame("Frame")
CheckHealer:RegisterEvent("PLAYER_ENTERING_WORLD")
CheckHealer:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
CheckHealer:RegisterEvent("PLAYER_TALENT_UPDATE")
CheckHealer:RegisterEvent("CHARACTER_POINTS_CHANGED")
CheckHealer:SetScript("OnEvent", function(self, event)
	R.Update_All()
	R.Update_ActionBar()
	if event == "ACTIVE_TALENT_GROUP_CHANGED" then
		UIParent:SetAlpha(0)
		R.Delay(0.5, function() UIFrameFadeIn(UIParent,2,0,1) end)
	end
end)