local R, C, L, DB = unpack(select(2, ...))
local ADDON_NAME = ...

local function CreateTutorialFrame(name, parent, width, height, text)
	local frame = CreateFrame("Frame", name, parent, "GlowBoxTemplate")
	frame:SetSize(width, height)	
	frame:SetFrameStrata("FULLSCREEN_DIALOG")

	local arrow = CreateFrame("Frame", nil, frame, "GlowBoxArrowTemplate")
	arrow:SetPoint("TOP", frame, "BOTTOM", 0, 4)

	frame.text = frame:CreateFontString(nil, "OVERLAY")
	frame.text:SetJustifyH("CENTER")
	frame.text:SetSize(width - 20, height - 20)
	frame.text:SetFontObject(GameFontHighlightLeft)
	frame.text:SetPoint("CENTER")
	frame.text:SetText(text)
	frame.text:SetSpacing(4)

	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", 6, 6)
	R.ReskinClose(close)
	
	return frame
end

if R.myclass ~= "ROGUE" then return end

local poisons = {	6947, 3775, 5237, 2892, 10918 }

local function ButtonUpdate(self, show)
	local actiontype, macroId = GetActionInfo(self.action)
	if actiontype ~= "macro" then return end
	local _, _, text = GetMacroInfo(macroId)
	local found = false
	for _, itemid in pairs(poisons) do
		local poison = GetItemInfo(itemid)
		if text:match(poison) then
			found = true
		end
	end
	if found then
		if show then
			ActionButton_ShowOverlayGlow(self)
		else
			ActionButton_HideOverlayGlow(self)
		end
	end
end

local function UpdateButton(show)
	for i = 1,12 do
		ButtonUpdate(_G["ActionButton"..i], show)
		ButtonUpdate(_G["MultiBarBottomRightButton"..i], show)
		ButtonUpdate(_G["MultiBarRightButton"..i], show)
		ButtonUpdate(_G["MultiBarBottomLeftButton"..i], show)
		ButtonUpdate(_G["MultiBarLeftButton"..i], show)
	end
end

local updater = CreateFrame("Frame")
updater:SetScript("OnUpdate", function(self, elapsed)
	local _, mainHandExpiration, _, _, offHandExpiration = GetWeaponEnchantInfo()
	if ( mainHandExpiration and mainHandExpiration/60000 > 5 ) and ( offHandExpiration and offHandExpiration/60000 > 5 ) then
		UpdateButton(false)
	else
		UpdateButton(true)
	end
end)

-- local event = CreateFrame("Frame")
-- event:RegisterEvent("PLAYER_TARGET_CHANGED")
-- event:RegisterEvent("UNIT_HEALTH")
-- event:SetScript("OnEvent", UpdateButton)
-- local tutorial1 = CreateTutorialFrame(nil, GameMenuFrame, 220, 100, "點擊進入RayUI控制台.")
-- tutorial1:SetPoint("BOTTOM", RayUIConfigButton, "TOP", 0, 20)

-- local tutorial2 = CreateTutorialFrame(nil, UIParent, 150, 100, "右鍵點擊打開追蹤菜單, 中鍵點擊打開微型菜單.")
-- tutorial2:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 50)