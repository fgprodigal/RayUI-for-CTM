local R, L, P = unpack(select(2, ...)) --Inport: Engine, Locales, ProfileDB
local UF = R:GetModule("UnitFrames")

UF.PvEMeleeBossDebuffs = {
	-- 4% Melee dmg
	[GetSpellInfo(30070)] = true, 		-- Blood Frenzy (Warrior (Arms))
	[GetSpellInfo(58683)] = true,			-- Savage Combat (Rogue (Combat))
	[GetSpellInfo(81326)] = true,			-- Brittle Bones (Deathknight (Frost))
	[GetSpellInfo(50518)] = true,			-- Ravage (Hunter (Ravager))
	[GetSpellInfo(55749)] = true,			-- Acid Spit (Hunter (Worm))
	-- 12% reduced armor
	[GetSpellInfo(91565)] = true,			-- Faerie Fire (Druid)
	[GetSpellInfo(58567)] = true, 		-- Sunder Armor (Warrior)
	[GetSpellInfo(8647)] = true,			-- Expose Armor (Rogue)
	[GetSpellInfo(35387)] = true,			-- Corrosive Spit (Hunter (Serpent))
	[GetSpellInfo(50498)] = true, 		-- Tear Armor (Hunter (Raptor))
	-- 30% increased bleed dmg
	[GetSpellInfo(33876)] = true,			-- Mangle (Cat) (Druid (Cat))
	[GetSpellInfo(33878)] = true, 		-- Mangle (Bear) (Druid (Bear))
	[GetSpellInfo(46857)] = true, 		-- Trauma (Warrior (Arms))
	[GetSpellInfo(16511)] = true, 		-- Hemorrhage (Rogue (Subtlety))
	[GetSpellInfo(50271)] = true, 		-- Tendon Rip (Hunter (Hyena))
	[GetSpellInfo(35290)] = true, 		-- Gore (Hunter (Boar))
	[GetSpellInfo(57386)] = true, 		-- Stampede (Hunter (Rhino))
	-- 10% reduced healing
	[GetSpellInfo(13218)] = true, 		-- Wound Poison (Rogue)
	[GetSpellInfo(12294)] = true, 		-- Mortal Strike (Warrior (Arms))
	[GetSpellInfo(56112)] = true, 		-- Furious Attacks (Warrior (Fury))
	[GetSpellInfo(82654)] = true, 		-- Widow Venom (Hunter (Beast Mastery))
	[GetSpellInfo(54680)] = true, 		-- Monstrous Bite (Hunter (Exotic Devlisaur))
	[GetSpellInfo(30213)] = true, 		-- Legion Strike (Warlock (Felguard))
	[GetSpellInfo(15273)] = true, 		-- Improved Mind Blast (Priest (Shadow))
	-- 30% reduced cast speed
	[GetSpellInfo(1714)] = true, 		-- Curse of Tongues (Warlock)
	[GetSpellInfo(5760)] = true, 		-- Mind-numbing Poison (Rogue)
	[GetSpellInfo(31589)] = true, 		-- Slow (Mage (Arcane))
	[GetSpellInfo(73975)] = true, 		-- Necrotic Strike (Death Knight (Unholy))
	[GetSpellInfo(58604)] = true, 		-- Lava Breath (Hunter (Core Hound)) 25%
	[GetSpellInfo(50274)] = true, 		-- Spore Cloud (Hunter (Sporebat))
}
UF.PvECasterBossDebuffs = {
	-- 8% Spell dmg
	[GetSpellInfo(1490)] = true,			-- Curse of the Elements (Warlock)
	[GetSpellInfo(60433)] = true, 		-- Earth and Moon (Druid (Balance))
	[GetSpellInfo(93068)] = true,			-- Master Poisoner (Rogue (Assassination))
	[GetSpellInfo(65142)] = true, 		-- Ebon Plague (Deathknight (Unholy))
	[GetSpellInfo(24844)] = true, 		-- Lightning Breath (Hunter (Wind Serpent))
	[GetSpellInfo(34889)] = true,			-- Fire Breath (Hunter (Dragonhawk))
	-- 5% Spell crit
	[GetSpellInfo(22959)] = true,			-- Critical Mass (Mage (Fire))
	[GetSpellInfo(17800)] = true, 		-- Shadow and Flame (Warlock (Destruction))
	-- 10% reduced healing
	[GetSpellInfo(13218)] = true, 		-- Wound Poison (Rogue)
	[GetSpellInfo(12294)] = true, 		-- Mortal Strike (Warrior (Arms))
	[GetSpellInfo(56112)] = true, 		-- Furious Attacks (Warrior (Fury))
	[GetSpellInfo(82654)] = true, 		-- Widow Venom (Hunter (Beast Mastery))
	[GetSpellInfo(54680)] = true, 		-- Monstrous Bite (Hunter (Exotic Devlisaur))
	[GetSpellInfo(30213)] = true, 		-- Legion Strike (Warlock (Felguard))
	[GetSpellInfo(15273)] = true, 		-- Improved Mind Blast (Priest (Shadow))
	-- 30% reduced cast speed
	[GetSpellInfo(1714)] = true, 		-- Curse of Tongues (Warlock)
	[GetSpellInfo(5760)] = true, 		-- Mind-numbing Poison (Rogue)
	[GetSpellInfo(31589)] = true, 		-- Slow (Mage (Arcane))
	[GetSpellInfo(73975)] = true, 		-- Necrotic Strike (Death Knight (Unholy))
	[GetSpellInfo(58604)] = true, 		-- Lava Breath (Hunter (Core Hound)) 25%
	[GetSpellInfo(50274)] = true, 		-- Spore Cloud (Hunter (Sporebat))
}
UF.PvETankBossDebuffs = {
	-- 12% reduced armor
	[GetSpellInfo(91565)] = true,			-- Faerie Fire (Druid)
	[GetSpellInfo(58567)] = true, 		-- Sunder Armor (Warrior)
	[GetSpellInfo(8647)] = true,			-- Expose Armor (Rogue)
	[GetSpellInfo(35387)] = true,			-- Corrosive Spit (Hunter (Serpent))
	[GetSpellInfo(50498)] = true, 		-- Tear Armor (Hunter (Raptor))
	-- 20% reduced attack speed
	[GetSpellInfo(58180)] = true,			-- Infected Wounds (Druid (Feral))
	[GetSpellInfo(6343)] = true, 			-- Thunderclap (Warrior)
	[GetSpellInfo(55095)] = true,			-- Frost Fever (Deathknight)
	[GetSpellInfo(68044)] = true,			-- Judgements of the Just (Paladin (Protection))
	[GetSpellInfo(51693)] = true, 			-- Waylay (Rogue (Subtlety))
	[GetSpellInfo(8042)] = true,				-- Earth Shock (Shaman)
	[GetSpellInfo(90314)] = true, 		-- Tailspin (Hunter (Fox))
	[GetSpellInfo(50285)] = true,			-- Dust Cloud (Hunter (Tailstrider))
	-- 10% physical damage caused
	[GetSpellInfo(99)] = true,			-- Demoralizing Roar (Druid (Feral))
	[GetSpellInfo(1160)] = true,			-- Demoralizing Shout (Warrior (Protection))
	[GetSpellInfo(81130)] = true,			-- Scarlet Fever (Deathknight (Blood))
	[GetSpellInfo(26017)] = true, 		-- Vindication (Paladin (Protection))
	[GetSpellInfo(702)] = true, 			-- Curse of Weakness (Warlock)
	[GetSpellInfo(50256)] = true, 		-- Demoralizing Roar (Hunter (Bear))
	[GetSpellInfo(24423)] = true, 		-- Demoralizing Screech (Hunter (Carrion Bird))
	-- 10% reduced healing
	[GetSpellInfo(13218)] = true, 		-- Wound Poison (Rogue)
	[GetSpellInfo(12294)] = true, 		-- Mortal Strike (Warrior (Arms))
	[GetSpellInfo(56112)] = true, 		-- Furious Attacks (Warrior (Fury))
	[GetSpellInfo(82654)] = true, 		-- Widow Venom (Hunter (Beast Mastery))
	[GetSpellInfo(54680)] = true, 		-- Monstrous Bite (Hunter (Exotic Devlisaur))
	[GetSpellInfo(30213)] = true, 		-- Legion Strike (Warlock (Felguard))
	[GetSpellInfo(15273)] = true, 		-- Improved Mind Blast (Priest (Shadow))
	-- 30% reduced cast speed
	[GetSpellInfo(1714)] = true, 		-- Curse of Tongues (Warlock)
	[GetSpellInfo(5760)] = true, 		-- Mind-numbing Poison (Rogue)
	[GetSpellInfo(31589)] = true, 		-- Slow (Mage (Arcane))
	[GetSpellInfo(73975)] = true, 		-- Necrotic Strike (Death Knight (Unholy))
	[GetSpellInfo(58604)] = true, 		-- Lava Breath (Hunter (Core Hound)) 25%
	[GetSpellInfo(50274)] = true, 		-- Spore Cloud (Hunter (Sporebat))
}