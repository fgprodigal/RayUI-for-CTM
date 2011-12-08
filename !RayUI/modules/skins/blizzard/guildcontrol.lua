local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	R.CreateBD(GuildControlUI)
	R.CreateSD(GuildControlUI)
	R.CreateBD(GuildControlUIRankBankFrameInset, .25)

	for i = 1, 9 do
		select(i, GuildControlUI:GetRegions()):Hide()
	end

	for i = 1, 8 do
		select(i, GuildControlUIRankBankFrameInset:GetRegions()):Hide()
	end

	GuildControlUIRankSettingsFrameChatBg:SetAlpha(0)
	GuildControlUIRankSettingsFrameRosterBg:SetAlpha(0)
	GuildControlUIRankSettingsFrameInfoBg:SetAlpha(0)
	GuildControlUIRankSettingsFrameBankBg:SetAlpha(0)
	GuildControlUITopBg:Hide()
	GuildControlUIHbar:Hide()
	GuildControlUIRankBankFrameInsetScrollFrameTop:SetAlpha(0)
	GuildControlUIRankBankFrameInsetScrollFrameBottom:SetAlpha(0)

	hooksecurefunc("GuildControlUI_RankOrder_Update", function()
		if not reskinnedranks then
			for i = 1, GuildControlGetNumRanks() do
				R.ReskinInput(_G["GuildControlUIRankOrderFrameRank"..i.."NameEditBox"], 20)
			end
			reskinnedranks = true
		end
	end)

	hooksecurefunc("GuildControlUI_BankTabPermissions_Update", function()
		for i = 1, GetNumGuildBankTabs()+1 do
			local tab = "GuildControlBankTab"..i
			local bu = _G[tab]
			if bu and not bu.reskinned then
				_G[tab.."Bg"]:Hide()
				R.CreateBD(bu, .12)
				R.Reskin(_G[tab.."BuyPurchaseButton"])
				R.ReskinInput(_G[tab.."OwnedStackBox"])

				bu.reskinned = true
			end
		end
	end)

	R.Reskin(GuildControlUIRankOrderFrameNewButton)

	R.ReskinClose(GuildControlUICloseButton)
	R.ReskinScroll(GuildControlUIRankBankFrameInsetScrollFrameScrollBar)
	R.ReskinDropDown(GuildControlUINavigationDropDown)
	R.ReskinDropDown(GuildControlUIRankSettingsFrameRankDropDown)
	R.ReskinDropDown(GuildControlUIRankBankFrameRankDropDown)
	R.ReskinInput(GuildControlUIRankSettingsFrameGoldBox, 20)
end

R.SkinFuncs["Blizzard_GuildControlUI"] = LoadSkin