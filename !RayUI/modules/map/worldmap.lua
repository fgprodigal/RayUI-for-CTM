local R, C, L, DB = unpack(select(2, ...))
if not C["worldmap"].enable then return end

local mpos = {"CENTER",UIParent,"CENTER",0,65}		-- set position for locked map
local EJbuttonWidth, EJbuttonHeight, EJbuttonImageWidth, EJbuttonImageHeigth

--EJButtonScale
hooksecurefunc("EncounterJournal_AddMapButtons",function()
	if EJMapButton1 and not EJbuttonWidth then
		EJbuttonWidth = EJbuttonWidth or EJMapButton1:GetWidth()
		EJbuttonHeight = EJbuttonHeight or EJMapButton1:GetHeight()
		EJbuttonImageWidth = EJbuttonImageWidth or EJMapButton1.bgImage:GetWidth()
		EJbuttonImageHeigth = EJbuttonImageHeigth or EJMapButton1.bgImage:GetHeight()
	end
	if WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE then
		local index = 1
		while _G["EJMapButton"..index] do
			_G["EJMapButton"..index]:SetSize(EJbuttonWidth * C["worldmap"].ejbuttonscale, EJbuttonHeight * C["worldmap"].ejbuttonscale)
			_G["EJMapButton"..index].bgImage:SetSize(EJbuttonImageWidth * C["worldmap"].ejbuttonscale,EJbuttonImageHeigth * C["worldmap"].ejbuttonscale)
			index = index + 1
		end
	else
		local index = 1
		while _G["EJMapButton"..index] do
			_G["EJMapButton"..index]:SetSize(EJbuttonWidth, EJbuttonHeight)
			_G["EJMapButton"..index].bgImage:SetSize(EJbuttonImageWidth,EJbuttonImageHeigth)
			index = index + 1
		end
		
	end
end)
---------------- > Coordinates functions
local player, cursor
local function gen_string(point, X, Y)
	local t = WorldMapButton:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	t:SetFont("Fonts\\ARIALN.TTF",14)
	t:SetPoint('BOTTOMLEFT', WorldMapButton, point, X, Y)
	t:SetJustifyH('LEFT')
	return t
end
local function Cursor()
	local left, top = WorldMapDetailFrame:GetLeft() or 0, WorldMapDetailFrame:GetTop() or 0
	local width, height = WorldMapDetailFrame:GetWidth(), WorldMapDetailFrame:GetHeight()
	local scale = WorldMapDetailFrame:GetEffectiveScale()
	local x, y = GetCursorPosition()
	local cx = (x/scale - left) / width
	local cy = (top - y/scale) / height
	if cx < 0 or cx > 1 or cy < 0 or cy > 1 then return end
	return cx, cy
end
local function OnUpdate(player, cursor)
	local cx, cy = Cursor()
	local px, py = GetPlayerMapPosition("player")
	if cx and cy then
		cursor:SetFormattedText(MOUSE_LABEL..': %.2d,%.2d', 100 * cx, 100 * cy)
	else
		cursor:SetText("")
	end
	if px == 0 or py == 0 then
		player:SetText("")
	else
		player:SetFormattedText(PLAYER..': %.2d,%.2d', 100 * px, 100 * py)
	end
	-- gotta change coords position for maximized world map
	if WorldMapQuestScrollFrame:IsShown() then
		player:SetPoint('BOTTOMLEFT', WorldMapButton, 'BOTTOM',-120,0)
		cursor:SetPoint('BOTTOMLEFT', WorldMapButton, 'BOTTOM',50,0)
	else
		player:SetPoint('BOTTOMLEFT', WorldMapButton, 'BOTTOM',-120,-22)
		cursor:SetPoint('BOTTOMLEFT', WorldMapButton, 'BOTTOM',50,-22)
	end
end
local function UpdateCoords(self, elapsed)
	self.elapsed = (self.elapsed or 0.1) - elapsed
	if self.elapsed <= 0 then
		self.elapsed = 0.1
		OnUpdate(player, cursor)
	end
end
local function gen_coords(self)
	if player or cursor then return end
	player = gen_string('BOTTOM',-120,-22)
	cursor = gen_string('BOTTOM',50,-22)
end

---------------- > Moving/removing world map elements
if C["worldmap"].scale==1 then C["worldmap"].scale = 0.99 end -- dirty hack to prevent 'division by zero'!
local w = CreateFrame"Frame"
w:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		SetCVar("questPOI", 1)
		SetCVar("lockedWorldMap", 0)
		gen_coords(self)
		local cond = false
		BlackoutWorld:Hide()
		BlackoutWorld.Show = R.dummy
		BlackoutWorld.Hide = R.dummy
		WORLDMAP_RATIO_MINI = C["worldmap"].scale
		WORLDMAP_WINDOWED_SIZE = C["worldmap"].scale 
		WORLDMAP_SETTINGS.size = C["worldmap"].scale 
		WorldMapBlobFrame.Show = R.dummy
		WorldMapBlobFrame.Hide = R.dummy
		WorldMapQuestPOI_OnLeave = function()
			WorldMapTooltip:Hide()
		end
		WorldMap_ToggleSizeDown()
		for i = 1,40 do
			local ri = _G["WorldMapRaid"..i]
			ri:SetWidth(C["worldmap"].partymembersize)
			ri:SetHeight(C["worldmap"].partymembersize)
		end
		for i = 1,4 do
			local ri = _G["WorldMapParty"..i]
			ri:SetWidth(C["worldmap"].partymembersize)
			ri:SetHeight(C["worldmap"].partymembersize)
		end
		if FeedbackUIMapTip then 
			FeedbackUIMapTip:Hide()
			FeedbackUIMapTip.Show = R.dummy
		end
	elseif event == "PLAYER_REGEN_DISABLED" then
		WorldMapFrameSizeUpButton:Disable()
		WorldMap_ToggleSizeDown()
		WorldMapBlobFrame:DrawBlob(WORLDMAP_SETTINGS.selectedQuestId, false)
		WorldMapBlobFrame:DrawBlob(WORLDMAP_SETTINGS.selectedQuestId, true)
	elseif event == "PLAYER_REGEN_ENABLED" then
		WorldMapFrameSizeUpButton:Enable()
	elseif event == "WORLD_MAP_UPDATE" then
		if (GetNumDungeonMapLevels() == 0) then
			WorldMapLevelUpButton:Hide()
			WorldMapLevelDownButton:Hide()
		else
			WorldMapLevelUpButton:Show()
			WorldMapLevelUpButton:ClearAllPoints()
			WorldMapLevelUpButton:SetPoint("TOPLEFT", WorldMapFrameCloseButton, "BOTTOMLEFT", 8, 8)
			WorldMapLevelUpButton:SetFrameStrata("MEDIUM")
			WorldMapLevelUpButton:SetFrameLevel(100)
			WorldMapLevelUpButton:SetParent("WorldMapFrame")
			WorldMapLevelDownButton:ClearAllPoints()
			WorldMapLevelDownButton:Show()
			WorldMapLevelDownButton:SetPoint("TOP", WorldMapLevelUpButton, "BOTTOM",0,-2)
			WorldMapLevelDownButton:SetFrameStrata("MEDIUM")
			WorldMapLevelDownButton:SetFrameLevel(100)
			WorldMapLevelDownButton:SetParent("WorldMapFrame")
		end
	end
end)
w:RegisterEvent("PLAYER_ENTERING_WORLD")
w:RegisterEvent("WORLD_MAP_UPDATE")
w:RegisterEvent("PLAYER_REGEN_DISABLED")
w:RegisterEvent("PLAYER_REGEN_ENABLED")

WorldMapFrame.backdrop = CreateFrame("Frame", nil, WorldMapFrame)
WorldMapFrame.backdrop:Point("TOPLEFT", -2, 2)
WorldMapFrame.backdrop:Point("BOTTOMRIGHT", 2, -2)
R.SetBD(WorldMapFrame.backdrop)
WorldMapFrame.backdrop:SetFrameLevel(0)

WorldMapDetailFrame.backdrop = CreateFrame("Frame", nil, WorldMapDetailFrame)
R.SetBD(WorldMapDetailFrame.backdrop)
WorldMapDetailFrame.backdrop:Point("TOPLEFT", -2, 2)
WorldMapDetailFrame.backdrop:Point("BOTTOMRIGHT", 2, -2)
WorldMapDetailFrame.backdrop:SetFrameLevel(WorldMapDetailFrame:GetFrameLevel() - 2)
	
R.ReskinDropDown(WorldMapZoneMinimapDropDown)
R.ReskinDropDown(WorldMapContinentDropDown)
R.ReskinDropDown(WorldMapZoneDropDown)

R.ReskinDropDown(WorldMapShowDropDown)	
WorldMapShowDropDown:ClearAllPoints()
WorldMapShowDropDown:SetPoint("TOPRIGHT", WorldMapButton, "BOTTOMRIGHT", 18, 2)

R.ReskinCheck(WorldMapQuestShowObjectives)
R.Reskin(WorldMapZoomOutButton)
WorldMapZoomOutButton:Point("LEFT", WorldMapZoneDropDown, "RIGHT", 0, 4)
WorldMapLevelUpButton:Point("TOPLEFT", WorldMapLevelDropDown, "TOPRIGHT", -2, 8)
WorldMapLevelDownButton:Point("BOTTOMLEFT", WorldMapLevelDropDown, "BOTTOMRIGHT", -2, 2)

R.ReskinCheck(WorldMapTrackQuest)
R.ReskinCheck(WorldMapShowDigSites)
WorldMapFrameSizeUpButton:SetFrameStrata("HIGH")
WorldMapFrameSizeUpButton.SetFrameStrata = R.dummy
WorldMapFrameSizeDownButton:SetFrameStrata("HIGH")
WorldMapFrameSizeDownButton.SetFrameStrata = R.dummy
WorldMapFrameCloseButton:SetFrameStrata("HIGH")
WorldMapFrameCloseButton.SetFrameStrata = R.dummy
WorldMapLevelUpButton:SetFrameStrata("HIGH")
WorldMapLevelUpButton.SetFrameStrata = R.dummy
WorldMapLevelDownButton:SetFrameStrata("HIGH")
WorldMapLevelDownButton.SetFrameStrata = R.dummy

--Mini
local function SmallSkin()
	WorldMapDetailFrame.backdrop:Show()
	WorldMapFrame.backdrop:Hide()
	WorldMapDetailFrame.backdrop:ClearAllPoints()
	WorldMapDetailFrame.backdrop:SetPoint("BOTTOMRIGHT", WorldMapButton, 8, -30)
	WorldMapDetailFrame.backdrop:SetPoint("TOPLEFT", WorldMapButton, -8, 25)
	WorldMapDetailFrame.backdrop:SetParent("WorldMapDetailFrame")
	WorldMapDetailFrame.backdrop:SetFrameLevel(0)
	WorldMapDetailFrame.backdrop:SetFrameStrata(WorldMapDetailFrame:GetFrameStrata())
	if C["worldmap"].lock then
		WorldMapDetailFrame:ClearAllPoints()
		WorldMapDetailFrame:SetPoint(unpack(mpos))
	end
	WorldMapFrame.scale = C["worldmap"].scale
	WorldMapDetailFrame:SetScale(C["worldmap"].scale)
	WorldMapButton:SetScale(C["worldmap"].scale)
	WorldMapFrameAreaFrame:SetScale(C["worldmap"].scale)
	WorldMapTitleButton:Show()
	WorldMapFrameMiniBorderLeft:Hide()
	WorldMapFrameMiniBorderRight:Hide()
	WorldMapPOIFrame.ratio = C["worldmap"].scale
	WorldMapFrameSizeUpButton:Show()
	WorldMapFrameSizeUpButton:ClearAllPoints()
	WorldMapFrameSizeUpButton:SetPoint("TOPRIGHT", WorldMapButton, "TOPRIGHT",-10,27)
	WorldMapFrameSizeUpButton:SetFrameStrata("MEDIUM")
	WorldMapFrameSizeUpButton:SetScale(C["worldmap"].scale)
	WorldMapFrameCloseButton:ClearAllPoints()
	WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapButton, "TOPRIGHT",10,27)
	WorldMapFrameCloseButton:SetFrameStrata("MEDIUM")
	WorldMapFrameCloseButton:SetScale(C["worldmap"].scale)
	WorldMapFrameTitle:ClearAllPoints()
	WorldMapFrameTitle:SetPoint("BOTTOM", WorldMapDetailFrame, "TOP", 0, 5)
	WorldMapTitleButton:SetFrameStrata("TOOLTIP")
	WorldMapTitleButton:ClearAllPoints()
	WorldMapTitleButton:SetPoint("BOTTOM", WorldMapDetailFrame, "TOP",0,0)
	WorldMapTooltip:SetFrameStrata("TOOLTIP")
	WorldMapLevelDropDown.Show = R.dummy
	WorldMapLevelDropDown:Hide()
	WorldMapQuestShowObjectives:SetScale(C["worldmap"].scale)
	WorldMapQuestShowObjectives:SetScale(C["worldmap"].scale)
	WorldMapShowDigSites:SetScale(C["worldmap"].scale)
	WorldMapTrackQuest:SetScale(C["worldmap"].scale)
	WorldMapLevelDownButton:SetScale(C["worldmap"].scale)
	WorldMapLevelUpButton:SetScale(C["worldmap"].scale)
	WorldMapFrame_SetOpacity(WORLDMAP_SETTINGS.opacity)
	WorldMapQuestShowObjectives_AdjustPosition()
--	WorldMapBossButtonFrame:Hide()
end

--Large
local function LargeSkin()
	if not InCombatLockdown() then
		WorldMapFrame:SetParent(UIParent)
		WorldMapFrame:EnableMouse(false)
		WorldMapFrame:EnableKeyboard(false)
		SetUIPanelAttribute(WorldMapFrame, "area", "center");
		SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true)
	end

	WorldMapDetailFrame.backdrop:Hide()
	WorldMapFrame.backdrop:Show()
	WorldMapFrame.backdrop:ClearAllPoints()
	WorldMapFrame.backdrop:Point("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -25, 70)
	WorldMapFrame.backdrop:Point("BOTTOMRIGHT", WorldMapDetailFrame, "BOTTOMRIGHT", 25, -30)
	WorldMapQuestShowObjectives:SetScale(1)
	WorldMapTrackQuest:SetScale(1)
	WorldMapFrameCloseButton:SetScale(1)
	WorldMapShowDigSites:SetScale(1)
	WorldMapLevelDownButton:SetScale(1)
	WorldMapLevelUpButton:SetScale(1)
	WorldMapFrame:EnableKeyboard(nil)
	WorldMapFrame:EnableMouse(nil)
	UIPanelWindows["WorldMapFrame"].area = "center"
	WorldMapFrame:SetAttribute("UIPanelLayout-defined", nil)
	WorldMapBossButtonFrame:Show()
end
R.CreateSD(WorldMapFrame.backdrop)


local function QuestSkin()
	if not InCombatLockdown() then
		WorldMapFrame:SetParent(UIParent)
		WorldMapFrame:EnableMouse(false)
		WorldMapFrame:EnableKeyboard(false)
		SetUIPanelAttribute(WorldMapFrame, "area", "center");
		SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true)
	end
	
	WorldMapFrame.backdrop:ClearAllPoints()
	WorldMapFrame.backdrop:Point("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -25, 70)
	WorldMapFrame.backdrop:Point("BOTTOMRIGHT", WorldMapDetailFrame, "BOTTOMRIGHT", 325, -235)  
	
	if not WorldMapQuestDetailScrollFrame.backdrop then
		WorldMapQuestDetailScrollFrame.backdrop = CreateFrame("Frame", nil, WorldMapQuestDetailScrollFrame)
		R.CreateBD(WorldMapQuestDetailScrollFrame.backdrop)
		WorldMapQuestDetailScrollFrame.backdrop:SetFrameLevel(0)
		WorldMapQuestDetailScrollFrame.backdrop:Point("TOPLEFT", -22, 2)
		WorldMapQuestDetailScrollFrame.backdrop:Point("BOTTOMRIGHT", 23, -4)
	end
	
	if not WorldMapQuestRewardScrollFrame.backdrop then
		WorldMapQuestRewardScrollFrame.backdrop = CreateFrame("Frame", nil, WorldMapQuestRewardScrollFrame)
		R.CreateBD(WorldMapQuestRewardScrollFrame.backdrop)
		WorldMapQuestRewardScrollFrame.backdrop:SetFrameLevel(0)
		WorldMapQuestRewardScrollFrame.backdrop:Point("TOPLEFT", -2, 2)
		WorldMapQuestRewardScrollFrame.backdrop:Point("BOTTOMRIGHT", 22, -4)				
	end
	
	if not WorldMapQuestScrollFrame.backdrop then
		WorldMapQuestScrollFrame.backdrop = CreateFrame("Frame", nil, WorldMapQuestScrollFrame)
		R.CreateBD(WorldMapQuestScrollFrame.backdrop)
		WorldMapQuestScrollFrame.backdrop:SetFrameLevel(0)
		WorldMapQuestScrollFrame.backdrop:Point("TOPLEFT", 0, 2)
		WorldMapQuestScrollFrame.backdrop:Point("BOTTOMRIGHT", 24, -3)				
	end
end			

local function FixSkin()
	WorldMapFrame:SetFrameStrata("HIGH")
	WorldMapFrame:StripTextures()
	if WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE then
		LargeSkin()
	elseif WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE then
		SmallSkin()
	elseif WORLDMAP_SETTINGS.size == WORLDMAP_QUESTLIST_SIZE then
		QuestSkin()
	end

	if not InCombatLockdown() then
		WorldMapFrameSizeDownButton:Show()
		WorldMapFrame:SetFrameLevel(10)
	else
		WorldMapFrameSizeDownButton:Disable()
		WorldMapFrameSizeUpButton:Disable()
	end	
	
	WorldMapFrameAreaLabel:SetFont(GameFontNormalSmall:GetFont(), 50, "OUTLINE")
	WorldMapFrameAreaLabel:SetShadowOffset(2, -2)
	WorldMapFrameAreaLabel:SetTextColor(0.90, 0.8294, 0.6407)	
	
	WorldMapFrameAreaDescription:SetFont(GameFontNormalSmall:GetFont(), 40, "OUTLINE")
	WorldMapFrameAreaDescription:SetShadowOffset(2, -2)	
	
	WorldMapZoneInfo:SetFont(GameFontNormalSmall:GetFont(), 27, "OUTLINE")
	WorldMapZoneInfo:SetShadowOffset(2, -2)		
end

WorldMapFrame:HookScript("OnShow", FixSkin)
hooksecurefunc("WorldMapFrame_SetFullMapView", LargeSkin)
hooksecurefunc("WorldMapFrame_SetQuestMapView", QuestSkin)
hooksecurefunc("WorldMap_ToggleSizeUp", LargeSkin)
hooksecurefunc("WorldMap_ToggleSizeDown", SmallSkin)

WorldMapFrame:HookScript("OnUpdate", function(self, elapsed)
	if self:IsShown() then
		UpdateCoords(self, elapsed)
	end

	if InCombatLockdown() then
		WorldMapFrameSizeDownButton:Disable()
		WorldMapFrameSizeUpButton:Disable()
	else
		WorldMapFrameSizeDownButton:Enable()
		WorldMapFrameSizeUpButton:Enable()			
	end
	
	if WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE then
		WorldMapFrameSizeUpButton:Hide()
		WorldMapFrameSizeDownButton:Show()
	elseif WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE then
		WorldMapFrameSizeUpButton:Show()
		WorldMapFrameSizeDownButton:Hide()
	elseif WORLDMAP_SETTINGS.size == WORLDMAP_QUESTLIST_SIZE then
		WorldMapFrameSizeUpButton:Hide()
		WorldMapFrameSizeDownButton:Show()
	end			
end)