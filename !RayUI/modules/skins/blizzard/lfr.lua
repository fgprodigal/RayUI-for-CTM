local R, C, L, DB = unpack(select(2, ...))
local AddOnName = ...

local function LoadSkin()
	R.Reskin(LFRQueueFrameFindGroupButton)
	R.Reskin(LFRQueueFrameAcceptCommentButton)
	R.Reskin(LFRBrowseFrameSendMessageButton)
	R.Reskin(LFRBrowseFrameInviteButton)
	R.Reskin(LFRBrowseFrameRefreshButton)
	R.ReskinCheck(LFRQueueFrameRoleButtonTank:GetChildren())
	R.ReskinCheck(LFRQueueFrameRoleButtonHealer:GetChildren())
	R.ReskinCheck(LFRQueueFrameRoleButtonDPS:GetChildren())
	R.ReskinDropDown(LFRBrowseFrameRaidDropDown)
	LFRQueueFrame:DisableDrawLayer("BACKGROUND")
	LFRBrowseFrame:DisableDrawLayer("BACKGROUND")
	for i = 1, 7 do
		_G["LFRBrowseFrameColumnHeader"..i]:DisableDrawLayer("BACKGROUND")
	end
	R.SetBD(RaidParentFrame)
	RaidParentFrame:DisableDrawLayer("BACKGROUND")
	RaidParentFrame:DisableDrawLayer("BORDER")
	RaidParentFrameInset:DisableDrawLayer("BORDER")
	RaidFinderFrameRoleInset:DisableDrawLayer("BORDER")
	LFRQueueFrameRoleInset:DisableDrawLayer("BORDER")
	LFRQueueFrameListInset:DisableDrawLayer("BORDER")
	LFRQueueFrameCommentInset:DisableDrawLayer("BORDER")
	LFRQueueFrameRoleInsetBg:Hide()
	LFRQueueFrameListInsetBg:Hide()
	LFRQueueFrameCommentInsetBg:Hide()	
	RaidFinderQueueFrameBackground:Hide()
	RaidParentFrameInsetBg:Hide()
	RaidFinderFrameRoleInsetBg:Hide()
	RaidFinderFrameRoleBackground:Hide()
	RaidParentFramePortraitFrame:Hide()
	RaidParentFramePortrait:Hide()
	RaidParentFrameTopBorder:Hide()
	RaidParentFrameTopRightCorner:Hide()			
	RaidFinderFrameFindRaidButton_RightSeparator:Hide()
	RaidFinderFrameCancelButton_LeftSeparator:Hide()

	for i = 1, 3 do
		R.CreateTab(_G["RaidParentFrameTab"..i])
	end

	for i = 1, 2 do
		local tab = _G["LFRParentFrameSideTab"..i]
		tab:GetRegions():Hide()
		R.CreateBG(tab)
		R.CreateSD(tab, 5, 0, 0, 0, 1, 1)
		select(2, tab:GetRegions()):SetTexCoord(.08, .92, .08, .92)
		
		if i == 1 then
			local a1, p, a2, x, y = tab:GetPoint()
			tab:SetPoint(a1, p, a2, x + 11, y)			
		end
		
		tab:StyleButton(true)
		tab:SetPushedTexture(nil)
	end
	R.Reskin(RaidFinderFrameFindRaidButton)
	R.Reskin(RaidFinderFrameCancelButton)
	R.Reskin(RaidFinderQueueFrameIneligibleFrameLeaveQueueButton)
	R.ReskinDropDown(RaidFinderQueueFrameSelectionDropDown)		
	R.ReskinClose(RaidParentFrameCloseButton)
end

tinsert(R.SkinFuncs[AddOnName], LoadSkin)