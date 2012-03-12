local R, L, P = unpack(select(2, ...)) --Inport: Engine, Locales, ProfileDB
local S = R:GetModule("Skins")

local function LoadSkin()
	local bg = CreateFrame("Frame", nil, GuildBankFrame)
	bg:SetPoint("TOPLEFT", 10, -8)
	bg:SetPoint("BOTTOMRIGHT", 0, 6)
	bg:SetFrameLevel(GuildBankFrame:GetFrameLevel()-1)
	S:CreateBD(bg)
	S:CreateSD(bg)

	GuildBankPopupFrame:SetPoint("TOPLEFT", GuildBankFrame, "TOPRIGHT", 2, -30)

	local bd = CreateFrame("Frame", nil, GuildBankPopupFrame)
	bd:SetPoint("TOPLEFT")
	bd:SetPoint("BOTTOMRIGHT", -28, 26)
	bd:SetFrameLevel(GuildBankPopupFrame:GetFrameLevel()-1)
	S:CreateBD(bd)
	S:CreateBD(GuildBankPopupEditBox, .25)

	GuildBankEmblemFrame:Hide()
	GuildBankPopupFrameTopLeft:Hide()
	GuildBankPopupFrameBottomLeft:Hide()
	select(2, GuildBankPopupFrame:GetRegions()):Hide()
	select(4, GuildBankPopupFrame:GetRegions()):Hide()
	GuildBankPopupNameLeft:Hide()
	GuildBankPopupNameMiddle:Hide()
	GuildBankPopupNameRight:Hide()
	GuildBankPopupScrollFrame:GetRegions():Hide()
	select(2, GuildBankPopupScrollFrame:GetRegions()):Hide()
	GuildBankTabTitleBackground:SetAlpha(0)
	GuildBankTabTitleBackgroundLeft:SetAlpha(0)
	GuildBankTabTitleBackgroundRight:SetAlpha(0)
	GuildBankTabLimitBackground:SetAlpha(0)
	GuildBankTabLimitBackgroundLeft:SetAlpha(0)
	GuildBankTabLimitBackgroundRight:SetAlpha(0)
	GuildBankFrameLeft:Hide()
	GuildBankFrameRight:Hide()
	local a, b = GuildBankTransactionsScrollFrame:GetRegions()
	a:Hide()
	b:Hide()

	for i = 1, 4 do
		local tab = _G["GuildBankFrameTab"..i]
		S:CreateTab(tab)

		if i ~= 1 then
			tab:SetPoint("LEFT", _G["GuildBankFrameTab"..i-1], "RIGHT", -15, 0)
		end
	end

	S:Reskin(GuildBankFrameWithdrawButton)
	S:Reskin(GuildBankFrameDepositButton)
	S:Reskin(GuildBankFramePurchaseButton)
	S:Reskin(GuildBankPopupOkayButton)
	S:Reskin(GuildBankPopupCancelButton)
	S:Reskin(GuildBankInfoSaveButton)

	GuildBankFrameWithdrawButton:ClearAllPoints()
	GuildBankFrameWithdrawButton:Point("RIGHT", GuildBankFrameDepositButton, "LEFT", -1, 0)

	for i = 1, NUM_GUILDBANK_COLUMNS do
		_G["GuildBankColumn"..i]:GetRegions():Hide()
		for j = 1, NUM_SLOTS_PER_GUILDBANK_GROUP do
			local bu = _G["GuildBankColumn"..i.."Button"..j]
			bu:StyleButton(true)

			_G["GuildBankColumn"..i.."Button"..j.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)
			_G["GuildBankColumn"..i.."Button"..j.."NormalTexture"]:SetAlpha(0)

			local bg = CreateFrame("Frame", nil, bu)
			bg:Point("TOPLEFT", -1, 1)
			bg:Point("BOTTOMRIGHT", 1, -1)
			bg:SetFrameLevel(bu:GetFrameLevel()-1)
			S:CreateBD(bg, 0)
		end
	end

	for i = 1, 8 do
		local tb = _G["GuildBankTab"..i]
		local bu = _G["GuildBankTab"..i.."Button"]
		local ic = _G["GuildBankTab"..i.."ButtonIconTexture"]
		local nt = _G["GuildBankTab"..i.."ButtonNormalTexture"]

		S:CreateBG(bu)
		S:CreateSD(bu, 5, 0, 0, 0, 1, 1)

		local a1, p, a2, x, y = bu:GetPoint()
		bu:Point(a1, p, a2, x + 11, y)

		ic:SetTexCoord(.08, .92, .08, .92)
		tb:GetRegions():Hide()
		nt:SetAlpha(0)

		_G["GuildBankTab"..i]:StripTextures()

		bu:StyleButton(true)
	end

	local GuildBankClose = select(14, GuildBankFrame:GetChildren())
	S:ReskinClose(GuildBankClose, "TOPRIGHT", GuildBankFrame, "TOPRIGHT", -4, -12)
	S:ReskinScroll(GuildBankTransactionsScrollFrameScrollBar)
	S:ReskinScroll(GuildBankInfoScrollFrameScrollBar)
	S:ReskinScroll(GuildBankPopupScrollFrameScrollBar)
end

S:RegisterSkin("Blizzard_GuildBankUI", LoadSkin)