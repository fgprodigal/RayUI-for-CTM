local R, C, DB = unpack(select(2, ...))

local addon, ns = ...

R.DebuffBlackList = {
	[GetSpellInfo(6562) or "英雄灵气"] = true,
	[GetSpellInfo(57940) or "冬拥湖的精华"] = true,
}

R.BuffWhiteList = {
	["DRUID"] = {
			-- Lifebloom / Blühendes Leben
			[GetSpellInfo(33763)] = true,
			-- Rejuvenation / Verjüngung
			[GetSpellInfo(774)] = true,
			-- Regrowth / Nachwachsen
			[GetSpellInfo(8936)] = true,
			-- Wild Growth / Wildwuchs
			[GetSpellInfo(48438)] = true,
		},
	["HUNTER"] = {
			-- Lock and Load / Sichern und Laden
			[GetSpellInfo(56342)] = true,
			-- Quick Shots / Schnelle Schüsse
			[GetSpellInfo(6150)] = true,
			-- Master Tactician / Meister der Taktik
			[GetSpellInfo(34837)] = true,
			-- Improved Steady Shot / Verbesserter zuverlässiger Schuss
			[GetSpellInfo(53224)] = true,
			-- Rapid Fire / Schnellfeuer
			[GetSpellInfo(3045)] = true,
			-- Mend Pet / Tier heilen
			-- { spellID = 136, size = 47, unitId = "pet", caster = "player", filter = "BUFF" },
			-- Feed Pet / Tier füttern
			-- { spellID = 6991, size = 47, unitId = "pet", caster = "player", filter = "BUFF" },
			-- Call of the Wild / Ruf der Wildnis
			[GetSpellInfo(53434)] = true,
		},
	["MAGE"] = {
			-- Frostbite / Frostbite
			--{ spellID = 11071, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Winter's Chill / Winterkälte
			-- { spellID = 28593, size = 47, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Fingers of Frost / Eisige Finger
			[GetSpellInfo(44544)] = true,
			-- Brain Freeze / Hirnfrost
			[GetSpellInfo(57761)] = true,
			-- Hot Streak / Kampfeshitze
			[GetSpellInfo(44445)] = true,
			-- Missile Barrage / Geschosssalve
			[GetSpellInfo(54486)] = true,
			-- Clearcasting / Freizaubern
			[GetSpellInfo(12536)] = true,
			-- Impact / Einschlag
			[GetSpellInfo(12358)] = true,
		},
	["WARRIOR"] = {
			-- Sudden Death / Plötzlicher Tod
			[GetSpellInfo(52437)] = true,
			-- Bloodsurge / Schäumendes Blut
			-- { spellID = 46916, size = 47, unitId = "player", caster = "all", filter = "BUFF" },
			-- Sword and Board / Schwert und Schild
			[GetSpellInfo(50227)] = true,
			-- Blood Reserve / Blutreserve
			[GetSpellInfo(64568)] = true,
			-- Spell Reflection / Zauberreflexion
			[GetSpellInfo(23920)] = true,
			-- Victory Rush / Siegesrausch
			[GetSpellInfo(34428)] = true,
			-- Shield Block / Schildblock
			[GetSpellInfo(2565)] = true,
			-- Last Stand / Letztes Gefecht
			[GetSpellInfo(12975)] = true,
			-- Shield Wall / Schildwall
			[GetSpellInfo(871)] = true,
		},
	["SHAMAN"] = {
			-- Earth Shield / Erdschild
			[GetSpellInfo(974)] = true,
			-- Riptide / Springflut
			[GetSpellInfo(61295)] = true,
			-- Lightning Shield / Blitzschlagschild
			[GetSpellInfo(324)] = true,
			-- Water Shield / Wasserschild
			[GetSpellInfo(52127)] = true,
		},
	["PALADIN"] = {
			-- Beacon of Light / Flamme des Glaubens
			[GetSpellInfo(53563)] = true,
		},
	["PRIEST"] = {
			-- Prayer of Mending / Gebet der Besserung
			[GetSpellInfo(41635)] = true,
			-- Guardian Spirit / Schutzgeist
			[GetSpellInfo(47788)] = true,
			-- Pain Suppression / Schmerzunterdrückung
			[GetSpellInfo(33206)] = true,
			-- Power Word: Shield / Machtwort: Schild
			[GetSpellInfo(17)] = true,
			-- Renew / Erneuerung
			[GetSpellInfo(139)] = true,
			-- Fade / Verblassen
			[GetSpellInfo(586)] = true,
			-- Fear Ward / Furchtzauberschutz
			[GetSpellInfo(6346)] = true,
			-- Inner Fire / Inneres Feuer
			[GetSpellInfo(588)] = true,
			-- Inner Will / Innerer Wille
			[GetSpellInfo(73413)] = true,
			-- Archangel / Erzengel
			[GetSpellInfo(81700)] = true,
			-- Dark Archangel / Dunkler Erzengel
			[GetSpellInfo(87153)] = true,
			-- Empowered Shadow / Machterfüllte Schatten
			[GetSpellInfo(95799)] = true,
		},
	["WARLOCK"] = {
			-- Devious Minds / Teuflische Absichten
			[GetSpellInfo(70840)] = true,
			-- Improved Soul Fire / Verbessertes Seelenfeuer
			[GetSpellInfo(85383)] = true,
			-- Molten Core / Geschmolzener Kern
			[GetSpellInfo(47383)] = true,
			-- Decimation / Dezimierung
			[GetSpellInfo(63165)] = true,
			-- Backdraft / Pyrolyse
			[GetSpellInfo(54274)] = true,
			-- Backlash / Heimzahlen
			[GetSpellInfo(34936)] = true,
			-- Nether Protection / Netherschutz
			[GetSpellInfo(30299)] = true,
			-- Nightfall / Einbruch der Nacht
			[GetSpellInfo(18094)] = true,
			-- Soulburn / Seelenbrand
			[GetSpellInfo(74434)] = true,
		},
	["ROGUE"] = {
			-- Sprint / Sprinten
			[GetSpellInfo(2983)] = true,
			-- Cloak of Shadows / Mantel der Schatten
			[GetSpellInfo(31224)] = true,
			-- Adrenaline Rush / Adrenalinrausch
			[GetSpellInfo(13750)] = true,
			-- Evasion / Entrinnen
			[GetSpellInfo(5277)] = true,
			-- Envenom / Vergiften
			[GetSpellInfo(32645)] = true,
			-- Overkill / Amok
			[GetSpellInfo(58426)] = true,
			-- Slice and Dice / Zerhäckseln
			[GetSpellInfo(5171)] = true,
			-- Tricks of the Trade / Schurkenhandel
			[GetSpellInfo(57934)] = true,
			-- Turn the Tables / Den Spieß umdrehen
			[GetSpellInfo(51627)] = true,
		},
	["DEATHKNIGHT"] = {
			-- Blood Shield / Blutschild
			[GetSpellInfo(77513)] = true,
			-- Unholy Force / Unheilige Kraft
			[GetSpellInfo(67383)] = true,
			-- Unholy Strength / Unheilige Stärke
			[GetSpellInfo(53365)] = true,
			-- Unholy Might / Unheilige Macht
			[GetSpellInfo(67117)] = true,
			-- Dancing Rune Weapon / Tanzende Runenwaffe
			[GetSpellInfo(49028)] = true,
			-- Icebound Fortitude / Eisige Gegenwehr
			[GetSpellInfo(48792)] = true,
			-- Anti-Magic Shell / Antimagische Hülle
			[GetSpellInfo(48707)] = true,
			-- Killing Machine / Tötungsmaschine
			[GetSpellInfo(51124)] = true,
			-- Freezing Fog / Gefrierender Nebel
			[GetSpellInfo(59052)] = true,
			-- Bone Shield / Knochenschild
			[GetSpellInfo(49222)] = true,
		},
}