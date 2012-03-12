local R, L, P = unpack(select(2, ...)) --Inport: Engine, Locales, ProfileDB
local M = R:GetModule("Misc")

local function LoadFunc()
	if R.myclass ~= "ROGUE" then return end

	local poisons = {	6947, 3775, 5237, 2892, 10918 }

	local function ButtonUpdate(self, show)
		local actiontype, macroId = GetActionInfo(self.action)
		if actiontype ~= "macro" then return end
		local _, _, text = GetMacroInfo(macroId)
		local found = false
		for _, itemid in pairs(poisons) do
			local poison = GetItemInfo(itemid)
			if poison and text:find(poison) then
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

	local function UpdateButtons(show)
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
			UpdateButtons(false)
		else
			UpdateButtons(true)
		end
	end)
end

M:RegisterMiscModule("PoisonGlow", LoadFunc)