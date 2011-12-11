-----------------------------------------------------------------------------------------------------
-- name = "目标debuff",
-- setpoint = { "BOTTOMLEFT", "RayUF_target", "TOPLEFT", 0, 33 },
-- direction = "UP",
-- iconSide = "LEFT",
-- mode = "BAR", 
-- size = 24,
-- barWidth = 170,				
--	{spellID = 8050, unitId = "target", caster = "target", filter = "DEBUFF"},
--	{ spellID = 18499, filter = "CD" },
--	{ itemID = 56285, filter = "itemCD" },
---------------------------------------------------------------------------------------------------
local R, C = unpack(RayUI)
local _, ns = ...

ns.font = C.media.font
ns.fontsize = 12
ns.fontflag = "OUTLINE"

ns.watchers ={
	["DRUID"] = {
		{
			name = "玩家buff",
			direction = "LEFT",
			setpoint = { "BOTTOMRIGHT", "RayUF_player", "TOPRIGHT", 0, 85 },
			size = 32,

			-- Lifebloom / Blühendes Leben
			{ spellID = 33763, unitId = "player", caster = "player", filter = "BUFF" },
			-- Rejuvenation / Verjüngung
			{ spellID = 774, unitId = "player", caster = "player", filter = "BUFF" },
			-- Regrowth / Nachwachsen
			{ spellID = 8936, unitId = "player", caster = "player", filter = "BUFF" },
			-- Wild Growth / Wildwuchs
			{ spellID = 48438, unitId = "player", caster = "player", filter = "BUFF" },
		},
		{
			name = "目标buff",
			direction = "RIGHT",
			setpoint = { "BOTTOMLEFT", "RayUF_target", "TOPLEFT", 0, 85 },
			size = 32,

			-- Lifebloom / Blühendes Leben
			{ spellID = 33763, unitId = "target", caster = "player", filter = "BUFF" },
			-- Rejuvenation / Verjüngung
			{ spellID = 774, unitId = "target", caster = "player", filter = "BUFF" },
			-- Regrowth / Nachwachsen
			{ spellID = 8936, unitId = "target", caster = "player", filter = "BUFF" },
			-- Wild Growth / Wildwuchs
			{ spellID = 48438, unitId = "target", caster = "player", filter = "BUFF" },

		},
		{
			name = "玩家重要buff",
			direction = "LEFT",
			setpoint = { "BOTTOMRIGHT", "RayUF_player", "TOPRIGHT", 0, 33 },
			size = 47,
			
			-- Eclipse (Lunar) / Mondfinsternis
			{ spellID = 48518, unitId = "player", caster = "player", filter = "BUFF" },
			-- Eclipse (Solar) / Sonnenfinsternis
			{ spellID = 48517, unitId = "player", caster = "player", filter = "BUFF" },
			-- Shooting Stars / Sternschnuppen
			{ spellID = 93400, unitId = "player", caster = "player", filter = "BUFF" },
			-- Savage Roar / Wildes Brüllen
			{ spellID = 52610, unitId = "player", caster = "player", filter = "BUFF" },
			-- Survival Instincts / Überlebensinstinkte
			{ spellID = 61336, unitId = "player", caster = "player", filter = "BUFF" },
			-- Tree of Life / Baum des Lebens
			{ spellID = 33891, unitId = "player", caster = "player", filter = "BUFF" },
			-- Clearcasting / Freizaubern
			{ spellID = 16870, unitId = "player", caster = "player", filter = "BUFF" },
			-- Innervate / Anregen
			{ spellID = 29166, unitId = "player", caster = "all", filter = "BUFF" },
			-- Barkskin / Baumrinde
			{ spellID = 22812, unitId = "player", caster = "player", filter = "BUFF" },

		},
		{
			name = "目标debuff",
			direction = "RIGHT",
			setpoint = { "BOTTOMLEFT", "RayUF_target", "TOPLEFT", 0, 33 },
			size = 47,
			
			-- Hibernate / Winterschlaf
			{ spellID = 2637, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Entangling Roots / Wucherwurzeln
			{ spellID = 339, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Cyclone / Wirbelsturm
			{ spellID = 33786, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Moonfire / Mondfeuer
			{ spellID = 8921, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Sunfire / Sonnenfeuer
			{ spellID = 93402, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Insect Swarm / Insektenschwarm
			{ spellID = 5570, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Rake / Krallenhieb
			{ spellID = 1822, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Rip / Zerfetzen
			{ spellID = 1079, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Lacerate / Aufschlitzen
			{ spellID = 33745, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Pounce Bleed / Anspringblutung
			{ spellID = 9007, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Mangle / Zerfleischen
			{ spellID = 33876, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Earth and Moon / Erde und Mond
			{ spellID = 48506, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Faerie Fire / Feenfeuer
			{ spellID = 770, unitId = "target", caster = "all", filter = "DEBUFF" },

		},
		{
			name = "焦点debuff",
			direction = "UP",
			setpoint = { "BOTTOMLEFT", "RayUF_focus", "TOPLEFT", 0, 10 },
			size = 32, 
			mode = "BAR",
			iconSide = "LEFT",
			barWidth = 170,
			
			-- Hibernate / Winterschlaf
			{ spellID = 2637, unitId = "focus", caster = "all", filter = "DEBUFF" },
			-- Entangling Roots / Wucherwurzeln
			{ spellID = 339, unitId = "focus", caster = "all", filter = "DEBUFF" },
			-- Cyclone / Wirbelsturm
			{ spellID = 33786, unitId = "focus", caster = "all", filter = "DEBUFF" },
		},
		{
			name = "CD",
			direction = "UP",
			iconSide = "LEFT",
			mode = "BAR",
			size = 32,
			barWidth = 170,
			setpoint = { "TOPLEFT", "rABS_MultiBarBottomLeft", "TOPRIGHT", 10, 0 },

			-- Swiftmend / Rasche Heilung
			{ spellID = 18562, filter = "CD" },
			-- Wild Growth / Wildwuchs
			{ spellID = 48438, filter = "CD" },
		},
	},
	["HUNTER"] = {
		{
			name = "玩家重要buff",
			direction = "LEFT",
			setpoint = { "BOTTOMRIGHT", "RayUF_player", "TOPRIGHT", 0, 33 },
			size = 47,
			
			-- Lock and Load / Sichern und Laden
			{ spellID = 56342, unitId = "player", caster = "player", filter = "BUFF" },
			-- Quick Shots / Schnelle Schüsse
			{ spellID = 6150, unitId = "player", caster = "player", filter = "BUFF" },
			-- Master Tactician / Meister der Taktik
			{ spellID = 34837, unitId = "player", caster = "player", filter = "BUFF" },
			-- Improved Steady Shot / Verbesserter zuverlässiger Schuss
			{ spellID = 53224, unitId = "player", caster = "player", filter = "BUFF" },
			-- Rapid Fire / Schnellfeuer
			{ spellID = 3045, unitId = "player", caster = "player", filter = "BUFF" },
			-- Mend Pet / Tier heilen
			{ spellID = 136, unitId = "pet", caster = "player", filter = "BUFF" },
			-- Feed Pet / Tier füttern
			{ spellID = 6991, unitId = "pet", caster = "player", filter = "BUFF" },
			-- Call of the Wild / Ruf der Wildnis
			{ spellID = 53434, unitId = "player", caster = "player", filter = "BUFF" },

		},
		{
			name = "目标debuff",
			direction = "RIGHT",
			setpoint = { "BOTTOMLEFT", "RayUF_target", "TOPLEFT", 0, 33 },
			size = 47,
			
			-- Wyvern Sting / Wyverngift
			{ spellID = 19386, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Silencing Shot / Unterdrückender Schuss
			{ spellID = 34490, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Serpent Sting / Schlangengift
			{ spellID = 1978, unitId = "target", caster = "player", filter = "DEBUFF" },
			{ spellID = 88453, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Widow Venom / Witwentoxin
			{ spellID = 82654, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Black Arrow / Schwarzer Pfeil
			{ spellID = 3674, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Explosive Shot / Explosivschuss
			{ spellID = 53301, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Hunter's Mark/ Mal des Jägers
			{ spellID = 1130, unitId = "target", caster = "all", filter = "DEBUFF" },

		},
		{
			name = "焦点debuff",
			direction = "UP",
			setpoint = { "BOTTOMLEFT", "RayUF_focus", "TOPLEFT", 0, 10 },
			size = 32, 
			mode = "BAR",
			iconSide = "LEFT",
			barWidth = 170,
			
			-- Wyvern Sting / Wyverngift
			{ spellID = 19386, unitId = "focus", caster = "all", filter = "DEBUFF" },
			-- Silencing Shot / Unterdrückender Schuss
			{ spellID = 34490, unitId = "focus", caster = "all", filter = "DEBUFF" },
		},
	},
	["MAGE"] = {
		{
			name = "玩家重要buff",
			direction = "LEFT",
			setpoint = { "BOTTOMRIGHT", "RayUF_player", "TOPRIGHT", 0, 33 },
			size = 47,
			
			-- Frostbite / Frostbite
			--{ spellID = 11071, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Winter's Chill / Winterkälte
			{ spellID = 28593, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Fingers of Frost / Eisige Finger
			{ spellID = 44544, unitId = "player", caster = "player", filter = "BUFF" },
			-- Brain Freeze / Hirnfrost
			{ spellID = 57761, unitId = "player", caster = "player", filter = "BUFF" },
			-- Hot Streak / Kampfeshitze
			{ spellID = 44445, unitId = "player", caster = "player", filter = "BUFF" },
			-- Missile Barrage / Geschosssalve
			{ spellID = 54486, unitId = "player", caster = "player", filter = "BUFF" },
			-- Clearcasting / Freizaubern
			{ spellID = 12536, unitId = "player", caster = "player", filter = "BUFF" },
			-- Impact / Einschlag
			{ spellID = 12358, unitId = "player", caster = "player", filter = "BUFF" },

		},
		{
			name = "目标debuff",
			direction = "RIGHT",
			setpoint = { "BOTTOMLEFT", "RayUF_target", "TOPLEFT", 0, 33 },
			size = 47,
			
			-- Polymorph / Verwandlung
			{ spellID = 118, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Arcane Blast / Arkanschlag
			{ spellID = 36032, unitId = "player", caster = "player", filter = "DEBUFF" },
			-- Improved Scorch / Verbessertes Versengen
			{ spellID = 11367, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Scorch / Versengen
			{ spellID = 2948, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Slow / Verlangsamen
			{ spellID = 31589, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Ignite / Entzünden
			{ spellID = 11119, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Living Bomb / Lebende Bombe
			{ spellID = 44457, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Pyroblast! / Pyroschlag!
			{ spellID = 92315, unitId = "player", caster = "player", filter = "DEBUFF" },

		},
		{
			name = "焦点debuff",
			direction = "UP",
			setpoint = { "BOTTOMLEFT", "RayUF_focus", "TOPLEFT", 0, 10 },
			size = 32, 
			mode = "BAR",
			iconSide = "LEFT",
			barWidth = 170,
			
			-- Polymorph / Verwandlung
			{ spellID = 118, unitId = "focus", caster = "all", filter = "DEBUFF" },
		},
	},
	["WARRIOR"] = {
		{
			name = "玩家重要buff",
			direction = "LEFT",
			setpoint = { "BOTTOMRIGHT", "RayUF_player", "TOPRIGHT", 0, 33 },
			size = 47,
			
			-- Sudden Death / Plötzlicher Tod
			{ spellID = 52437, unitId = "player", caster = "player", filter = "BUFF" },
			-- Bloodsurge / Schäumendes Blut
			{ spellID = 46916, unitId = "player", caster = "all", filter = "BUFF" },
			-- Sword and Board / Schwert und Schild
			{ spellID = 50227, unitId = "player", caster = "player", filter = "BUFF" },
			-- Blood Reserve / Blutreserve
			{ spellID = 64568, unitId = "player", caster = "player", filter = "BUFF" },
			-- Spell Reflection / Zauberreflexion
			{ spellID = 23920, unitId = "player", caster = "player", filter = "BUFF" },
			-- Victory Rush / Siegesrausch
			{ spellID = 34428, unitId = "player", caster = "player", filter = "BUFF" },
			-- Shield Block / Schildblock
			{ spellID = 2565, unitId = "player", caster = "player", filter = "BUFF" },
			-- Last Stand / Letztes Gefecht
			{ spellID = 12975, unitId = "player", caster = "player", filter = "BUFF" },
			-- Shield Wall / Schildwall
			{ spellID = 871, unitId = "player", caster = "player", filter = "BUFF" },

		},
		{
			name = "目标debuff",
			direction = "RIGHT",
			setpoint = { "BOTTOMLEFT", "RayUF_target", "TOPLEFT", 0, 33 },
			size = 47,
			
			-- Charge Stun / Sturmangriffsbetäubung
			{ spellID = 7922, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Shockwave / Schockwelle
			{ spellID = 46968, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Hamstring / Kniesehne
			{ spellID = 1715, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Rend / Verwunden
			{ spellID = 94009, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Sunder Armor /Rüstung zerreiße
			{ spellID = 7386, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Thunder Clap / Donnerknall
			{ spellID = 6343, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Demoralizing Shout / Demoralisierender Ruf
			{ spellID = 1160, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Expose Armor / Rüstung schwächen (Rogue)
			{ spellID = 8647, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Infected Wounds / Infizierte Wunden (Druid)
			{ spellID = 48484, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Frost Fever / Frostfieber (Death Knight)
			{ spellID = 55095, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Demoralizing Roar / Demoralisierendes Gebrüll (Druid)
			{ spellID = 99, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Curse of Weakness / Fluch der Schwäche (Warlock)
			{ spellID = 702, unitId = "target", caster = "all", filter = "DEBUFF" },

		},
	},
	["SHAMAN"] = {
		{
			name = "玩家buff",
			direction = "LEFT",
			setpoint = { "BOTTOMRIGHT", "RayUF_player", "TOPRIGHT", 0, 85 },
			size = 32,
			
			-- Earth Shield / Erdschild
			{ spellID = 974, unitId = "player", caster = "player", filter = "BUFF" },
			-- Riptide / Springflut
			{ spellID = 61295, unitId = "player", caster = "player", filter = "BUFF" },
			-- Lightning Shield / Blitzschlagschild
			{ spellID = 324, unitId = "player", caster = "player", filter = "BUFF" },
			-- Water Shield / Wasserschild
			{ spellID = 52127, unitId = "player", caster = "player", filter = "BUFF" },

		},
		{
			name = "目标buff",
			direction = "RIGHT",
			setpoint = { "BOTTOMLEFT", "RayUF_target", "TOPLEFT", 0, 85 },
			size = 32,
			
			-- Earth Shield / Erdschild
			{ spellID = 974, unitId = "target", caster = "player", filter = "BUFF" },
			-- Riptide / Springflut
			{ spellID = 61295, unitId = "target", caster = "player", filter = "BUFF" },

		},
		{
			name = "玩家重要buff",
			direction = "LEFT",
			setpoint = { "BOTTOMRIGHT", "RayUF_player", "TOPRIGHT", 0, 33 },
			size = 47,
			
			-- Maelstorm Weapon / Waffe des Mahlstroms
			{ spellID = 53817, unitId = "player", caster = "player", filter = "BUFF" },
			-- Shamanistic Rage / Schamanistische Wut
			{ spellID = 30823, unitId = "player", caster = "player", filter = "BUFF" },
			-- Clearcasting / Freizaubern
			{ spellID = 16246, unitId = "player", caster = "player", filter = "BUFF" },
			-- Tidal Waves / Flutwellen
			{ spellID = 51562, unitId = "player", caster = "player", filter = "BUFF" },
			-- Ancestral Fortitude / Seelenstärke der Ahnen
			{ spellID = 16177, unitId = "target", caster = "player", filter = "BUFF" },

		},
		{
			name = "目标debuff",
			direction = "RIGHT",
			setpoint = { "BOTTOMLEFT", "RayUF_target", "TOPLEFT", 0, 33 },
			size = 47,
			
			-- Hex / Verhexen
			{ spellID = 51514, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Bind Elemental / Elementar binden
			{ spellID = 76780, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Storm Strike / Sturmschlag
			{ spellID = 17364, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Earth Shock / Erdschock
			{ spellID = 8042, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Frost Shock / Frostschock
			{ spellID = 8056, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Flame Shock / Flammenschock
			{ spellID = 8050, unitId = "target", caster = "player", filter = "DEBUFF" },

		},
		{
			name = "焦点debuff",
			direction = "UP",
			setpoint = { "BOTTOMLEFT", "RayUF_focus", "TOPLEFT", 0, 10 },
			size = 32, 
			mode = "BAR",
			iconSide = "LEFT",
			barWidth = 170,
			
			-- Hex / Verhexen
			{ spellID = 51514, unitId = "focus", caster = "all", filter = "DEBUFF" },
			-- Bind Elemental / Elementar binden
			{ spellID = 76780, unitId = "focus", caster = "all", filter = "DEBUFF" },

		},
	},
	["PALADIN"] = {
		{
			name = "玩家buff",
			direction = "LEFT",
			setpoint = { "BOTTOMRIGHT", "RayUF_player", "TOPRIGHT", 0, 85 },
			size = 32,
			
			-- Beacon of Light / Flamme des Glaubens
			{ spellID = 53563, unitId = "player", caster = "player", filter = "BUFF" },

		},
		{
			name = "目标buff",
			direction = "RIGHT",
			setpoint = { "BOTTOMLEFT", "RayUF_target", "TOPLEFT", 0, 85 },
			size = 32,
			
			-- Beacon of Light / Flamme des Glaubens
			{ spellID = 53563, unitId = "target", caster = "player", filter = "BUFF" },

		},
		{
			name = "玩家重要buff",
			direction = "LEFT",
			setpoint = { "BOTTOMRIGHT", "RayUF_player", "TOPRIGHT", 0, 33 },
			size = 47,
			
			-- Judgements of the Pure / Richturteile des Reinen
			{ spellID = 53671, unitId = "player", caster = "player", filter = "BUFF" },
			-- Judgements of the Just / Richturteil des Gerechten
			{ spellID = 68055, unitId = "player", caster = "player", filter = "BUFF" },
			-- Holy Shield / Heiliger Schild
			{ spellID = 20925, unitId = "player", caster = "player", filter = "BUFF" },
			-- Infusion of Light / Lichtenergie
			{ spellID = 53672, unitId = "player", caster = "player", filter = "BUFF" },
			-- Divine Plea / Göttliche Bitte
			{ spellID = 54428, unitId = "player", caster = "player", filter = "BUFF" },
			-- Essence of Life / Essenz des Lebens
			{ spellID = 60062, unitId = "player", caster = "player", filter = "BUFF" },
			-- Divine Illumination / Göttliche Gunst
			{ spellID = 31842, unitId = "player", caster = "player", filter = "BUFF" },
			-- 異端審問
			{ spellID = 84963, unitId = "player", caster = "player", filter = "BUFF" },
			-- 狂熱精神
			{ spellID = 85696, unitId = "player", caster = "player", filter = "BUFF" },

		},
		{
			name = "目标debuff",
			direction = "RIGHT",
			setpoint = { "BOTTOMLEFT", "RayUF_target", "TOPLEFT", 0, 33 },
			size = 47,
			
			-- Hammer of Justice / Hammer der Gerechtigkeit
			{ spellID = 853, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Judgement / Richturteil
			{ spellID = 20271, unitId = "target", caster = "player", filter = "DEBUFF" },

		},
		{
			name = "焦点debuff",
			direction = "UP",
			setpoint = { "BOTTOMLEFT", "RayUF_focus", "TOPLEFT", 0, 10 },
			size = 32, 
			mode = "BAR",
			iconSide = "LEFT",
			barWidth = 170,
			
			-- Hammer of Justice / Hammer der Gerechtigkeit
			{ spellID = 853, unitId = "focus", caster = "all", filter = "DEBUFF" },

		},
	},
	["PRIEST"] = {
		{
			name = "玩家buff",
			direction = "LEFT",
			setpoint = { "BOTTOMRIGHT", "RayUF_player", "TOPRIGHT", 0, 85 },
			size = 32,
			
			-- Prayer of Mending / Gebet der Besserung
			{ spellID = 41635, unitId = "player", caster = "player", filter = "BUFF" },
			-- Guardian Spirit / Schutzgeist
			{ spellID = 47788, unitId = "player", caster = "player", filter = "BUFF" },
			-- Pain Suppression / Schmerzunterdrückung
			{ spellID = 33206, unitId = "player", caster = "player", filter = "BUFF" },
			-- Power Word: Shield / Machtwort: Schild
			{ spellID = 17, unitId = "player", caster = "player", filter = "BUFF" },
			-- Renew / Erneuerung
			{ spellID = 139, unitId = "player", caster = "player", filter = "BUFF" },
			-- Fade / Verblassen
			{ spellID = 586, unitId = "player", caster = "player", filter = "BUFF" },
			-- Fear Ward / Furchtzauberschutz
			{ spellID = 6346, unitId = "player", caster = "player", filter = "BUFF" },
			-- Inner Will / Innerer Wille
			{ spellID = 73413, unitId = "player", caster = "player", filter = "BUFF" },
			-- Archangel / Erzengel
			{ spellID = 81700, unitId = "player", caster = "player", filter = "BUFF" },
			-- Dark Archangel / Dunkler Erzengel
			{ spellID = 87153, unitId = "player", caster = "player", filter = "BUFF" },
			-- Empowered Shadow / Machterfüllte Schatten
			{ spellID = 95799, unitId = "player", caster = "player", filter = "BUFF" },

		},
		{
			name = "目标buff",
			direction = "RIGHT",
			setpoint = { "BOTTOMLEFT", "RayUF_target", "TOPLEFT", 0, 85 },
			size = 32,
			
			-- Prayer of Mending / Gebet der Besserung
			{ spellID = 41635, unitId = "target", caster = "player", filter = "BUFF" },
			-- Guardian Spirit / Schutzgeist
			{ spellID = 47788, unitId = "target", caster = "player", filter = "BUFF" },
			-- Pain Suppression / Schmerzunterdrückung
			{ spellID = 33206, unitId = "target", caster = "player", filter = "BUFF" },
			-- Power Word: Shield / Machtwort: Schild
			{ spellID = 17, unitId = "target", caster = "player", filter = "BUFF" },
			-- Renew / Erneuerung
			{ spellID = 139, unitId = "target", caster = "player", filter = "BUFF" },
			-- Fear Ward / Furchtzauberschutz
			{ spellID = 6346, unitId = "target", caster = "player", filter = "BUFF" },
			-- Echo of Light / Echo des Lichts
			{ spellID = 77489, unitId = "target", caster = "player", filter = "BUFF" },
			-- Inspiration / Inspiration
			{ spellID = 15357, unitId = "target", caster = "player", filter = "BUFF" },
			-- Grace / Barmherzigkeit
			{ spellID = 77613, unitId = "target", caster = "player", filter = "BUFF" },

		},
		{
			name = "玩家重要buff",
			direction = "LEFT",
			setpoint = { "BOTTOMRIGHT", "RayUF_player", "TOPRIGHT", 0, 33 },
			size = 47,
			
			-- Surge of Light / Woge des Lichts
			{ spellID = 88688, unitId = "player", caster = "all", filter = "BUFF" },
			-- Serendipity / Glücksfall
			{ spellID = 63735, unitId = "player", caster = "player", filter = "BUFF" },
			-- Shadow Orb / Schattenkugeln
			{ spellID = 77487, unitId = "player", caster = "player", filter = "BUFF" },
			-- Evangelism / Prediger
			{ spellID = 81661, unitId = "player", caster = "player", filter = "BUFF" },
			-- Dark Evangelism / Dunkler Prediger
			{ spellID = 87118, unitId = "player", caster = "player", filter = "BUFF" },
			-- Dispersion / Dispersion
			{ spellID = 47585, unitId = "player", caster = "player", filter = "BUFF" },
			-- Chakra: Serenity / Chakra: Epiphanie
			{ spellID = 81208, unitId = "player", caster = "player", filter = "BUFF" },
			-- Chakra: Sanctuary / Chakra: Refugium
			{ spellID = 81206, unitId = "player", caster = "player", filter = "BUFF" },
			-- Chakra: Chastise / Chakra: Züchtigung
			{ spellID = 81209, unitId = "player", caster = "player", filter = "BUFF" },

		},
		{
			name = "目标debuff",
			direction = "RIGHT",
			setpoint = { "BOTTOMLEFT", "RayUF_target", "TOPLEFT", 0, 33 },
			size = 47,
			
			-- Shackle Undead / Untote fesseln
			{ spellID = 9484, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Psychic Scream / Psychischer Schrei
			{ spellID = 8122, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Shadow Word: Pain / Schattenwort: Schmerz
			{ spellID = 589, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Devouring Plague / Verschlingende Seuche
			{ spellID = 2944, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Vampiric Touch / Vampirberührung
			{ spellID = 34914, unitId = "target", caster = "player", filter = "DEBUFF" },

		},
		{
			name = "焦点debuff",
			direction = "UP",
			setpoint = { "BOTTOMLEFT", "RayUF_focus", "TOPLEFT", 0, 10 },
			size = 32, 
			mode = "BAR",
			iconSide = "LEFT",
			barWidth = 170,
			
			-- Shackle Undead / Untote fesseln
			{ spellID = 9484, unitId = "focus", caster = "all", filter = "DEBUFF" },
			-- Psychic Scream / Psychischer Schrei
			{ spellID = 8122, unitId = "focus", caster = "all", filter = "DEBUFF" },

		},
	},
	["WARLOCK"]={
		{
			name = "目标debuff",
			setpoint = { "BOTTOMLEFT", "RayUF_target", "TOPLEFT", 0, 33 },
			direction = "RIGHT",
			mode = "ICON",
			size = 47,
	
			{spellID = 8050, unitId = "target", caster = "target", filter = "DEBUFF"},
			-- Fear / Furcht
			{ spellID = 5782, unitId = "target", caster = "target", filter = "DEBUFF" },
			-- Banish / Verbannen
			{ spellID = 710, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Curse of the Elements / Fluch der Elemente
			{ spellID = 1490, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Curse of Tongues / Fluch der Sprachen
			{ spellID = 1714, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Curse of Exhaustion / Fluch der Erschöpfung
			{ spellID = 18223, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Curse of Weakness / Fluch der Schwäche
			{ spellID = 702, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Corruption / Verderbnis
			{ spellID = 172, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Immolate / Feuerbrand
			{ spellID = 348, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Curse of Agony / Omen der Pein
			{ spellID = 980, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Bane of Doom / Omen der Verdammnis
			{ spellID = 603, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Unstable Affliction / Instabiles Gebrechen
			{ spellID = 30108, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Haunt / Heimsuchung
			{ spellID = 48181, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Seed of Corruption / Saat der Verderbnis
			{ spellID = 27243, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Howl of Terror / Schreckensgeheul
			{ spellID = 5484, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Death Coil / Todesmantel
			{ spellID = 6789, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Enslave Demon / Dämonensklave
			{ spellID = 1098, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Demon Charge / Dämonischer Ansturm
			{ spellID = 54785, unitId = "target", caster = "player", filter = "DEBUFF" },
		},
		{
			name = "玩家重要buff",
			setpoint = { "BOTTOMRIGHT", "RayUF_player", "TOPRIGHT", 0, 33 },
			direction = "LEFT",
			size = 47,
			-- Improved Soul Fire / Verbessertes Seelenfeuer
			{ spellID = 85383, unitId = "player", caster = "player", filter = "BUFF" },
			-- Molten Core / Geschmolzener Kern
			{ spellID = 47383, unitId = "player", caster = "player", filter = "BUFF" },
			-- Decimation / Dezimierung
			{ spellID = 63165, unitId = "player", caster = "player", filter = "BUFF" },
			-- Backdraft / Pyrolyse
			{ spellID = 54274, unitId = "player", caster = "player", filter = "BUFF" },
			-- Backlash / Heimzahlen
			{ spellID = 34936, unitId = "player", caster = "player", filter = "BUFF" },
			-- Nether Protection / Netherschutz
			{ spellID = 30299, unitId = "player", caster = "player", filter = "BUFF" },
			-- Nightfall / Einbruch der Nacht
			{ spellID = 18094, unitId = "player", caster = "player", filter = "BUFF" },
			-- Soulburn / Seelenbrand
			{ spellID = 74434, unitId = "player", caster = "player", filter = "BUFF" },
		},
	},
	["ROGUE"] = {
		{
			name = "玩家重要buff",
			direction = "LEFT",
			setpoint = { "BOTTOMRIGHT", "RayUF_player", "TOPRIGHT", 0, 33 },
			size = 47,
			
			-- Sprint / Sprinten
			{ spellID = 2983, unitId = "player", caster = "player", filter = "BUFF" },
			-- Cloak of Shadows / Mantel der Schatten
			{ spellID = 31224, unitId = "player", caster = "player", filter = "BUFF" },
			-- Adrenaline Rush / Adrenalinrausch
			{ spellID = 13750, unitId = "player", caster = "player", filter = "BUFF" },
			-- Evasion / Entrinnen
			{ spellID = 5277, unitId = "player", caster = "player", filter = "BUFF" },
			-- Envenom / Vergiften
			{ spellID = 32645, unitId = "player", caster = "player", filter = "BUFF" },
			-- Overkill / Amok
			{ spellID = 58426, unitId = "player", caster = "player", filter = "BUFF" },
			-- Slice and Dice / Zerhäckseln
			{ spellID = 5171, unitId = "player", caster = "player", filter = "BUFF" },
			-- Tricks of the Trade / Schurkenhandel
			{ spellID = 57934, unitId = "player", caster = "player", filter = "BUFF" },
			-- Turn the Tables / Den Spieß umdrehen
			{ spellID = 51627, unitId = "player", caster = "player", filter = "BUFF" },
			--养精蓄锐
			{ spellID = 73651, unitId = "player", caster = "player", filter = "BUFF" },
			--剑刃乱舞
			{ spellID = 13877, unitId = "player", caster = "player", filter = "BUFF" },
			--淺察
			{ spellID = 84745, unitId = "player", caster = "player", filter = "BUFF" },
			--中度洞察
			{ spellID = 84746, unitId = "player", caster = "player", filter = "BUFF" },
			--深度洞察
			{ spellID = 84747, unitId = "player", caster = "player", filter = "BUFF" },

		},
		{
			name = "目标debuff",
			direction = "RIGHT",
			setpoint = { "BOTTOMLEFT", "RayUF_target", "TOPLEFT", 0, 33 },
			size = 47,
			
			-- Cheap Shot / Fieser Trick
			{ spellID = 1833, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Kidney Shot / Nierenhieb
			{ spellID = 408, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Blind / Blenden
			{ spellID = 2094, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Sap / Kopfnuss
			{ spellID = 6770, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Rupture / Blutung
			{ spellID = 1943, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Garrote / Erdrosseln
			{ spellID = 703, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Gouge / Solarplexus
			{ spellID = 1776, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Expose Armor / Rüstung schwächen
			{ spellID = 8647, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Dismantle / Zerlegen
			{ spellID = 51722, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Deadly Poison / Tödliches Gift
			{ spellID = 2818, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Mind-numbing Poison / Gedankenbenebelndes Gift
			{ spellID = 5760, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Crippling Poison / Verkrüppelndes Gift
			{ spellID = 3409, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Wound Poison / Wundgift
			{ spellID = 13218, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- 出血
			{ spellID = 16511, unitId = "target", caster = "player", filter = "DEBUFF" },

		},
		{
			name = "焦点debuff",
			direction = "UP",
			setpoint = { "BOTTOMLEFT", "RayUF_focus", "TOPLEFT", 0, 10 },
			size = 32, 
			mode = "BAR",
			iconSide = "LEFT",
			barWidth = 170,
			
			-- Blind / Blenden
			{ spellID = 2094, unitId = "focus", caster = "all", filter = "DEBUFF" },
			-- Sap / Kopfnuss
			{ spellID = 6770, unitId = "focus", caster = "all", filter = "DEBUFF" },

		},
		{
			name = "CD",
			direction = "DOWN",
			iconSide = "LEFT",
			mode = "BAR",
			size = 32,
			barWidth = 200,
			setpoint = { "BOTTOM", UIParent, "BOTTOM", -100, 190 },

			--暗影步
			{ spellID = 36554, filter = "CD" },
			--预备
			{ spellID = 14185, filter = "CD" },
			--疾跑
			{ spellID = 2983, filter = "CD" },
			--斗篷
			{ spellID = 31224, filter = "CD" },
			--闪避
			{ spellID = 5277, filter = "CD" },
			--拆卸
			{ spellID = 51722, filter = "CD" },
			--影舞
			{ spellID = 51713, filter = "CD" },
			--致盲
			{ spellID = 2094, filter = "CD" },
			--战斗就绪
			{ spellID = 74001, filter = "CD" },
			--烟雾弹
			{ spellID = 76577, filter = "CD" },
			--消失
			{ spellID = 1856, filter = "CD" },
			--转攻
			{ spellID = 73981, filter = "CD" },
			--宿怨
			{ itemID = 79140, filter = "CD" },
			--冷血
			{ itemID = 14177, filter = "CD" },
			--狂舞杀戮
			{ itemID = 51690, filter = "CD" },
			--能量刺激
			{ itemID = 13750, filter = "CD" },
		},
	},
	["DEATHKNIGHT"] = {
		{
			name = "玩家重要buff",
			direction = "LEFT",
			setpoint = { "BOTTOMRIGHT", "RayUF_player", "TOPRIGHT", 0, 33 },
			size = 47,
			
			-- Blood Shield / Blutschild
			{ spellID = 77513, unitId = "player", caster = "player", filter = "BUFF" },
			-- Unholy Force / Unheilige Kraft
			{ spellID = 67383, unitId = "player", caster = "player", filter = "BUFF" },
			-- Unholy Strength / Unheilige Stärke
			{ spellID = 53365, unitId = "player", caster = "player", filter = "BUFF" },
			-- Unholy Might / Unheilige Macht
			{ spellID = 67117, unitId = "player", caster = "player", filter = "BUFF" },
			-- Dancing Rune Weapon / Tanzende Runenwaffe
			{ spellID = 49028, unitId = "player", caster = "player", filter = "BUFF" },
			-- Icebound Fortitude / Eisige Gegenwehr
			{ spellID = 48792, unitId = "player", caster = "player", filter = "BUFF" },
			-- Anti-Magic Shell / Antimagische Hülle
			{ spellID = 48707, unitId = "player", caster = "player", filter = "BUFF" },
			-- Killing Machine / Tötungsmaschine
			{ spellID = 51124, unitId = "player", caster = "player", filter = "BUFF" },
			-- Freezing Fog / Gefrierender Nebel
			{ spellID = 59052, unitId = "player", caster = "player", filter = "BUFF" },
			-- Bone Shield / Knochenschild
			{ spellID = 49222, unitId = "player", caster = "player", filter = "BUFF" },

		},
		{
			name = "目标debuff",
			direction = "RIGHT",
			setpoint = { "BOTTOMLEFT", "RayUF_target", "TOPLEFT", 0, 33 },
			size = 47,
			
			-- Strangulate / Strangulieren
			{ spellID = 47476, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Blood Plague / Blutseuche
			{ spellID = 59879, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Frost Fever / Frostfieber
			{ spellID = 59921, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Unholy Blight / Unheilige Verseuchung
			{ spellID = 49194, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Summon Gargoyle / Gargoyle beschwören
			{ spellID = 49206, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Death and Decay / Tod und Verfall
			{ spellID = 43265, unitId = "target", caster = "player", filter = "DEBUFF" },

		},
	},
	["ALL"]={
		{
			name = "玩家特殊buff",
			direction = "LEFT",
			setpoint = { "TOPRIGHT", "RayUF_player", "BOTTOMRIGHT", 0, -10 },
			size = 55,

		-- Trinket Procs
			-- Cleansing Tears / Läuternde Tränen (Tear of Blood)
			
			{ spellID = 91139, unitId = "player", caster = "player", filter = "BUFF" },
			-- Fury of the Five Flights / Furor der fünf Schwärme
			{ spellID = 60314, unitId = "player", caster = "player", filter = "BUFF" },
			-- Witching Hour / Geisterstunde 
			{ spellID = 90887, unitId = "player", caster = "player", filter = "BUFF" },
			-- Heart's Revelation / Erkenntnis des Herzens
			{ spellID = 91027, unitId = "player", caster = "player", filter = "BUFF" },
			-- Heart's Judgement / Richturteil des Herzens
			{ spellID = 91041, unitId = "player", caster = "player", filter = "BUFF" },

		-- Item Enchants - Engineering
			-- Hyperspeed Accelerators / Hypergeschwindigkeitsbeschleuniger
			{ spellID = 54758, unitId = "player", caster = "player", filter = "BUFF" },
			-- Synapse Springs / Synapsenfedern
			{ spellID = 82175, unitId = "player", caster = "player", filter = "BUFF" },

		-- Item Enchants - Tailoring
			-- Darkglow / Dunkles Glühen
			{ spellID = 55767, unitId = "player", caster = "player", filter = "BUFF" },
			-- Lightweave / Leuchtgarn
			{ spellID = 55637, unitId = "player", caster = "player", filter = "BUFF" },
			-- Swordguard / Schwertwallgarn
			{ spellID = 55775, unitId = "player", caster = "player", filter = "BUFF" },

		-- Item Enchants - Enchanting
			-- Heartsong / Gesang des Herzens
			{ spellID = 74224, unitId = "player", caster = "player", filter = "BUFF" },
			-- Avalanche / Lawine
			{ spellID = 74196, unitId = "player", caster = "player", filter = "BUFF" },
			-- Hurricane / Hurrikan
			{ spellID = 74221, unitId = "player", caster = "player", filter = "BUFF" },

		-- Potions
			-- Speed / Geschwindigkeit - Potion of Speed
			{ spellID = 53908, unitId = "player", caster = "player", filter = "BUFF" },
			-- Wild Magic / Wilde Magie - Potion of Wild Magic
			{ spellID = 53909, unitId = "player", caster = "player", filter = "BUFF" },
			-- Earthen Armor / Irdene Rüstung - Earthen Potion
			{ spellID = 79475, unitId = "player", caster = "player", filter = "BUFF" },

		-- External Buffs
			-- Tricks of the Trade / Schurkenhandel
			{ spellID = 57934, unitId = "player", caster = "all", filter = "BUFF" },
			-- Power Infusion / Seele der Macht
			{ spellID = 10060, unitId = "player", caster = "all", filter = "BUFF" },
			-- Bloodlust / Kampfrausch
			{ spellID = 2825, unitId = "player", caster = "all", filter = "BUFF" },
			-- Heroism / Heldentum
			{ spellID = 32182, unitId = "player", caster = "all", filter = "BUFF" },
			-- Time Warp / Zeitkrümmung
			{ spellID = 80353, unitId = "player", caster = "all", filter = "BUFF" },
			-- Ancient Hysteria / Uralte Hysterie (Core Hound)
			{ spellID = 90355, unitId = "player", caster = "all", filter = "BUFF" },

		},
		{
			name = "PVE/PVP玩家debuff",
			direction = "UP",
			setpoint = { "BOTTOM", UIParent, "BOTTOM", -35, 350 },
			size = 55,
			
		
			
		-- Death Knight
			-- Gnaw (Ghoul)
			{ spellID = 47481, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Strangulate
			{ spellID = 47476, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Chains of Ice
			{ spellID = 45524, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Desecration (no duration, lasts as long as you stand in it)
			{ spellID = 55741, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Glyph of Heart Strike
			{ spellID = 58617, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Icy Clutch (Chilblains)
			--{ spellID = 50436, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Hungering Cold
			{ spellID = 49203, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Druid
			-- Cyclone
			{ spellID = 33786, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Hibernate
			{ spellID = 2637, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Bash
			{ spellID = 5211, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Maim
			{ spellID = 22570, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Pounce
			{ spellID = 9005, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Entangling Roots
			{ spellID = 339, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Feral Charge Effect
			{ spellID = 45334, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Infected Wounds
			{ spellID = 58179, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Hunter
			-- Freezing Trap Effect
			{ spellID = 3355, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Freezing Arrow Effect
			--{ spellID = 60210, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Scare Beast
			{ spellID = 1513, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Scatter Shot
			{ spellID = 19503, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Chimera Shot - Scorpid
			--{ spellID = 53359, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Snatch (Bird of Prey)
			{ spellID = 50541, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Silencing Shot
			{ spellID = 34490, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Intimidation
			{ spellID = 24394, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Sonic Blast (Bat)
			{ spellID = 50519, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Ravage (Ravager)
			{ spellID = 50518, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Concussive Barrage
			{ spellID = 35101, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Concussive Shot
			{ spellID = 5116, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Frost Trap Aura
			{ spellID = 13810, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Glyph of Freezing Trap
			{ spellID = 61394, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Wing Clip
			{ spellID = 2974, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Counterattack
			{ spellID = 19306, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Entrapment
			{ spellID = 19185, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Pin (Crab)
			{ spellID = 50245, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Venom Web Spray (Silithid)
			{ spellID = 54706, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Web (Spider)
			{ spellID = 4167, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Froststorm Breath (Chimera)
			{ spellID = 92380, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Tendon Rip (Hyena)
			{ spellID = 50271, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Mage
			-- Dragon's Breath
			{ spellID = 31661, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Polymorph
			{ spellID = 118, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Silenced - Improved Counterspell
			{ spellID = 18469, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Deep Freeze
			{ spellID = 44572, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Freeze (Water Elemental)
			{ spellID = 33395, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Frost Nova
			{ spellID = 122, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Shattered Barrier
			{ spellID = 55080, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Chilled
			{ spellID = 6136, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Cone of Cold
			{ spellID = 120, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Slow
			{ spellID = 31589, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Paladin
			-- Repentance
			{ spellID = 20066, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Turn Evil
			{ spellID = 10326, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Shield of the Templar
			{ spellID = 63529, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Hammer of Justice
			{ spellID = 853, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Holy Wrath
			{ spellID = 2812, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Stun (Seal of Justice proc)
			{ spellID = 20170, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Avenger's Shield
			{ spellID = 31935, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Priest
			-- Psychic Horror
			{ spellID = 64058, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Mind Control
			{ spellID = 605, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Psychic Horror
			{ spellID = 64044, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Psychic Scream
			{ spellID = 8122, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Silence
			{ spellID = 15487, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Mind Flay
			{ spellID = 15407, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Rogue
			-- Dismantle
			{ spellID = 51722, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Blind
			{ spellID = 2094, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Gouge
			{ spellID = 1776, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Sap
			{ spellID = 6770, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Garrote - Silence
			{ spellID = 1330, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Silenced - Improved Kick
			{ spellID = 18425, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Cheap Shot
			{ spellID = 1833, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Kidney Shot
			{ spellID = 408, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Blade Twisting
			{ spellID = 31125, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Crippling Poison
			{ spellID = 3409, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Deadly Throw
			{ spellID = 26679, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Shaman
			-- Hex
			{ spellID = 51514, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Earthgrab
			{ spellID = 64695, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Freeze
			{ spellID = 63685, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Stoneclaw Stun
			{ spellID = 39796, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Earthbind
			{ spellID = 3600, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Frost Shock
			{ spellID = 8056, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Warlock
			-- Banish
			{ spellID = 710, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Death Coil
			{ spellID = 6789, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Fear
			{ spellID = 5782, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Howl of Terror
			{ spellID = 5484, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Seduction (Succubus)
			{ spellID = 6358, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Spell Lock (Felhunter)
			{ spellID = 24259, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Shadowfury
			{ spellID = 30283, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Intercept (Felguard)
			{ spellID = 30153, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Aftermath
			{ spellID = 18118, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Curse of Exhaustion
			{ spellID = 18223, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Warrior
			-- Intimidating Shout
			{ spellID = 20511, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Disarm
			{ spellID = 676, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Silenced (Gag Order)
			{ spellID = 18498, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Charge Stun
			{ spellID = 7922, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Concussion Blow
			{ spellID = 12809, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Intercept
			{ spellID = 20253, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Revenge Stun
			--{ spellID = 12798, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Shockwave
			{ spellID = 46968, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Glyph of Hamstring
			{ spellID = 58373, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Improved Hamstring
			{ spellID = 23694, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Hamstring
			{ spellID = 1715, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Piercing Howl
			{ spellID = 12323, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Racials
			-- War Stomp
			{ spellID = 20549, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Baradin Hold(PvP)
			-- Meteor Slash / Meteorschlag (Argaloth)
			{ spellID = 88942, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Bastion of Twilight
			-- Blackout / Blackout (Valiona & Theralion)
			{ spellID = 92879, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Engulfing Magic / Einhüllende Magie (Valiona & Theralion)
			{ spellID = 86631, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Twilight Meteorite / Zwielichtmeteorit (Valiona & Theralion)
			{ spellID = 86013, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Malevolent Strikes / Bösartige Stöße (Halfus Wyrmbreaker)
			{ spellID = 39171, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Waterlogged / Wasserdurchtränkt (Twilight Ascendant Council)
			{ spellID = 82762, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Burning Blood / Brennendes Blut (Twilight Ascendant Council)
			{ spellID = 82662, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Heart of Ice / Herz aus Eis (Twilight Ascendant Council)
			{ spellID = 82667, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Frozen / Gefroren (Twilight Ascendant Council)
			{ spellID = 92503, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Swirling Winds / Wirbelnde Winde (Twilight Ascendant Council)
			{ spellID = 83500, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Magnetic Pull / Magnetische Anziehung (Twilight Ascendant Council)
			{ spellID = 83587, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Corruption: Accelerated / Verderbnis: Beschleunigung (Cho'gall)
			{ spellID = 81836, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Corruption: Malformation / Verderbnis: Missbildung (Cho'gall)
			{ spellID = 82125, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Corruption: Absolute / Verderbnis: Vollendet (Cho'gall)
			{ spellID = 82170, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Corruption: Sickness / Verderbnis: Krankheit (Cho'gall)
			{ spellID = 93200, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Blackwing Descent
			-- Constricting Chains / Fesselnde Ketten (Magmaw)
			{ spellID = 91911, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Parasitic Infection / Parasitäre Infektion (Magmaw)
			{ spellID = 94679, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Infectious Vomit / Infektiöses Erbrochenes (Magmaw)
			{ spellID = 91923, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Lightning Conductor (Omnitron Defense System)
			{ spellID = 91433, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Shadow Infusion / Schattenmacht (Omnitron Defense System)
			{ spellID = 92048, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Flash Freeze / Blitzeis (Maloriak)
			{ spellID = 77699, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Consuming Flames / Verzehrende Flammen (Maloriak)
			{ spellID = 77786, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Finkle's Mixture / Finkels Mixtur (Chimaeron)
			{ spellID = 82705, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Shadow Conductor / Schattenleiter (Nefarian)
			{ spellID = 92053, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Throne of Four Winds
			-- Wind Chill / Windkühle (Conclave of Wind)
			{ spellID = 93123, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Slicing Gale / Schneidender Orkan (Conclave of Wind)
			{ spellID = 93058, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Static Shock / Statischer Schock (Al'Akir)
			{ spellID = 87873, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Acid Rain / Säureregen (Al'Akir)
			{ spellID = 93279, unitId = "player", caster = "all", filter = "DEBUFF" },

		},
		{
			name = "PVP目标buff",
			direction = "UP",
			setpoint = { "BOTTOM", UIParent, "BOTTOM", 35, 350 },
			size = 55,
			
			
			-- Aspect of the Pack
			{ spellID = 13159, unitId = "player", caster = "player", filter = "BUFF" },
			-- Innervate
			{ spellID = 29166, unitId = "target", caster = "all", filter = "BUFF"},
			-- Spell Reflection
			{ spellID = 23920, unitId = "target", caster = "all", filter = "BUFF" },
			-- Aura Mastery
			{ spellID = 31821, unitId = "target", caster = "all", filter = "BUFF" },
			-- Ice Block
			{ spellID = 45438, unitId = "target", caster = "all", filter = "BUFF" },
			-- Cloak of Shadows
			{ spellID = 31224, unitId = "target", caster = "all", filter = "BUFF" },
			-- Divine Shield
			{ spellID = 642, unitId = "target", caster = "all", filter = "BUFF" },
			-- Deterrence
			{ spellID = 19263, unitId = "target", caster = "all", filter = "BUFF" },
			-- Anti-Magic Shell
			{ spellID = 48707, unitId = "target", caster = "all", filter = "BUFF" },
			-- Lichborne
			{ spellID = 49039, unitId = "target", caster = "all", filter = "BUFF" },
			-- Hand of Freedom
			{ spellID = 1044, unitId = "target", caster = "all", filter = "BUFF" },
			-- Hand of Sacrifice
			{ spellID = 6940, unitId = "target", caster = "all", filter = "BUFF" },
			-- Grounding Totem Effect
			{ spellID = 8178, unitId = "target", caster = "all", filter = "BUFF" },

		},
	},
}