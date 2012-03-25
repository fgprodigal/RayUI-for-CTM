local R, L, P = unpack(select(2, ...)) --Inport: Engine, Locales, ProfileDB
local M = R:GetModule("Misc")

local function LoadFunc()
	if not M.db.raidbuffreminder then return end

	local BuffReminderRaidBuffs = {
		Flask = {
			94160, --"Flask of Flowing Water"
			79469, --"Flask of Steelskin"
			79470, --"Flask of the Draconic Mind"
			79471, --"Flask of the Winds
			79472, --"Flask of Titanic Strength"
			79638, --"Flask of Enhancement-STR"
			79639, --"Flask of Enhancement-AGI"
			79640, --"Flask of Enhancement-INT"
			92679, --Flask of battle
		},
		BattleElixir = {
			--Scrolls
			89343, --Agility
			63308, --Armor 
			89347, --Int
			89342, --Spirit
			63306, --Stam
			89346, --Strength
			
			--Elixirs
			79481, --Hit
			79632, --Haste
			79477, --Crit
			79635, --Mastery
			79474, --Expertise
			79468, --Spirit
		},
		GuardianElixir = {
			79480, --Armor
			79631, --Resistance+90
		},
		Food = {
			87545, --90 STR
			87546, --90 AGI
			87547, --90 INT
			87548, --90 SPI
			87549, --90 MAST
			87550, --90 HIT
			87551, --90 CRIT
			87552, --90 HASTE
			87554, --90 DODGE
			87555, --90 PARRY
			87635, --90 EXP
			87556, --60 STR
			87557, --60 AGI
			87558, --60 INT
			87559, --60 SPI
			87560, --60 MAST
			87561, --60 HIT
			87562, --60 CRIT
			87563, --60 HASTE
			87564, --60 DODGE
			87634, --60 EXP
			87554, --Seafood Feast
		},
	}

	local flaskbuffs = BuffReminderRaidBuffs["Flask"]
	local battleelixirbuffs = BuffReminderRaidBuffs["BattleElixir"]
	local guardianelixirbuffs = BuffReminderRaidBuffs["GuardianElixir"]
	local foodbuffs = BuffReminderRaidBuffs["Food"]	
	local battleelixired	
	local guardianelixired	

	--Setup Caster Buffs
	local function SetCasterOnlyBuffs()
		Spell3Buff = { --Total Stats
			1126, -- "Mark of the wild"
			90363, --"Embrace of the Shale Spider"
			20217, --"Greater Blessing of Kings",
		}
		Spell4Buff = { --Total Stamina
			469, -- Commanding
			6307, -- Blood Pact
			90364, -- Qiraji Fortitude
			72590, -- Drums of fortitude
			21562, -- Fortitude
		}
		Spell5Buff = { --Total Mana
			54424, --"Fel Intelligence"
			61316, --"Dalaran Brilliance"
			79058, --"Arcane Brilliance"
		}
		Spell6Buff = { --Mana Regen
			54424, --"Fel Intelligence"
			5675, --"Mana Spring Totem"
			19740, --"Blessing of Might"
		}
	end

	--Setup everyone else's buffs
	local function SetBuffs()
		Spell3Buff = { --Total Stats
			1126, -- "Mark of the wild"
			90363, --"Embrace of the Shale Spider"
			20217, --"Greater Blessing of Kings",
		}
		Spell4Buff = { --Total Stamina
			469, -- Commanding
			6307, -- Blood Pact
			90364, -- Qiraji Fortitude
			72590, -- Drums of fortitude
			21562, -- Fortitude
		}
		Spell5Buff = { --Total Mana
			8075, --"Strength of Earth Totem"
			93435, --"Roar of Courage"
			57330, --"Horn of Winter"
			6673, --"Battle Shout"
		}
		Spell6Buff = { --Total AP
			19740, --"Blessing of Might" placing it twice because i like the icon better :D code will stop after this one is read, we want this first 
			30808, --"Unleashed Rage"
			53138, --Abom Might
			19506, --Trushot
			19740, --"Blessing of Might"
		}
	end

	local function CheckElixir(unit)
		if (battleelixirbuffs and battleelixirbuffs[1]) then
			for i, battleelixirbuffs in pairs(battleelixirbuffs) do
				local spellname = select(1, GetSpellInfo(battleelixirbuffs))
				if UnitAura("player", spellname) then
					FlaskFrame.t:SetTexture(select(3, GetSpellInfo(battleelixirbuffs)))
					battleelixired = true
					break
				else
					battleelixired = false
				end
			end
		end
		
		if (guardianelixirbuffs and guardianelixirbuffs[1]) then
			for i, guardianelixirbuffs in pairs(guardianelixirbuffs) do
				local spellname = select(1, GetSpellInfo(guardianelixirbuffs))
				if UnitAura("player", spellname) then
					guardianelixired = true
					if not battleelixired then
						FlaskFrame.t:SetTexture(select(3, GetSpellInfo(guardianelixirbuffs)))
					end
					break
				else
					guardianelixired = false
				end
			end
		end	
		
		if guardianelixired == true and battleelixired == true then
			FlaskFrame:SetAlpha(0.2)
			return
		else
			FlaskFrame:SetAlpha(1)
		end
	end

	--Main Script
	RaidReminderShown = true
	local function OnAuraChange(self, event, arg1, unit)
		if (event == "UNIT_AURA" and arg1 ~= "player") then 
			return
		end
		if (M.db.raidbuffreminderparty and GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0) then 
			self:Hide()
			return
		else
			self:Show()
		end
		
		FlaskFrame.locale = L["合剂"]
		FoodFrame.locale = L["食物Buff"]
		Spell3Frame.locale = L["全属性Buff"]
		Spell4Frame.locale = L["血量上限Buff"]
		--If We're a caster we may want to see differant buffs
		if R.Role == "Caster" then 
			SetCasterOnlyBuffs()
			Spell5Frame.locale = L["法力上限Buff"]
			Spell6Frame.locale = L["法力恢复Buff"]
		else
			SetBuffs()
			Spell5Frame.locale = L["力量与敏捷Buff"]
			Spell6Frame.locale = L["攻击强度Buff"]
		end
		
		--Start checking buffs to see if we can find a match from the list
		if (flaskbuffs and flaskbuffs[1]) then
			FlaskFrame.t:SetTexture(select(3, GetSpellInfo(flaskbuffs[1])))
			for i, flaskbuffs in pairs(flaskbuffs) do
				local spellname = select(1, GetSpellInfo(flaskbuffs))
				if UnitAura("player", spellname) then
					FlaskFrame.t:SetTexture(select(3, GetSpellInfo(flaskbuffs)))
					FlaskFrame:SetAlpha(0.2)
					break
				else
					CheckElixir()
				end
			end
		end
		
		if (foodbuffs and foodbuffs[1]) then
			FoodFrame.t:SetTexture(select(3, GetSpellInfo(foodbuffs[1])))
			for i, foodbuffs in pairs(foodbuffs) do
				local spellname = select(1, GetSpellInfo(foodbuffs))
				if UnitAura("player", spellname) then
					FoodFrame:SetAlpha(0.2)
					FoodFrame.t:SetTexture(select(3, GetSpellInfo(foodbuffs)))
					break
				else
					FoodFrame:SetAlpha(1)
				end
			end
		end
		
		for i, Spell3Buff in pairs(Spell3Buff) do
			local spellname = select(1, GetSpellInfo(Spell3Buff))
			if UnitAura("player", spellname) then
				Spell3Frame:SetAlpha(0.2)
				Spell3Frame.t:SetTexture(select(3, GetSpellInfo(Spell3Buff)))
				break
			else
				Spell3Frame:SetAlpha(1)
				Spell3Frame.t:SetTexture(select(3, GetSpellInfo(Spell3Buff)))
			end
		end
		
		for i, Spell4Buff in pairs(Spell4Buff) do
			local spellname = select(1, GetSpellInfo(Spell4Buff))
			if UnitAura("player", spellname) then
				Spell4Frame:SetAlpha(0.2)
				Spell4Frame.t:SetTexture(select(3, GetSpellInfo(Spell4Buff)))
				break
			else
				Spell4Frame:SetAlpha(1)
				Spell4Frame.t:SetTexture(select(3, GetSpellInfo(Spell4Buff)))
			end
		end

		for i, Spell5Buff in pairs(Spell5Buff) do
			local spellname = select(1, GetSpellInfo(Spell5Buff))
			if UnitAura("player", spellname) then
				Spell5Frame:SetAlpha(0.2)
				Spell5Frame.t:SetTexture(select(3, GetSpellInfo(Spell5Buff)))
				break
			else
				Spell5Frame:SetAlpha(1)
				Spell5Frame.t:SetTexture(select(3, GetSpellInfo(Spell5Buff)))
			end
		end

		for i, Spell6Buff in pairs(Spell6Buff) do
			local spellname = select(1, GetSpellInfo(Spell6Buff))
			if UnitAura("player", spellname) then
				Spell6Frame:SetAlpha(0.2)
				Spell6Frame.t:SetTexture(select(3, GetSpellInfo(Spell6Buff)))
				break
			else
				Spell6Frame:SetAlpha(1)
				Spell6Frame.t:SetTexture(select(3, GetSpellInfo(Spell6Buff)))
			end
		end	
	end

	local bsize = ((Minimap:GetWidth() - 6) / 6) - 4

	--Create the Main bar
	local raidbuff_reminder = CreateFrame("Frame", "RaidBuffReminder", Minimap)
	raidbuff_reminder:SetSize(Minimap:GetWidth(), bsize)
	raidbuff_reminder:Point("TOPLEFT", Minimap, "BOTTOMLEFT", 0, -3)
	raidbuff_reminder:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	raidbuff_reminder:RegisterEvent("UNIT_INVENTORY_CHANGED")
	raidbuff_reminder:RegisterEvent("UNIT_AURA")
	raidbuff_reminder:RegisterEvent("PLAYER_REGEN_ENABLED")
	raidbuff_reminder:RegisterEvent("PLAYER_REGEN_DISABLED")
	raidbuff_reminder:RegisterEvent("PLAYER_ENTERING_WORLD")
	raidbuff_reminder:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	raidbuff_reminder:RegisterEvent("CHARACTER_POINTS_CHANGED")
	raidbuff_reminder:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	if M.db.raidbuffreminderparty then
		raidbuff_reminder:RegisterEvent("PARTY_MEMBERS_CHANGED")
	end
	raidbuff_reminder:SetScript("OnEvent", OnAuraChange)

	--Function to create buttons
	local function CreateButton(name, relativeTo, firstbutton)
		local button = CreateFrame("Frame", name, RaidBuffReminder)
		button:SetSize(bsize, bsize)
		button:CreateShadow("Background")
		if firstbutton == true then
			button:SetPoint("TOPLEFT", relativeTo, "BOTTOMLEFT", 0, -5)
		else
			button:SetPoint("LEFT", relativeTo, "RIGHT", 6, 0)
		end
		button:SetFrameLevel(RaidBuffReminder:GetFrameLevel() + 2)
		
		button.t = button:CreateTexture(name..".t", "OVERLAY")
		button.t:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		button.t:SetAllPoints()
		
		button:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(RaidBuffReminder, 'ANCHOR_BOTTOM', 0, -10)
			if self.locale and self:GetAlpha() == 1 then
				GameTooltip:AddLine(L["缺少"]..self.locale)
				GameTooltip:Show()
			end
		end)
		button:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	end

	--Create Buttons
	CreateButton("FlaskFrame", Minimap, true)
	CreateButton("FoodFrame", FlaskFrame, false)
	CreateButton("Spell3Frame", FoodFrame, false)
	CreateButton("Spell4Frame", Spell3Frame, false)
	CreateButton("Spell5Frame", Spell4Frame, false)
	CreateButton("Spell6Frame", Spell5Frame, false)
end

M:RegisterMiscModule("RaidBuffReminder", LoadFunc)