local R, C, L, DB = unpack(select(2, ...))
local AddOnName = ...

local function LoadSkin()
	if not R.HoT then
		R.Reskin(RaidFrameNotInRaidRaidBrowserButton)
	end
	R.Reskin(RaidFrameRaidInfoButton)
	R.Reskin(RaidFrameConvertToRaidButton)
	R.Reskin(RaidInfoExtendButton)
	R.Reskin(RaidInfoCancelButton)
	R.ReskinClose(RaidInfoCloseButton)
	R.ReskinScroll(RaidInfoScrollFrameScrollBar)
	RaidFrameConvertToRaidButton:ClearAllPoints()
	RaidFrameConvertToRaidButton:SetPoint("TOPLEFT", RaidFrame, "TOPLEFT", 38, -35)	
	RaidInfoInstanceLabel:DisableDrawLayer("BACKGROUND")
	RaidInfoIDLabel:DisableDrawLayer("BACKGROUND")
	RaidInfoDetailFooter:Hide()
	RaidInfoDetailHeader:Hide()
	RaidInfoDetailCorner:Hide()
	RaidInfoFrameHeader:Hide()
	if R.HoT then
		RaidInfoFrame:SetPoint("TOPLEFT", RaidFrame, "TOPRIGHT", 1, -28)			
	else			
		RaidInfoFrame:SetPoint("TOPLEFT", FriendsFrame, "TOPRIGHT", -33, -60)
		RaidInfoFrame.SetPoint = R.dummy
	end
end

tinsert(R.SkinFuncs[AddOnName], LoadSkin)