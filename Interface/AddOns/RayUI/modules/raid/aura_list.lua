local R, L, P = unpack(select(2, ...)) --Inport: Engine, LoRA.dbles, ProfileDB
local RA = R:GetModule("Raid")

local oUF = RayUF or oUF

local spellcache = setmetatable({}, {__index=function(t,v) local a = {GetSpellInfo(v)} if GetSpellInfo(v) then t[v] = a end return a end})
local function GetSpellInfo(a)
    return unpack(spellcache[a])
end

RA.auras = {
    -- Ascending aura timer
    -- Add spells to this list to have the aura time count up from 0
    -- NOTE: This does not show the aura, it needs to be in one of the other list too.
    ascending = {
        [GetSpellInfo(92956)] = true, -- Wrack
    },

    -- Any Zone
    debuffs = {
        --[GetSpellInfo(6788)] = 16, -- Weakened Soul
        [GetSpellInfo(39171)] = 9, -- Mortal Strike
        [GetSpellInfo(76622)] = 9, -- Sunder Armor
    },

    buffs = {
        --[GetSpellInfo(871)] = 15, -- Shield Wall
    },

    -- Raid Debuffs
    instances = {
        --["MapID"] = {
        --	[Name or GetSpellInfo(#)] = PRIORITY,
        --},
		-- Dragon Soul
	   [824] = {
			---- Dragon Soul
			-- Morchok
			[GetSpellInfo(103687)] = 7,  -- RA.dbush Armor(擊碎護甲)

			-- Zon'ozz
			[GetSpellInfo(103434)] = 7, -- Disrupting Shadows(崩解之影)

			-- Yor'sahj
			[105171] = 8, -- Deep Corruption(深度腐化)
			[109389] = 8, -- Deep Corruption(深度腐化)
			[GetSpellInfo(105171)] = 7, -- Deep Corruption(深度腐化)
			[GetSpellInfo(104849)] = 9,  -- Void Bolt(虛無箭)

			-- Hagara
			[GetSpellInfo(104451)] = 7,  -- Ice Tomb(寒冰之墓)

			-- Ultraxion
			[GetSpellInfo(110073)] = 7, -- Fading Light(凋零之光)

			-- Blackhorn
			[GetSpellInfo(109209)] = 7,  -- Brutal Strike(蠻橫打擊)
			[GetSpellInfo(108043)] = 8,  -- Sunder Armor(破甲攻擊)
			[GetSpellInfo(108861)] = 9,  -- Degeneration(衰亡)

			-- Spine
			[GetSpellInfo(105479)] = 7, -- 燃燒血漿
			--[GetSpellInfo(109379)] = 7, -- Searing Plasma(燃燒血漿)
			--[GetSpellInfo(109457)] = 8,  -- Fiery Grip(熾熱之握)
			[GetSpellInfo(105490)] = 8,  -- Fiery Grip(熾熱之握)

			-- Madness 
			[GetSpellInfo(105841)] = 7,  -- Degenerative Bite(退化咬擊)
			[GetSpellInfo(105445)] = 8,  -- Blistering Heat(極熾高熱)
			[GetSpellInfo(106444)] = 9,  -- Impale(刺穿)
	   },

        [800] = { --[[ Firelands ]]--
             
              --Trash
              --Flamewaker Forward Guard
              -- [GetSpellInfo(76622)] = 4, -- Sunder Armor
              -- [GetSpellInfo(99610)] = 5, -- Shockwave
              --Flamewaker Pathfinder
              -- [GetSpellInfo(99695)] = 4, -- Flaming Spear
              -- [GetSpellInfo(99800)] = 4, -- Ensnare
              --Flamewaker RA.dbuterizer
              -- [GetSpellInfo(99625)] = 4, -- Conflagration (Magic/dispellable)
              --Fire Scorpion
              -- [GetSpellInfo(99993)] = 4, -- Fiery Blood
              --Molten Lord
              -- [GetSpellInfo(100767)] = 4, -- Melt Armor
              --AnRA.dbent Core Hound
              -- [GetSpellInfo(99692)] = 4, -- Terrifying Roar (Magic/dispellable)
              -- [GetSpellInfo(99693)] = 4, -- Dinner Time
              --Magma
              -- [GetSpellInfo(97151)] = 4, -- Magma
             
              --Shannox
             -- [GetSpellInfo(99936)] = 5, -- Jagged Tear
             -- [GetSpellInfo(99837)] = 7, -- RA.dbystal Prison Trap Effect
             -- [GetSpellInfo(101208)] = 4, -- Immolation Trap
             -- [GetSpellInfo(99840)] = 4, -- Magma Rupture
             -- Riplimp
             -- [GetSpellInfo(99937)] = 5, -- Jagged Tear
             -- Rageface
             [GetSpellInfo(99947)] = 6, -- Face Rage
             -- [GetSpellInfo(100415)] = 5, -- Rage 
              
            --Baleroc
            -- [GetSpellInfo(99252)] = 5, -- Blaze of Glory
            [GetSpellInfo(99256)] = 5, -- 折磨
            [GetSpellInfo(99403)] = 6, -- 受到折磨
            -- [GetSpellInfo(99262)] = 4, -- Vital Spark
            -- [GetSpellInfo(99263)] = 4, -- Vital Flame
            [GetSpellInfo(99516)] = 7, -- Countdown
            -- [GetSpellInfo(99353)] = 7, -- DeRA.dbmating Strike
            -- [GetSpellInfo(100908)] = 6, -- Fiery Torment

            --Majordomo Staghelm
            [GetSpellInfo(98535)] = 5, -- Leaping Flames
            -- [GetSpellInfo(98443)] = 6, -- Fiery Cyclone
            -- [GetSpellInfo(98450)] = 5, -- Searing Seeds
            --Burning Orbs
            [GetSpellInfo(100210)] = 6, -- Burning Orb
            -- ?
            -- [GetSpellInfo(96993)] = 5, -- Stay Withdrawn?

            --Ragnaros
           -- [GetSpellInfo(99339)] = 5, -- Burning Wound
           [GetSpellInfo(100293)] = 5, -- Lava Wave
           -- [GetSpellInfo(100238)] = 4, -- Magma Trap Vulnerability
           -- [GetSpellInfo(98313)] = 4, -- Magma Blast
           --Lava SRA.dbon
           [GetSpellInfo(100460)] = 7, -- Blazing Heat
           --Dreadflame?
           --Son of Flame
           --Lava
           [GetSpellInfo(98981)] = 5, -- Lava Bolt
           --Molten Elemental
           --Living Meteor
           [GetSpellInfo(100249)] = 5, -- Combustion
           --Molten Wyrms
           [GetSpellInfo(99613)] = 6, -- Molten Blast 
        },

        [752] = { --[[ Baradin Hold ]]--

            [GetSpellInfo(88954)] = 6, -- Consuming Darkness
        },
        
        [754] = { --[[ Blackwing Descent ]]--

            --Magmaw
            [GetSpellInfo(78941)] = 6, -- Parasitic Infection
            [GetSpellInfo(89773)] = 7, -- Mangle

            --Omnitron Defense System
            [GetSpellInfo(79888)] = 6, -- Lightning Conductor
            [GetSpellInfo(79505)] = 8, -- Flamethrower
            [GetSpellInfo(80161)] = 7, -- ChemiRA.dbl Cloud
            [GetSpellInfo(79501)] = 8, -- Acquiring Target
            [GetSpellInfo(80011)] = 7, -- Soaked in Poison
            [GetSpellInfo(80094)] = 7, -- Fixate
            [GetSpellInfo(92023)] = 9, -- EnRA.dbsing Shadows
            [GetSpellInfo(92048)] = 9, -- Shadow Infusion
            [GetSpellInfo(92053)] = 9, -- Shadow Conductor
            --[GetSpellInfo(91858)] = 6, -- Overcharged Power Generator
            
            --Maloriak
            [GetSpellInfo(92973)] = 8, -- Consuming Flames
            [GetSpellInfo(92978)] = 8, -- Flash Freeze
            [GetSpellInfo(92976)] = 7, -- Biting Chill
            [GetSpellInfo(91829)] = 7, -- Fixate
            [GetSpellInfo(92787)] = 9, -- Engulfing Darkness

            --Atramedes
            [GetSpellInfo(78092)] = 7, -- Tracking
            [GetSpellInfo(78897)] = 8, -- Noisy
            [GetSpellInfo(78023)] = 7, -- Roaring Flame

            --Chimaeron
            [GetSpellInfo(89084)] = 8, -- Low Health
            [GetSpellInfo(82881)] = 7, -- Break
            [GetSpellInfo(82890)] = 9, -- Mortality

            --Nefarian
            [GetSpellInfo(94128)] = 7, -- Tail Lash
            --[GetSpellInfo(94075)] = 8, -- Magma
            [GetSpellInfo(79339)] = 9, -- Explosive RA.dbnders
            [GetSpellInfo(79318)] = 9, -- Dominion
        },

        [758] = { --[[ The Bastion of Twilight ]]--

            --Halfus
            [GetSpellInfo(39171)] = 7, -- Malevolent Strikes
            [GetSpellInfo(86169)] = 8, -- Furious Roar

            --Valiona & Theralion
            [GetSpellInfo(86788)] = 6, -- Blackout
            [GetSpellInfo(86622)] = 7, -- Engulfing Magic
            [GetSpellInfo(86202)] = 7, -- Twilight Shift

            --CounRA.dbl
            [GetSpellInfo(82665)] = 7, -- Heart of Ice
            [GetSpellInfo(82660)] = 7, -- Burning Blood
            [GetSpellInfo(82762)] = 7, -- Waterlogged
            [GetSpellInfo(83099)] = 7, -- Lightning Rod
            [GetSpellInfo(82285)] = 7, -- Elemental Stasis
            [GetSpellInfo(92488)] = 8, -- Gravity RA.dbush

            --Cho'gall
            [GetSpellInfo(86028)] = 6, -- Cho's Blast
            [GetSpellInfo(86029)] = 6, -- Gall's Blast
            [GetSpellInfo(93189)] = 7, -- Corrupted Blood
            [GetSpellInfo(93133)] = 7, -- Debilitating Beam
            [GetSpellInfo(81836)] = 8, -- Corruption: Accelerated
            [GetSpellInfo(81831)] = 8, -- Corruption: Sickness
            [GetSpellInfo(82125)] = 8, -- Corruption: Malformation
            [GetSpellInfo(82170)] = 8, -- Corruption: Absolute

            --Sinestra
            [GetSpellInfo(92956)] = 9, -- Wrack
        },

        [773] = { --[[ Throne of the Four Winds ]]--

            --Conclave
            [GetSpellInfo(85576)] = 9, -- Withering Winds
            [GetSpellInfo(85573)] = 9, -- Deafening Winds
            [GetSpellInfo(93057)] = 7, -- SliRA.dbng Gale
            [GetSpellInfo(86481)] = 8, -- HurriRA.dbne
            [GetSpellInfo(93123)] = 7, -- Wind Chill
            [GetSpellInfo(93121)] = 8, -- Toxic Spores

            --Al'Akir
            --[GetSpellInfo(93281)] = 7, -- ARA.dbd Rain
            [GetSpellInfo(87873)] = 7, -- Static Shock
            [GetSpellInfo(88427)] = 7, -- Electrocute
            [GetSpellInfo(93294)] = 8, -- Lightning Rod
            [GetSpellInfo(93284)] = 9, -- Squall Line
        },
    },
}
