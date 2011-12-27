local R, C, L, DB = unpack(select(2, ...))
local AddOnName = ...

local function LoadSkin()
	R.SetBD(LFDParentFrame)	
	R.Reskin(LFDQueueFrameFindGroupButton)
	R.Reskin(LFDQueueFrameCancelButton)
	R.Reskin(LFDRoleCheckPopupAcceptButton)
	R.Reskin(LFDRoleCheckPopupDeclineButton)
	R.Reskin(LFDQueueFramePartyBackfillBackfillButton)
	R.Reskin(RaidFinderQueueFramePartyBackfillBackfillButton)
	R.Reskin(LFDQueueFramePartyBackfillNoBackfillButton)
	R.Reskin(RaidFinderQueueFramePartyBackfillNoBackfillButton)
	R.ReskinClose(LFDParentFrameCloseButton)
	R.ReskinClose(LFGDungeonReadyStatusCloseButton)
	R.ReskinCheck(LFGInvitePopupRoleButtonTank:GetChildren())
	R.ReskinCheck(LFGInvitePopupRoleButtonHealer:GetChildren())
	R.ReskinCheck(LFGInvitePopupRoleButtonDPS:GetChildren())
	R.CreateBD(LFGInvitePopup)
	R.CreateSD(LFGInvitePopup)
	R.ReskinCheck(LFDQueueFrameRoleButtonTank:GetChildren())
	R.ReskinCheck(LFDQueueFrameRoleButtonHealer:GetChildren())
	R.ReskinCheck(LFDQueueFrameRoleButtonDPS:GetChildren())
	R.ReskinCheck(LFDQueueFrameRoleButtonLeader:GetChildren())
	R.ReskinCheck(LFDRoleCheckPopupRoleButtonTank:GetChildren())
	R.ReskinCheck(LFDRoleCheckPopupRoleButtonHealer:GetChildren())
	R.ReskinCheck(LFDRoleCheckPopupRoleButtonDPS:GetChildren())
	R.ReskinScroll(LFDQueueFrameSpecificListScrollFrameScrollBar)
	R.ReskinScroll(LFDQueueFrameRandomScrollFrameScrollBar)
	R.ReskinDropDown(LFDQueueFrameTypeDropDown)

	LFDParentFrame:DisableDrawLayer("BACKGROUND")
	LFDParentFrame:DisableDrawLayer("BORDER")
	LFDParentFrame:DisableDrawLayer("OVERLAY")
	LFDParentFrameInset:DisableDrawLayer("BACKGROUND")
	LFDParentFrameInset:DisableDrawLayer("BORDER")
	LFDParentFrameEyeFrame:Hide()
	LFDQueueFrameCapBarShadow:Hide()
	LFDQueueFrameBackground:Hide()
	LFDQueueFrameCooldownFrameBlackFilter:SetAlpha(.6)
	LFDQueueFrameRandomScrollFrameScrollBackground:Hide()
	LFDQueueFramePartyBackfill:SetAlpha(.6)
	LFDQueueFrameCancelButton_LeftSeparator:Hide()
	LFDQueueFrameFindGroupButton_RightSeparator:Hide()
	LFDQueueFrameSpecificListScrollFrameScrollBackgroundTopLeft:Hide()
	LFDQueueFrameSpecificListScrollFrameScrollBackgroundBottomRight:Hide()
	LFDQueueFrameSpecificListScrollFrameScrollBarScrollDownButton:SetPoint("TOP", LFDQueueFrameSpecificListScrollFrameScrollBar, "BOTTOM", 0, 2)
	LFDQueueFrameRandomScrollFrameScrollBarScrollDownButton:SetPoint("TOP", LFDQueueFrameRandomScrollFrameScrollBar, "BOTTOM", 0, 2)

	LFDQueueFrameCapBarProgress:SetTexture(C.Aurora.backdrop)
	LFDQueueFrameCapBarCap1:SetTexture(C.Aurora.backdrop)
	LFDQueueFrameCapBarCap2:SetTexture(C.Aurora.backdrop)

	LFDQueueFrameCapBarLeft:Hide()
	LFDQueueFrameCapBarMiddle:Hide()
	LFDQueueFrameCapBarRight:Hide()
	LFDQueueFrameCapBarBG:SetTexture(nil)

	LFDQueueFrameCapBar.backdrop = CreateFrame("Frame", nil, LFDQueueFrameCapBar)
	LFDQueueFrameCapBar.backdrop:SetPoint("TOPLEFT", LFDQueueFrameCapBar, "TOPLEFT", -1, -2)
	LFDQueueFrameCapBar.backdrop:SetPoint("BOTTOMRIGHT", LFDQueueFrameCapBar, "BOTTOMRIGHT", 1, 2)
	LFDQueueFrameCapBar.backdrop:SetFrameLevel(0)
	R.CreateBD(LFDQueueFrameCapBar.backdrop)
	
	for i = 1, 4 do
		_G["LFDQueueFrameCapBarDivider"..i]:Hide()
	end

	for i = 1, 2 do
		local bu = _G["LFDQueueFrameCapBarCap"..i.."Marker"]
		_G["LFDQueueFrameCapBarCap"..i.."MarkerTexture"]:Hide()

		local cap = bu:CreateTexture(nil, "OVERLAY")
		cap:SetSize(1, 14)
		cap:SetPoint("CENTER")
		cap:SetTexture(C.Aurora.backdrop)
		cap:SetVertexColor(0, 0, 0)
	end

	LFDQueueFrameRandomScrollFrame:SetWidth(304)

	local function ReskinRewards()
		for i = 1, LFD_MAX_REWARDS do
			local button = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i]
			local icon = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."IconTexture"]

			if button then
				icon:SetTexCoord(.08, .92, .08, .92)
				if not button.reskinned then
					local cta = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."ShortageBorder"]
					local count = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."Count"]
					local na = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."NameFrame"]

					R.CreateBG(icon)
					icon:SetDrawLayer("OVERLAY")
					count:SetDrawLayer("OVERLAY")
					na:SetTexture(0, 0, 0, .25)
					na:SetSize(118, 39)
					cta:SetAlpha(0)

					button.bg2 = CreateFrame("Frame", nil, button)
					button.bg2:SetPoint("TOPLEFT", na, "TOPLEFT", 10, 0)
					button.bg2:SetPoint("BOTTOMRIGHT", na, "BOTTOMRIGHT")
					R.CreateBD(button.bg2, 0)

					button.reskinned = true
				end
			end
		end
	end

	hooksecurefunc("LFDQueueFrameRandom_UpdateFrame", ReskinRewards)

	LFGDungeonReadyDialog.SetBackdrop = R.dummy
	LFGDungeonReadyDialogBackground:Hide()
	LFGDungeonReadyDialogBottomArt:Hide()
	LFGDungeonReadyDialogFiligree:Hide()
	R.Reskin(LFGDungeonReadyDialogEnterDungeonButton)
	R.Reskin(LFGDungeonReadyDialogLeaveQueueButton)
	R.Reskin(LFDQueueFrameNoLFDWhileLFRLeaveQueueButton)
end

tinsert(R.SkinFuncs[AddOnName], LoadSkin)