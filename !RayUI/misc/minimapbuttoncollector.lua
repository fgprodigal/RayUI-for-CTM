local BlackList = { 
	["MiniMapTracking"] = true,
	["MiniMapVoiceChatFrame"] = true,
	["MiniMapWorldMapButton"] = true,
	["MiniMapLFGFrame"] = true,
	["MinimapZoomIn"] = true,
	["MinimapZoomOut"] = true,
	["MiniMapMailFrame"] = true,
	["MiniMapBattlefieldFrame"] = true,
	["MinimapBackdrop"] = true,
	["GameTimeFrame"] = true,
	["TimeManagerClockButton"] = true,
	["FeedbackUIButton"] = true,
}

local buttons = {}
local MBCF = CreateFrame("Frame", "MinimapButtonCollectFrame", UIParent)
MBCF:SetPoint("BOTTOMRIGHT", -26, 5)
MBCF:SetSize(200, 20)
MBCF:SetFrameStrata("BACKGROUND")
MBCF:SetFrameLevel(1)
MBCF.bg = MBCF:CreateTexture(nil, "BACKGROUND")
MBCF.bg:SetAllPoints(MBCF)
MBCF.bg:SetTexture(0, 0, 0, 1)
MBCF.bg:SetGradientAlpha("HORIZONTAL", 0, 0, 0, 0, 0, 0, 0, .6)
MBCF:SetAlpha(0)

local MinimapButtonCollect = CreateFrame("Frame")
MinimapButtonCollect:RegisterEvent("PLAYER_ENTERING_WORLD")
MinimapButtonCollect:SetScript("OnEvent", function(self)
	for i, child in ipairs({Minimap:GetChildren()}) do
		if not BlackList[child:GetName()] then
			if child:GetObjectType() == 'Button' and child:GetNumRegions() >= 3 then
				-- child:CreateShadow("Background")
				child:ClearAllPoints()
				child:SetParent("MinimapButtonCollectFrame")
				child:SetPoint("RIGHT", MinimapButtonCollectFrame, "RIGHT", -5 - #buttons * 30 , 0)
				child.SetPoint = function() end
				for j = 1, child:GetNumRegions() do
					if select(j, child:GetRegions()):GetTexture():find("Highlight") then
						select(j, child:GetRegions()):Kill()
					end
				end
				tinsert(buttons, child)
			end
		end
	end
	if #buttons == 0 then 
		MBCF:Hide() 
	else
		for _, child in ipairs(buttons) do
			child:HookScript("OnEnter", function()
				UIFrameFadeIn(MBCF, .5, MBCF:GetAlpha(), 1)
			end)
			child:HookScript("OnLeave", function()
				UIFrameFadeOut(MBCF, .5, MBCF:GetAlpha(), 0)
			end)
		end
	end
end)

MBCF:SetScript("OnEnter", function(self)
	UIFrameFadeIn(self, .5, self:GetAlpha(), 1)
end)

Minimap:HookScript("OnEnter", function()
	UIFrameFadeIn(MBCF, .5, MBCF:GetAlpha(), 1)
end)

MBCF:SetScript("OnLeave", function(self)
	UIFrameFadeOut(self, .5, self:GetAlpha(), 0)
end)

Minimap:HookScript("OnLeave", function()
	UIFrameFadeOut(MBCF, .5, MBCF:GetAlpha(), 0)
end)