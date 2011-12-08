local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	if R.HoT then
		R.ReskinCheck(RaidFrameAllAssistCheckButton)
	else
		RaidFrameRaidBrowserButton:ClearAllPoints()
		RaidFrameRaidBrowserButton:SetPoint("TOPLEFT", RaidFrame, "TOPLEFT", 38, -35)
		R.Reskin(RaidFrameRaidBrowserButton)
	end
	ReadyCheckFrame:HookScript("OnShow", function(self) if UnitIsUnit("player", self.initiator) then self:Hide() end end)
	R.Reskin(RaidFrameReadyCheckButton)
	R.Reskin(ReadyCheckFrameYesButton)
	R.Reskin(ReadyCheckFrameNoButton)
	ReadyCheckPortrait:SetAlpha(0)
	select(2, ReadyCheckListenerFrame:GetRegions()):Hide()
end

R.SkinFuncs["Blizzard_RaidUI"] = LoadSkin