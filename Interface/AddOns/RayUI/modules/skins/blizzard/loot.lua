local R, L, P = unpack(select(2, ...)) --Inport: Engine, Locales, ProfileDB
local S = R:GetModule("Skins")

local function LoadSkin()
	if not(IsAddOnLoaded("Butsu") or IsAddOnLoaded("LovelyLoot") or IsAddOnLoaded("XLoot")) then
		LootFramePortraitOverlay:Hide()
		select(2, LootFrame:GetRegions()):Hide()
		S:ReskinClose(LootCloseButton, "CENTER", LootFrame, "TOPRIGHT", -81, -26)

		LootFrame.bg = CreateFrame("Frame", nil, LootFrame)
		LootFrame.bg:SetFrameLevel(LootFrame:GetFrameLevel()-1)
		LootFrame.bg:SetPoint("TOPLEFT", LootFrame, "TOPLEFT", 20, -12)
		LootFrame.bg:SetPoint("BOTTOMRIGHT", LootFrame, "BOTTOMRIGHT", -66, 12)

		S:CreateBD(LootFrame.bg)
		S:CreateBD(MissingLootFrame)

		select(3, LootFrame:GetRegions()):SetPoint("TOP", LootFrame.bg, "TOP", 0, -8)

		for i = 1, LOOTFRAME_NUMBUTTONS do
			local bu = _G["LootButton"..i]
			local ic = _G["LootButton"..i.."IconTexture"]
			_G["LootButton"..i.."IconQuestTexture"]:SetAlpha(0)
			local _, _, _, _, _, _, _, _, bg = bu:GetRegions()

			bu:SetNormalTexture("")
			bu:StyleButton(true)

			local bd = CreateFrame("Frame", nil, bu)
			bd:SetPoint("TOPLEFT")
			bd:SetPoint("BOTTOMRIGHT", 126, 0)
			bd:SetFrameLevel(bu:GetFrameLevel()-1)
			S:CreateBD(bd, .25)

			ic:SetTexCoord(.08, .92, .08, .92)
			ic.bg = S:CreateBG(ic)

			bg:Kill()
		end

		hooksecurefunc("LootFrame_UpdateButton", function(index)
			local ic = _G["LootButton"..index.."IconTexture"]
			if select(6, GetLootSlotInfo(index)) then
				ic.bg:SetVertexColor(1, 0, 0)
			else
				ic.bg:SetVertexColor(0, 0, 0)
			end
		end)
	end
end

S:RegisterSkin("RayUI", LoadSkin)