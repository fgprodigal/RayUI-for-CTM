local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	if R.HoT then
		R.SetBD(ReforgingFrame)
		select(12,ReforgingFrameItemButton:GetRegions()):Hide()
		ReforgingFrame:DisableDrawLayer("BACKGROUND")
		ReforgingFrame:DisableDrawLayer("BORDER")
		ReforgingFramePortrait:Hide()
		ReforgingFrameBg:Hide()
		ReforgingFrameTitleBg:Hide()
		ReforgingFramePortraitFrame:Hide()
		ReforgingFrameTopBorder:Hide()
		ReforgingFrameTopRightCorner:Hide()
		ReforgingFrameRestoreButton_LeftSeparator:Hide()
		ReforgingFrameRestoreButton_RightSeparator:Hide()
		ReforgingFrameButtonFrame:GetRegions():Hide()
		ReforgingFrameButtonFrameButtonBorder:Hide()
		ReforgingFrameButtonFrameButtonBottomBorder:Hide()
		ReforgingFrameButtonFrameMoneyLeft:Hide()
		ReforgingFrameButtonFrameMoneyRight:Hide()
		ReforgingFrameButtonFrameMoneyMiddle:Hide()
		ReforgingFrameRestoreMessage:SetTextColor(1, 1, 1)
		R.Reskin(ReforgingFrameRestoreButton)
		R.Reskin(ReforgingFrameReforgeButton)
		R.ReskinClose(ReforgingFrameCloseButton)
		ReforgingFrameRestoreButton:ClearAllPoints()
		ReforgingFrameRestoreButton:SetPoint("LEFT", ReforgingFrameMoneyFrame, "RIGHT", 60, 0)
		ReforgingFrameReforgeButton:ClearAllPoints()
		ReforgingFrameReforgeButton:SetPoint("LEFT", ReforgingFrameRestoreButton, "RIGHT", 1, 0)
	else
		ReforgingFrameTopInset:StripTextures()
		ReforgingFrameInset:StripTextures()
		ReforgingFrameBottomInset:StripTextures()
		
		ReforgingFrame:StripTextures()
		R.SetBD(ReforgingFrame)
		ReforgingFrameRestoreButton_LeftSeparator:Hide()
		ReforgingFrameReforgeButton_LeftSeparator:Hide()
		R.Reskin(ReforgingFrameRestoreButton)
		R.Reskin(ReforgingFrameReforgeButton)
		R.ReskinDropDown(ReforgingFrameFilterOldStat)
		R.ReskinDropDown(ReforgingFrameFilterNewStat)
		R.ReskinClose(ReforgingFrameCloseButton)
		
		ReforgingFrameItemButton:StripTextures()
		ReforgingFrameItemButton:CreateShadow("Background")
		ReforgingFrameItemButton:StyleButton()
		ReforgingFrameItemButtonIconTexture:ClearAllPoints()
		ReforgingFrameItemButtonIconTexture:Point("TOPLEFT", 2, -2)
		ReforgingFrameItemButtonIconTexture:Point("BOTTOMRIGHT", -2, 2)
		
		hooksecurefunc("ReforgingFrame_Update", function(self)
			local currentReforge, icon, name, quality, bound, cost = GetReforgeItemInfo()
			if icon then
				ReforgingFrameItemButtonIconTexture:SetTexCoord(.08, .92, .08, .92)
			else
				ReforgingFrameItemButtonIconTexture:SetTexture(nil)
			end
		end)
	end
end

R.SkinFuncs["Blizzard_ReforgingUI"] = LoadSkin