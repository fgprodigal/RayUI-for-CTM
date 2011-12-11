local R, C, L, DB = unpack(select(2, ...))
local AddOnName = ...

local function LoadSkin()
	WhoFrameWhoButton:SetPoint("RIGHT", WhoFrameAddFriendButton, "LEFT", -1, 0)
	WhoFrameAddFriendButton:SetPoint("RIGHT", WhoFrameGroupInviteButton, "LEFT", -1, 0)
	WhoListScrollFrame:GetRegions():Hide()
	select(2, WhoListScrollFrame:GetRegions()):Hide()
	ChannelFrameDaughterFrameCorner:Hide()
	ChannelFrameDaughterFrameTitlebar:Hide()
	ChannelRosterScrollFrameTop:SetAlpha(0)
	ChannelRosterScrollFrameBottom:SetAlpha(0)
	FriendsFrameStatusDropDown:ClearAllPoints()
	
	R.ReskinScroll(FriendsFrameFriendsScrollFrameScrollBar)
	R.ReskinScroll(WhoListScrollFrameScrollBar)
	R.ReskinScroll(FriendsFriendsScrollFrameScrollBar)
	R.ReskinDropDown(FriendsFrameStatusDropDown)
	R.ReskinDropDown(WhoFrameDropDown)
	R.ReskinDropDown(FriendsFriendsFrameDropDown)
	R.ReskinInput(AddFriendNameEditBox)
	R.ReskinInput(FriendsFrameBroadcastInput)
	R.ReskinInput(ChannelFrameDaughterFrameChannelName)
	R.ReskinInput(ChannelFrameDaughterFrameChannelPassword)
	R.ReskinClose(ChannelFrameDaughterFrameDetailCloseButton)
	R.ReskinClose(FriendsFrameCloseButton)

	local buttons = {
		"WhoFrameAddFriendButton",
		"WhoFrameGroupInviteButton",
		"FriendsFrameAddFriendButton",
		"FriendsFrameSendMessageButton",
		"AddFriendEntryFrameAcceptButton",
		"AddFriendEntryFrameCancelButton",
		"FriendsFriendsSendRequestButton",
		"FriendsFriendsCloseButton",
		"FriendsFrameUnsquelchButton",
		"FriendsFramePendingButton1AcceptButton",
		"FriendsFramePendingButton1DeclineButton",
		"FriendsFrameIgnorePlayerButton",
		"AddFriendInfoFrameContinueButton",
		"ChannelFrameNewButton",
		"ChannelFrameDaughterFrameOkayButton",
		"ChannelFrameDaughterFrameCancelButton",
		"WhoFrameWhoButton",
		"PendingListInfoFrameContinueButton"
	}
	for i = 1, #buttons do
		local button = _G[buttons[i]]
		R.Reskin(button)
	end

	local bglayers = {
		"FriendsFrame",
		"WhoFrameColumnHeader1",
		"WhoFrameColumnHeader2",
		"WhoFrameColumnHeader3",
		"WhoFrameColumnHeader4"
	}
	for i = 1, #bglayers do
		_G[bglayers[i]]:DisableDrawLayer("BACKGROUND")
	end
	
	if R.HoT then
		local borderlayers = {
			"FriendsFrame",
			"FriendsFrameInset",
			"WhoFrameListInset",
			"WhoFrameEditBoxInset",
			"WhoFrameColumnHeader4",
			"ChannelFrameLeftInset",
			"ChannelFrameRightInset"
		}
		for i = 1, #borderlayers do
			_G[borderlayers[i]]:DisableDrawLayer("BORDER")
		end
	end
	
	local lightbds = {
		"FriendsFriendsList",
		"AddFriendNoteFrame",
		"FriendsFriendsNoteFrame"
	}
	for i = 1, #lightbds do
		R.CreateBD(_G[lightbds[i]], .25)
	end

	if R.HoT then
		FriendsFrameStatusDropDown:SetPoint("TOPLEFT", FriendsFrame, "TOPLEFT", 10, -32)
		FriendsFrameTitleText:SetPoint("TOP", FriendsFrame, "TOP", 0, -8)
		R.SetBD(FriendsFrame)
		FriendsFrameTopRightCorner:Hide()
		FriendsFrameTopLeftCorner:Hide()
		FriendsFrameTopBorder:Hide()
		FriendsFramePortraitFrame:Hide()
		FriendsFrameIcon:Hide()
		FriendsFrameInsetBg:Hide()
		FriendsFrameFriendsScrollFrameTop:Hide()
		FriendsFrameFriendsScrollFrameMiddle:Hide()
		FriendsFrameFriendsScrollFrameBottom:Hide()
		WhoFrameListInsetBg:Hide()
		WhoFrameEditBoxInsetBg:Hide()
		ChannelFrameLeftInsetBg:Hide()
		ChannelFrameRightInsetBg:Hide()
		IgnoreListFrameTop:Hide()
		IgnoreListFrameMiddle:Hide()
		IgnoreListFrameBottom:Hide()
		PendingListFrameTop:Hide()
		PendingListFrameMiddle:Hide()
		PendingListFrameBottom:Hide()
	else
		ChannelFrameVerticalBar:Hide()
		FriendsFrameStatusDropDown:SetPoint("TOPLEFT", FriendsFrame, "TOPLEFT", 10, -40)
		FriendsFrameTitleText:SetPoint("TOP", FriendsFrame, "TOP", 0, -16)
		R.SetBD(FriendsFrame, 10, -4, -34, 76)
		FriendsFrame:DisableDrawLayer("LOW")
		R.ReskinClose(FriendsFrameCloseButton, "TOPRIGHT", FriendsFrame, "TOPRIGHT", -42, -12)
	end
	
	for i = 1, 6 do
		for j = 1, 3 do
			select(i, _G["FriendsTabHeaderTab"..j]:GetRegions()):Hide()
			select(i, _G["FriendsTabHeaderTab"..j]:GetRegions()).Show = R.dummy
		end
	end
	
	for i = 1, 4 do
		R.CreateTab(_G["FriendsFrameTab"..i])
	end
	
	for i = 1, 9 do
		select(i, FriendsFriendsNoteFrame:GetRegions()):Hide()
		select(i, AddFriendNoteFrame:GetRegions()):Hide()
	end
	
	for i = 1, MAX_DISPLAY_CHANNEL_BUTTONS do
		_G["ChannelButton"..i]:SetNormalTexture("")
	end

	for i = 1, FRIENDS_TO_DISPLAY do
		local bu = _G["FriendsFrameFriendsScrollFrameButton"..i]
		local ic = _G["FriendsFrameFriendsScrollFrameButton"..i.."GameIcon"]
		local inv = _G["FriendsFrameFriendsScrollFrameButton"..i.."TravelPassButton"]
		bu:SetHighlightTexture(C.Aurora.backdrop)
		bu:GetHighlightTexture():SetVertexColor(.24, .56, 1, .2)

		ic:SetSize(22, 22)
		ic:SetTexCoord(.15, .85, .15, .85)

		ic:ClearAllPoints()
		ic:SetPoint("RIGHT", bu, "RIGHT", -2, -2)
		ic.SetPoint = R.dummy

		inv:SetAlpha(0)
		inv:EnableMouse(false)
	end

	local function UpdateScroll()
		for i = 1, FRIENDS_TO_DISPLAY do
			local bu = _G["FriendsFrameFriendsScrollFrameButton"..i]
			local ic = _G["FriendsFrameFriendsScrollFrameButton"..i.."GameIcon"]
			if not bu.bg then
				bu.bg = CreateFrame("Frame", nil, bu)
				bu.bg:SetPoint("TOPLEFT", ic)
				bu.bg:SetPoint("BOTTOMRIGHT", ic)
				R.CreateBD(bu.bg, 0)
			end
			if ic:IsShown() then
				bu.bg:Show()
			else
				bu.bg:Hide()
			end
		end
	end

	local friendshandler = CreateFrame("Frame")
	friendshandler:RegisterEvent("FRIENDLIST_UPDATE")
	friendshandler:RegisterEvent("BN_FRIEND_TOON_ONLINE")
	friendshandler:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")
	friendshandler:SetScript("OnEvent", UpdateScroll)
	FriendsFrameFriendsScrollFrame:HookScript("OnVerticalScroll", UpdateScroll)

	if R.HoT then
		local whobg = CreateFrame("Frame", nil, WhoFrameEditBoxInset)
		whobg:SetPoint("TOPLEFT")
		whobg:Point("BOTTOMRIGHT", -1, 1)
		whobg:SetFrameLevel(WhoFrameEditBoxInset:GetFrameLevel()-1)
		R.CreateBD(whobg, .25)

		FriendsTabHeaderSoRButtonIcon:SetTexCoord(.08, .92, .08, .92)
		local sorbg = CreateFrame("Frame", nil, FriendsTabHeaderSoRButton)
		sorbg:Point("TOPLEFT", -1, 1)
		sorbg:Point("BOTTOMRIGHT", 1, -1)
		R.CreateBD(sorbg, 0)
	end
end

tinsert(R.SkinFuncs[AddOnName], LoadSkin)