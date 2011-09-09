local R, C, DB = unpack(select(2, ...))

-- if not IsAddOnLoaded("Filger") then return end

R.Filger = R.Filger or {}

R.Filger.Interval = 4
R.Filger.PlayerBuffSize = 32
R.Filger.SpecialPlayerBuffSize = 47
R.Filger.PVPPlayerDebuffSize = 72
R.Filger.PlayerCDBarWidth = 204
R.Filger.PlayerCDSize = 32

R.Filger.TargetBuffSize = 32
R.Filger.TargetDebuffSize = 47
R.Filger.PVPTargetDebuffSize = 72

R.Filger.FocusDebuffSize = 32
R.Filger.FocusDebuffBarWidth = 164
R.Filger.PlayerProcSize = 47

local test = CreateFrame("Frame")
test:RegisterEvent("PLAYER_LOGIN")
test:SetScript("OnEvent", function(self, event)
	local PlayerBuffs = CreateFrame("Frame","FilgerPlayerBuffs",oUF_FreebPlayer)
	PlayerBuffs:SetPoint("BOTTOMRIGHT", oUF_FreebPlayer, "TOPRIGHT", 2, 5)
	PlayerBuffs:SetSize(R.Filger.PlayerBuffSize * 4 + R.Filger.Interval * 3 , R.Filger.PlayerBuffSize)
	PlayerBuffs:SetFrameLevel(1)
	PlayerBuffs:SetFrameStrata("BACKGROUND")
	R.CreateMover(PlayerBuffs, "FilgerCooldownsMover", "Filger玩家BUFF锚点")
	
	local PlayerProcs = CreateFrame("Frame","FilgerPlayerProcs",oUF_FreebPlayer)
	PlayerProcs:SetPoint("BOTTOMRIGHT", oUF_FreebPlayer, "TOPRIGHT", 2, 40)
	PlayerProcs:SetSize(R.Filger.PlayerProcSize * 4 + R.Filger.Interval * 3 , R.Filger.PlayerProcSize)
	PlayerProcs:SetFrameLevel(1)
	PlayerProcs:SetFrameStrata("BACKGROUND")
	R.CreateMover(PlayerProcs, "FilgerPlayerProcsMover", "Filger玩家重要技能锚点")
	
	local TargetBuffs = CreateFrame("Frame","FilgerTargetBuffs",oUF_FreebTarget)
	TargetBuffs:SetPoint("BOTTOMLEFT", oUF_FreebTarget, "TOPLEFT", -2, 5)
	TargetBuffs:SetSize(R.Filger.TargetBuffSize * 4 + R.Filger.Interval * 3 , R.Filger.TargetBuffSize)
	TargetBuffs:SetFrameLevel(1)
	TargetBuffs:SetFrameStrata("BACKGROUND")
	R.CreateMover(TargetBuffs, "FilgerTargetBuffsMover", "Filger目标BUFF锚点")
	
	local TargetDebuffs = CreateFrame("Frame","FilgerTargetDebuffs",oUF_FreebTarget)
	TargetDebuffs:SetPoint("BOTTOMLEFT", oUF_FreebTarget, "TOPLEFT", -2, 40)
	TargetDebuffs:SetSize(R.Filger.TargetDebuffSize * 4 + R.Filger.Interval * 3 , R.Filger.TargetDebuffSize)
	TargetDebuffs:SetFrameLevel(1)
	TargetDebuffs:SetFrameStrata("BACKGROUND")
	R.CreateMover(TargetDebuffs, "FilgerTargetDebuffsMover", "Filger目标DEBUFF锚点")
	
	local FocusDebuffs = CreateFrame("Frame","FilgerFocusDebuffs",oUF_FreebFocus)
	FocusDebuffs:SetPoint("BOTTOMRIGHT", oUF_FreebFocus, "TOPRIGHT", 0, 5)
	FocusDebuffs:SetSize(R.Filger.FocusDebuffBarWidth + R.Filger.FocusDebuffSize + R.Filger.Interval , R.Filger.FocusDebuffSize)
	FocusDebuffs:SetFrameLevel(1)
	FocusDebuffs:SetFrameStrata("BACKGROUND")
	R.CreateMover(FocusDebuffs, "FilgerFocusDebuffsMover", "Filger焦点DEBUFF锚点")
	
	local PlayerCDs = CreateFrame("Frame","FilgerPlayerCDs",oUF_FreebPlayer)
	PlayerCDs:SetPoint("BOTTOMRIGHT", oUF_FreebPlayer, "TOPRIGHT", 2, 165)
	PlayerCDs:SetSize(R.Filger.PlayerCDBarWidth + R.Filger.PlayerCDSize + R.Filger.Interval , R.Filger.PlayerCDSize)
	PlayerCDs:SetFrameLevel(1)
	PlayerCDs:SetFrameStrata("BACKGROUND")
	R.CreateMover(PlayerCDs, "FilgerPlayerCDsMover", "Filger玩家CD锚点")
	
	local SpecialPlayerBuffs = CreateFrame("Frame","FilgerSpecialPlayerBuffs",oUF_FreebPlayer)
	SpecialPlayerBuffs:SetPoint("BOTTOMRIGHT", oUF_FreebPlayer, "TOPRIGHT", 2, 90)
	SpecialPlayerBuffs:SetSize(R.Filger.SpecialPlayerBuffSize * 4 + R.Filger.Interval * 3 , R.Filger.SpecialPlayerBuffSize)
	SpecialPlayerBuffs:SetFrameLevel(1)
	SpecialPlayerBuffs:SetFrameStrata("BACKGROUND")
	R.CreateMover(SpecialPlayerBuffs, "FilgerSpecialPlayerBuffsMover", "Filger玩家特殊BUFF锚点")
	
	local PVPPlayerDebuffs = CreateFrame("Frame","FilgerPVPPlayerDebuffs",oUF_FreebPlayer)
	PVPPlayerDebuffs:SetPoint("TOPRIGHT", oUF_FreebPlayer, "BOTTOMRIGHT", 2, -50)
	PVPPlayerDebuffs:SetSize(R.Filger.PVPPlayerDebuffSize * 4 + R.Filger.Interval * 3 , R.Filger.PVPPlayerDebuffSize)
	PVPPlayerDebuffs:SetFrameLevel(1)
	PVPPlayerDebuffs:SetFrameStrata("BACKGROUND")
	R.CreateMover(PVPPlayerDebuffs, "FilgerPVPPlayerDebuffsMover", "Filger玩家PVP DEBUFF锚点")
	
	local PVPTargetDebuffs = CreateFrame("Frame","FilgerPVPTargetDebuffs",oUF_FreebTarget)
	PVPTargetDebuffs:SetPoint("BOTTOMLEFT", oUF_FreebTarget, "TOPLEFT", -2, 90)
	PVPTargetDebuffs:SetSize(R.Filger.PVPTargetDebuffSize * 4 + R.Filger.Interval * 3 , R.Filger.PVPTargetDebuffSize)
	PVPTargetDebuffs:SetFrameLevel(1)
	PVPTargetDebuffs:SetFrameStrata("BACKGROUND")
	R.CreateMover(PVPTargetDebuffs, "FilgerPVPTargetDebuffsMover", "Filger目标PVP DEBUFF锚点")
end)