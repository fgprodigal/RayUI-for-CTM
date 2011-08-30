local R, C, DB = unpack(select(2, ...))

local TEST = function(msg)
	R.isHealer = not R.isHealer
	R.Update_All()
	R.Update_ActionBar()
	UIParent:SetAlpha(0)
	R.Delay(0.5, function() UIFrameFadeIn(UIParent,2,0,1) end)
end
SlashCmdList.TEST = TEST
SLASH_TEST1 = "/test"

local CheckHealer = CreateFrame("Frame")
CheckHealer:RegisterEvent("PLAYER_ENTERING_WORLD")
CheckHealer:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
CheckHealer:RegisterEvent("PLAYER_TALENT_UPDATE")
CheckHealer:RegisterEvent("CHARACTER_POINTS_CHANGED")
CheckHealer:SetScript("OnEvent", function(self, event)
	R.Delay(0.5, function() 
		R.Update_All()
		R.Update_ActionBar()
	end)
	if event == "ACTIVE_TALENT_GROUP_CHANGED" then
		UIParent:SetAlpha(0)
		R.Delay(0.5, function() UIFrameFadeIn(UIParent,2,0,1) end)
	end
end)