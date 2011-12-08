local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	local r, g, b = C.Aurora.classcolours[R.myclass].r, C.Aurora.classcolours[R.myclass].g, C.Aurora.classcolours[R.myclass].b
	R.SetBD(LookingForGuildFrame)
	R.CreateBD(LookingForGuildInterestFrame, .25)
	LookingForGuildInterestFrameBg:Hide()
	R.CreateBD(LookingForGuildAvailabilityFrame, .25)
	LookingForGuildAvailabilityFrameBg:Hide()
	R.CreateBD(LookingForGuildRolesFrame, .25)
	LookingForGuildRolesFrameBg:Hide()
	R.CreateBD(LookingForGuildCommentFrame, .25)
	LookingForGuildCommentFrameBg:Hide()
	R.CreateBD(LookingForGuildCommentInputFrame, .12)
	LookingForGuildFrame:DisableDrawLayer("BACKGROUND")
	LookingForGuildFrame:DisableDrawLayer("BORDER")
	LookingForGuildFrameInset:DisableDrawLayer("BACKGROUND")
	LookingForGuildFrameInset:DisableDrawLayer("BORDER")
	for i = 1, 5 do
		local bu = _G["LookingForGuildBrowseFrameContainerButton"..i]
		R.CreateBD(bu, .25)
		bu:SetHighlightTexture("")
		bu:GetRegions():SetTexture(C.Aurora.backdrop)
		bu:GetRegions():SetVertexColor(r, g, b, .2)
	end
	for i = 1, 9 do
		select(i, LookingForGuildCommentInputFrame:GetRegions()):Hide()
	end
	for i = 1, 3 do
		for j = 1, 6 do
			select(j, _G["LookingForGuildFrameTab"..i]:GetRegions()):Hide()
			select(j, _G["LookingForGuildFrameTab"..i]:GetRegions()).Show = R.dummy
		end
	end
	LookingForGuildFrameTabardBackground:Hide()
	LookingForGuildFrameTabardEmblem:Hide()
	LookingForGuildFrameTabardBorder:Hide()
	LookingForGuildFramePortraitFrame:Hide()
	LookingForGuildFrameTopBorder:Hide()
	LookingForGuildFrameTopRightCorner:Hide()
	LookingForGuildBrowseButton_LeftSeparator:Hide()
	LookingForGuildRequestButton_RightSeparator:Hide()

	R.Reskin(LookingForGuildBrowseButton)
	R.Reskin(LookingForGuildRequestButton)

	R.ReskinScroll(LookingForGuildBrowseFrameContainerScrollBar)
	R.ReskinClose(LookingForGuildFrameCloseButton)
	R.ReskinCheck(LookingForGuildQuestButton)
	R.ReskinCheck(LookingForGuildDungeonButton)
	R.ReskinCheck(LookingForGuildRaidButton)
	R.ReskinCheck(LookingForGuildPvPButton)
	R.ReskinCheck(LookingForGuildRPButton)
	R.ReskinCheck(LookingForGuildWeekdaysButton)
	R.ReskinCheck(LookingForGuildWeekendsButton)
	R.ReskinCheck(LookingForGuildTankButton:GetChildren())
	R.ReskinCheck(LookingForGuildHealerButton:GetChildren())
	R.ReskinCheck(LookingForGuildDamagerButton:GetChildren())
	if R.HoT then
		R.CreateBD(GuildFinderRequestMembershipFrame)
		R.CreateSD(GuildFinderRequestMembershipFrame)
		for i = 1, 6 do
			select(i, GuildFinderRequestMembershipFrameInputFrame:GetRegions()):Hide()
		end
		R.Reskin(GuildFinderRequestMembershipFrameAcceptButton)
		R.Reskin(GuildFinderRequestMembershipFrameCancelButton)
		R.ReskinInput(GuildFinderRequestMembershipFrameInputFrame)
	end
end

R.SkinFuncs["Blizzard_LookingForGuildUI"] = LoadSkin