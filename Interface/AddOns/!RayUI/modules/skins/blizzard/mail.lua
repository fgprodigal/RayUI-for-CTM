local R, C, L, DB = unpack(select(2, ...))
local AddOnName = ...

local function LoadSkin()
	R.SetBD(MailFrame, 10, -12, -34, 74)
	R.SetBD(OpenMailFrame, 10, -12, -34, 74)
	
	MailTextFontNormal:SetTextColor(1, 1, 1)

	OpenMailLetterButton:StyleButton(true)
	OpenMailLetterButtonIconTexture:SetTexCoord(.08, .92, .08, .92)
	OpenMailMoneyButton:StyleButton(true)
	OpenMailMoneyButtonIconTexture:SetTexCoord(.08, .92, .08, .92)
	OpenMailFrameIcon:Hide()
	OpenMailHorizontalBarLeft:Hide()
	select(13, OpenMailFrame:GetRegions()):Hide()
	OpenStationeryBackgroundLeft:Hide()
	OpenStationeryBackgroundRight:Hide()
	for i = 4, 7 do
		select(i, SendMailFrame:GetRegions()):Hide()
	end
	SendStationeryBackgroundLeft:Hide()
	SendStationeryBackgroundRight:Hide()
	SendScrollBarBackgroundTop:Hide()
	select(4, SendMailScrollFrame:GetRegions()):Hide()
	OpenScrollBarBackgroundTop:Hide()
	select(2, OpenMailScrollFrame:GetRegions()):Hide()
	InboxPrevPageButton:GetRegions():Hide()
	InboxNextPageButton:GetRegions():Hide()
	
	SendMailMailButton:SetPoint("RIGHT", SendMailCancelButton, "LEFT", -1, 0)
	OpenMailDeleteButton:SetPoint("RIGHT", OpenMailCancelButton, "LEFT", -1, 0)
	OpenMailReplyButton:SetPoint("RIGHT", OpenMailDeleteButton, "LEFT", -1, 0)
	SendMailMoneySilver:SetPoint("LEFT", SendMailMoneyGold, "RIGHT", 1, 0)
	SendMailMoneyCopper:SetPoint("LEFT", SendMailMoneySilver, "RIGHT", 1, 0)

	local buttons = {
		"SendMailMailButton",
		"SendMailCancelButton",
		"OpenMailReplyButton",
		"OpenMailDeleteButton",
		"OpenMailCancelButton",
		"OpenMailReportSpamButton"
	}
	for i = 1, #buttons do
		local button = _G[buttons[i]]
		R.Reskin(button)
	end

	for i = 1, 2 do
		R.CreateTab(_G["MailFrameTab"..i])
	end

	for i = 1, 5 do
		select(i, MailFrame:GetRegions()):Hide()
	end

	local inputs = {
		"SendMailNameEditBox",
		"SendMailSubjectEditBox",
		"SendMailMoneyGold",
		"SendMailMoneySilver",
		"SendMailMoneyCopper"
	}
	for i = 1, #inputs do
		input = _G[inputs[i]]
		R.ReskinInput(input)
	end

	R.ReskinArrow(InboxPrevPageButton, 1)
	R.ReskinArrow(InboxNextPageButton, 2)
	R.ReskinClose(InboxCloseButton, "TOPRIGHT", MailFrame, "TOPRIGHT", -38, -16)
	R.ReskinClose(OpenMailCloseButton, "TOPRIGHT", OpenMailFrame, "TOPRIGHT", -38, -16)
	R.ReskinScroll(SendMailScrollFrameScrollBar)
	R.ReskinScroll(OpenMailScrollFrameScrollBar)
	OpenMailFrame:DisableDrawLayer("BORDER")

	local bg = CreateFrame("Frame", nil, OpenMailLetterButton)
	bg:SetPoint("TOPLEFT", -1, 1)
	bg:SetPoint("BOTTOMRIGHT", 1, -1)
	bg:SetFrameLevel(OpenMailLetterButton:GetFrameLevel()-1)
	R.CreateBD(bg)

	for i = 1, INBOXITEMS_TO_DISPLAY do
		local it = _G["MailItem"..i]
		local bu = _G["MailItem"..i.."Button"]
		local st = _G["MailItem"..i.."ButtonSlot"]
		local ic = _G["MailItem"..i.."Button".."Icon"]
		local line = select(3, _G["MailItem"..i]:GetRegions())

		local a, b = it:GetRegions()
		a:Hide()
		b:Hide()

		bu:StyleButton(true)
		bu:SetPushedTexture(nil)

		st:Hide()
		line:Hide()
		ic:SetTexCoord(.08, .92, .08, .92)

		local bg = CreateFrame("Frame", nil, bu)
		bg:SetPoint("TOPLEFT", -1, 1)
		bg:SetPoint("BOTTOMRIGHT", 1, -1)
		bg:SetFrameLevel(bu:GetFrameLevel()-1)
		R.CreateBD(bg, 0)
	end

	for i = 1, ATTACHMENTS_MAX_SEND do
		local button = _G["SendMailAttachment"..i]
		button:GetRegions():Hide()

		local bg = CreateFrame("Frame", nil, button)
		bg:SetPoint("TOPLEFT", -1, 1)
		bg:SetPoint("BOTTOMRIGHT", 1, -1)
		bg:SetFrameLevel(0)
		R.CreateBD(bg, .25)
	end

	for i = 1, ATTACHMENTS_MAX_RECEIVE do
		local bu = _G["OpenMailAttachmentButton"..i]
		local ic = _G["OpenMailAttachmentButton"..i.."IconTexture"]

		bu:StyleButton(true)
		ic:SetTexCoord(.08, .92, .08, .92)

		local bg = CreateFrame("Frame", nil, bu)
		bg:SetPoint("TOPLEFT", -1, 1)
		bg:SetPoint("BOTTOMRIGHT", 1, -1)
		bg:SetFrameLevel(0)
		R.CreateBD(bg, .25)
	end

	hooksecurefunc("SendMailFrame_Update", function()
		for i = 1, ATTACHMENTS_MAX_SEND do
			local button = _G["SendMailAttachment"..i]
			if button:GetNormalTexture() then
				button:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
			end
			button:StyleButton(true)
		end
	end)
end

tinsert(R.SkinFuncs[AddOnName], LoadSkin)