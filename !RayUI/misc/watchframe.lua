local R, C, L, DB = unpack(select(2, ...))

local RayUIWatchFrame = CreateFrame("Frame", nil, UIParent)
local RayUIWatchFrameHolder = CreateFrame("Frame", nil, UIParent)
RayUIWatchFrameHolder:SetWidth(330)
RayUIWatchFrameHolder:SetHeight(22)
RayUIWatchFrameHolder:SetPoint("RIGHT", UIParent, "RIGHT", -80, 290)
R.CreateMover(RayUIWatchFrameHolder, "WatchFrameMover", L["任务追踪锚点"], true)

local function init()
	RayUIWatchFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
	RayUIWatchFrame:RegisterEvent("CVAR_UPDATE")
	RayUIWatchFrame:SetScript("OnEvent", function(_,_,cvar,value)
		SetCVar("watchFrameWidth", 1)
		RayUIWatchFrame:SetWidth(330)
		InterfaceOptionsObjectivesPanelWatchFrameWidth:Hide()
	end)
	RayUIWatchFrame:ClearAllPoints()
	RayUIWatchFrame:SetPoint("TOP", RayUIWatchFrameHolder, "TOP", 0, 5)
end

local function setup()	
	local screenheight = GetScreenHeight()
	RayUIWatchFrame:SetHeight(screenheight / 1.6)
	
	RayUIWatchFrame:SetWidth(330)
	
	WatchFrame:SetParent(RayUIWatchFrame)
	WatchFrame:SetClampedToScreen(false)
	WatchFrame:ClearAllPoints()
	WatchFrame.ClearAllPoints = function() end
	WatchFrame:SetPoint("TOPLEFT", 32,-2.5)
	WatchFrame:SetPoint("BOTTOMRIGHT", 4,0)
	WatchFrame.SetPoint = R.dummy

	WatchFrameTitle:SetParent(RayUIWatchFrame)
	WatchFrameCollapseExpandButton:SetParent(RayUIWatchFrame)
	WatchFrameCollapseExpandButton.Disable = R.dummy
end

local f = CreateFrame("Frame")
f:Hide()
f.elapsed = 0
f:SetScript("OnUpdate", function(self, elapsed)
	f.elapsed = f.elapsed + elapsed
	if f.elapsed > .5 then
		setup()
		f:Hide()
	end
end)

RayUIWatchFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
RayUIWatchFrame:SetScript("OnEvent", function()
	init()
	f:Show()
end)

--进出副本自动收放任务追踪
local autocollapse = CreateFrame("Frame")
autocollapse:RegisterEvent("ZONE_CHANGED_NEW_AREA")
autocollapse:RegisterEvent("PLAYER_ENTERING_WORLD")
autocollapse:SetScript("OnEvent", function(self)
   if IsInInstance() then
      WatchFrame.userCollapsed = true
      WatchFrame_Collapse(WatchFrame)
   else
      WatchFrame.userCollapsed = nil
      WatchFrame_Expand(WatchFrame)
   end
end)