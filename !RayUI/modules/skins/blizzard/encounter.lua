local R, C, L, DB = unpack(select(2, ...))
local AddOnName = ...

local function LoadSkin()
	EncounterJournal:DisableDrawLayer("BORDER")
	EncounterJournalInset:DisableDrawLayer("BORDER")
	EncounterJournalNavBar:DisableDrawLayer("BORDER")
	EncounterJournal:DisableDrawLayer("OVERLAY")
	EncounterJournalInstanceSelectDungeonTab:DisableDrawLayer("OVERLAY")
	EncounterJournalInstanceSelectRaidTab:DisableDrawLayer("OVERLAY")

	EncounterJournalPortrait:Hide()
	EncounterJournalInstanceSelectBG:Hide()
	EncounterJournalNavBar:GetRegions():Hide()
	EncounterJournalNavBarOverlay:Hide()
	EncounterJournalBg:Hide() 
	EncounterJournalTitleBg:Hide()
	EncounterJournalInsetBg:Hide()
	EncounterJournalInstanceSelectDungeonTabMid:Hide()
	EncounterJournalInstanceSelectRaidTabMid:Hide()
	EncounterJournalNavBarHomeButtonLeft:Hide()
	for i = 8, 10 do
		select(i, EncounterJournalInstanceSelectDungeonTab:GetRegions()):SetAlpha(0)
		select(i, EncounterJournalInstanceSelectRaidTab:GetRegions()):SetAlpha(0)
	end

	R.SetBD(EncounterJournal)

	EncounterJournalEncounterFrameInfoBossTab:ClearAllPoints()
	EncounterJournalEncounterFrameInfoBossTab:SetPoint("RIGHT", EncounterJournalEncounterFrameInfoResetButton, "LEFT", -28, 0)
	EncounterJournalEncounterFrameInfoLootTab:ClearAllPoints()
	EncounterJournalEncounterFrameInfoLootTab:SetPoint("LEFT", EncounterJournalEncounterFrameInfoBossTab, "RIGHT", -24, 0)
				
	EncounterJournalEncounterFrameInfoBossTab:SetFrameStrata("HIGH")
	EncounterJournalEncounterFrameInfoLootTab:SetFrameStrata("HIGH")
				
	EncounterJournalEncounterFrameInfoBossTab:SetScale(0.75)
	EncounterJournalEncounterFrameInfoLootTab:SetScale(0.75)

	EncounterJournalEncounterFrameInfoBossTab:SetNormalTexture(nil)
	EncounterJournalEncounterFrameInfoBossTab:SetPushedTexture(nil)
	EncounterJournalEncounterFrameInfoBossTab:SetDisabledTexture(nil)
	EncounterJournalEncounterFrameInfoBossTab:SetHighlightTexture(nil)

	EncounterJournalEncounterFrameInfoLootTab:SetNormalTexture(nil)
	EncounterJournalEncounterFrameInfoLootTab:SetPushedTexture(nil)
	EncounterJournalEncounterFrameInfoLootTab:SetDisabledTexture(nil)
	EncounterJournalEncounterFrameInfoLootTab:SetHighlightTexture(nil)

	local encounterbd = CreateFrame("Frame", nil, EncounterJournalEncounterFrameInfo)
	encounterbd:SetPoint("TOPLEFT", -1, 1)
	encounterbd:SetPoint("BOTTOMRIGHT", 1, -1)
	R.CreateBD(encounterbd, 0)

	for i = 1, 14 do
		local bu = _G["EncounterJournalInstanceSelectScrollFrameinstance"..i] or _G["EncounterJournalInstanceSelectScrollFrameScrollChildInstanceButton"..i]

		if bu then
			bu:SetNormalTexture("")
			bu:SetHighlightTexture("")

			local bg = CreateFrame("Frame", nil, bu)
			bg:SetPoint("TOPLEFT", 4, -4)
			bg:SetPoint("BOTTOMRIGHT", -5, 3)
			R.CreateBD(bg, 0)
		end
	end

	R.Reskin(EncounterJournalNavBarHomeButton)
	R.Reskin(EncounterJournalInstanceSelectDungeonTab)
	R.Reskin(EncounterJournalInstanceSelectRaidTab)
	R.ReskinClose(EncounterJournalCloseButton)
	R.ReskinInput(EncounterJournalSearchBox)
	R.ReskinScroll(EncounterJournalInstanceSelectScrollFrameScrollBar)
	R.ReskinScroll(EncounterJournalEncounterFrameInstanceFrameLoreScrollFrameScrollBar)
	R.ReskinScroll(EncounterJournalEncounterFrameInfoDetailsScrollFrameScrollBar)
end

R.SkinFuncs["Blizzard_EncounterJournal"] = LoadSkin

if R.HoT then return end

local function LoadOldSkin()
	R.SetBD(EncounterJournal)
	EncounterJournalEncounterFrameInfoBossTab:ClearAllPoints()
	EncounterJournalEncounterFrameInfoBossTab:SetPoint("LEFT", EncounterJournalEncounterFrameInfoEncounterTile, "RIGHT", -10, 4)
	EncounterJournalEncounterFrameInfoLootTab:ClearAllPoints()
	EncounterJournalEncounterFrameInfoLootTab:SetPoint("LEFT", EncounterJournalEncounterFrameInfoBossTab, "RIGHT", -24, 0)
				
	EncounterJournalEncounterFrameInfoBossTab:SetFrameStrata("HIGH")
	EncounterJournalEncounterFrameInfoLootTab:SetFrameStrata("HIGH")
				
	EncounterJournalEncounterFrameInfoBossTab:SetScale(0.75)
	EncounterJournalEncounterFrameInfoLootTab:SetScale(0.75)

	EncounterJournalEncounterFrameInfoBossTab:SetNormalTexture(nil)
	EncounterJournalEncounterFrameInfoBossTab:SetPushedTexture(nil)
	EncounterJournalEncounterFrameInfoBossTab:SetDisabledTexture(nil)
	EncounterJournalEncounterFrameInfoBossTab:SetHighlightTexture(nil)

	EncounterJournalEncounterFrameInfoLootTab:SetNormalTexture(nil)
	EncounterJournalEncounterFrameInfoLootTab:SetPushedTexture(nil)
	EncounterJournalEncounterFrameInfoLootTab:SetDisabledTexture(nil)
	EncounterJournalEncounterFrameInfoLootTab:SetHighlightTexture(nil)
	
	EncounterJournal:DisableDrawLayer("BORDER")
	EncounterJournalInset:DisableDrawLayer("BORDER")
	EncounterJournalNavBar:DisableDrawLayer("BORDER")
	EncounterJournal:DisableDrawLayer("OVERLAY")
	EncounterJournalInstanceSelectDungeonTab:DisableDrawLayer("OVERLAY")
	EncounterJournalInstanceSelectRaidTab:DisableDrawLayer("OVERLAY")

	local encounterbd = CreateFrame("Frame", nil, EncounterJournalEncounterFrameInfo)
	encounterbd:SetPoint("TOPLEFT", -1, 1)
	encounterbd:SetPoint("BOTTOMRIGHT", 1, -1)
	R.CreateBD(encounterbd, 0)
	
	EncounterJournalPortrait:Hide()
	EncounterJournalInstanceSelectBG:Hide()
	EncounterJournalNavBar:GetRegions():Hide()
	EncounterJournalNavBarOverlay:Hide()
	EncounterJournalNavBarHomeButtonLeft:Hide()
	EncounterJournalBg:Hide()
	EncounterJournalInsetBg:Hide()
	EncounterJournalTitleBg:Hide()
	EncounterJournalInstanceSelectDungeonTabMid:Hide()
	EncounterJournalInstanceSelectRaidTabMid:Hide()
	for i = 8, 10 do
		select(i, EncounterJournalInstanceSelectDungeonTab:GetRegions()):SetAlpha(0)
		select(i, EncounterJournalInstanceSelectRaidTab:GetRegions()):SetAlpha(0)
	end
	R.Reskin(EncounterJournalNavBarHomeButton)
	R.Reskin(EncounterJournalInstanceSelectDungeonTab)
	R.Reskin(EncounterJournalInstanceSelectRaidTab)
	R.ReskinClose(EncounterJournalCloseButton)
	R.ReskinScroll(EncounterJournalInstanceSelectScrollFrameScrollBar)
	R.ReskinScroll(EncounterJournalEncounterFrameInfoDetailsScrollFrameScrollBar)
	R.ReskinScroll(EncounterJournalEncounterFrameInstanceFrameLoreScrollFrameScrollBar)
	R.ReskinInput(EncounterJournalSearchBox)
end
tinsert(R.SkinFuncs[AddOnName], LoadOldSkin)