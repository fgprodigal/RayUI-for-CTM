local lock_map_position = true						-- lock your map in set position
local mpos = {"CENTER",UIParent,"CENTER",0,65}		-- set position for locked map
local map_scale = 0.9								-- Mini World Map scale
local isize = 20									-- group icons size

---------------- > Coordinates functions
local player, cursor
local function gen_string(point, X, Y)
	local t = WorldMapButton:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	t:SetFont("Fonts\\ZYKai_T.TTF",12)
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
		cursor:SetFormattedText('鼠标: %.2d,%.2d', 100 * cx, 100 * cy)
	else
		cursor:SetText("")
	end
	if px == 0 or py == 0 then
		player:SetText("")
	else
		player:SetFormattedText('玩家: %.2d,%.2d', 100 * px, 100 * py)
	end
	-- gotta change coords position for maximized world map
	if WorldMapQuestScrollFrame:IsShown() then
		player:SetPoint('BOTTOMLEFT', WorldMapButton, 'BOTTOM',-120,0)
		cursor:SetPoint('BOTTOMLEFT', WorldMapButton, 'BOTTOM',50,0)
	else
		player:SetPoint('BOTTOMLEFT', WorldMapButton, 'BOTTOM',-120,-19)
		cursor:SetPoint('BOTTOMLEFT', WorldMapButton, 'BOTTOM',50,-19)
	end
end
local function UpdateCoords(self, elapsed)
	self.elapsed = self.elapsed - elapsed
	if self.elapsed <= 0 then
		self.elapsed = 0.1
		OnUpdate(player, cursor)
	end
end
local tpt = {"LEFT", self, "BOTTOM"}
local function gen_coords(self)
	if player or cursor then return end
	player = gen_string('BOTTOM',-120,-19)
	cursor = gen_string('BOTTOM',50,-19)
end

---------------- > Moving/removing world map elements
if map_scale==1 then map_scale = 0.99 end -- dirty hack to prevent 'division by zero'!
local function null() end
local w = CreateFrame"Frame"
w:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		SetCVar("questPOI", 1)
		SetCVar("advancedWorldMap",1)
		gen_coords(self)
		local cond = false
		BlackoutWorld:Hide()
		BlackoutWorld.Show = null
		BlackoutWorld.Hide = null
		WORLDMAP_RATIO_MINI = map_scale
		WORLDMAP_WINDOWED_SIZE = map_scale 
		WORLDMAP_SETTINGS.size = map_scale 
		WorldMapBlobFrame.Show = null
		WorldMapBlobFrame.Hide = null
		WorldMapQuestPOI_OnLeave = function()
			WorldMapTooltip:Hide()
		end
		WorldMap_ToggleSizeDown()
		for i = 1,40 do
			local ri = _G["WorldMapRaid"..i]
			ri:SetWidth(isize)
			ri:SetHeight(isize)
		end
		if FeedbackUIMapTip then 
			FeedbackUIMapTip:Hide()
			FeedbackUIMapTip.Show = null
		end
	elseif event == "PLAYER_REGEN_DISABLED" then
		WorldMapFrameSizeUpButton:Disable()
		WorldMap_ToggleSizeDown()
		WorldMapBlobFrame:DrawBlob(WORLDMAP_SETTINGS.selectedQuestId, false)
		WorldMapBlobFrame:DrawBlob(WORLDMAP_SETTINGS.selectedQuestId, true)
	elseif event == "PLAYER_REGEN_ENABLED" then
		WorldMapFrameSizeUpButton:Enable()
	elseif event == "WORLD_MAP_UPDATE" then
		-- making sure that coordinates are not calculated when map is hidden
		if not WorldMapFrame:IsVisible() and cond then
			self.elapsed = nil
			self:SetScript('OnUpdate', nil)
			cond = false
		else
			self.elapsed = 0.1
			self:SetScript('OnUpdate', UpdateCoords)
			cond = true
		end
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

local backdrop_tab = { 
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\AddOns\\m_Map\\media\\backdrop_edge",
		tile = false, tileSize = 0, edgeSize = 5, 
		insets = {left = 5, right = 5, top = 5, bottom = 5,},}
---------------- > Styling mini World Map
-- for the love of GOD do not change values in this function
local function m_MapShrink()
	if not w.bg then w.bg = CreateFrame("Frame", nil, WorldMapButton) end
	w.bg:SetParent("WorldMapDetailFrame")
	w.bg:SetFrameStrata("MEDIUM")
	w.bg:SetFrameLevel(30)
	w.bg:SetPoint("BOTTOMRIGHT", WorldMapButton, 8, -30)
	w.bg:SetPoint("TOPLEFT", WorldMapButton, -8, 25)
	w.bg:SetBackdrop(backdrop_tab)
	w.bg:SetBackdropColor(0,0,0,0)
    w.bg:SetBackdropBorderColor(0,0,0,0.9)
	if not w.bd then w.bd = w.bg:CreateTexture(nil, "BACKGROUND") end
	w.bd:SetPoint("BOTTOMRIGHT", w.bg, -5, 5)
	w.bd:SetPoint("TOPLEFT", w.bg, 5, -5)
	w.bd:SetTexture(0, 0, 0, 1)
	if lock_map_position then
		WorldMapDetailFrame:ClearAllPoints()
		WorldMapDetailFrame:SetPoint(unpack(mpos))
	end
	WorldMapFrame.scale = map_scale
	WorldMapDetailFrame:SetScale(map_scale)
	WorldMapButton:SetScale(map_scale)
	WorldMapFrameAreaFrame:SetScale(map_scale)
	WorldMapTitleButton:Show()
	WorldMapFrameMiniBorderLeft:Hide()
	WorldMapFrameMiniBorderRight:Hide()
	WorldMapPOIFrame.ratio = map_scale
	WorldMapFrameSizeUpButton:Show()
	WorldMapFrameSizeUpButton:ClearAllPoints()
	WorldMapFrameSizeUpButton:SetPoint("TOPRIGHT", WorldMapButton, "TOPRIGHT",-10,27)
	WorldMapFrameSizeUpButton:SetFrameStrata("MEDIUM")
	WorldMapFrameSizeUpButton:SetScale(map_scale)
	WorldMapFrameCloseButton:ClearAllPoints()
	WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapButton, "TOPRIGHT",10,27)
	WorldMapFrameCloseButton:SetFrameStrata("MEDIUM")
	WorldMapFrameCloseButton:SetScale(map_scale)
	WorldMapFrameTitle:ClearAllPoints()
	WorldMapFrameTitle:SetPoint("BOTTOM", WorldMapDetailFrame, "TOP", 0, 0)
	WorldMapTitleButton:SetFrameStrata("TOOLTIP")
	WorldMapTitleButton:ClearAllPoints()
	WorldMapTitleButton:SetPoint("BOTTOM", WorldMapDetailFrame, "TOP",0,0)
	WorldMapTooltip:SetFrameStrata("TOOLTIP")
	WorldMapLevelDropDown.Show = null
	WorldMapLevelDropDown:Hide()
	WorldMapQuestShowObjectives:SetScale(map_scale)
	WorldMapQuestShowObjectives:SetScale(map_scale)
	WorldMapShowDigSites:SetScale(map_scale)
	WorldMapTrackQuest:SetScale(map_scale)
	WorldMapLevelDownButton:SetScale(map_scale)
	WorldMapLevelUpButton:SetScale(map_scale)
	WorldMapFrame_SetOpacity(WORLDMAP_SETTINGS.opacity)
	WorldMapQuestShowObjectives_AdjustPosition()
end
hooksecurefunc("WorldMap_ToggleSizeDown", m_MapShrink)

local function m_MapEnlarge()
	if bg then bg:Hide() end
	WorldMapQuestShowObjectives:SetScale(1)
	WorldMapTrackQuest:SetScale(1)
	WorldMapFrameCloseButton:SetScale(1)
	WorldMapShowDigSites:SetScale(1)
	WorldMapLevelDownButton:SetScale(1)
	WorldMapLevelUpButton:SetScale(1)
	WorldMapLevelDropDown.Show = WorldMapLevelDropDown:Show()
	WorldMapFrame:EnableKeyboard(nil)
	WorldMapFrame:EnableMouse(nil)
	UIPanelWindows["WorldMapFrame"].area = "center"
	WorldMapFrame:SetAttribute("UIPanelLayout-defined", nil)
end
hooksecurefunc("WorldMap_ToggleSizeUp", m_MapEnlarge)