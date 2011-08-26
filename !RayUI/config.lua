local R, C, DB = unpack(select(2, ...))

DB["media"]={
	blank = "RayUI Blank",
	normal = "RayUI Normal",
	glow = "RayUI GlowBorder",
	font = "RayUI Font",
	dmgfont = "RayUI Combat",
	pxfont = "RayUI Pixel",
	fontsize = 12,
	fontflag = "THINOUTLINE",
	warning = "RayUI Warning",
	backdropcolor = { .05,.05,.05, .9},
	bordercolor = {0,0,0,1},	
}

DB["general"]={
	uiscale = 0.80
}

DB["ouf"]={
	scale = 1,

	backdrop_edge_texture = "Interface\\AddOns\\!RayUI\\media\\backdrop_edge",
	backdrop_texture = "Interface\\AddOns\\!RayUI\\media\\backdrop",
	highlight_texture = "Interface\\AddOns\\!RayUI\\media\\raidbg",
	debuffBorder = "Interface\\AddOns\\!RayUI\\media\\iconborder",

	PlayerBuffFilter = true,
	DebuffOnyshowPlayer = true,
	Powercolor = true,
	HealthcolorClass = false,
	HealFrames = false, -- 治疗模式，请勿开启，我还木有写
	showIndicators = true, -- buffs indicators on healframes only
	showAuraWatch = true, -- buffs timer on raid frames(hots, shields etc)
	ShowParty = true, -- show party frames (shown as 5man raid)
	ShowRaid = true, -- show raid frames
	RaidShowSolo = false, -- show raid frames even when solo
	RaidShowAllGroups = false, -- show raid groups 6, 7 and 8 (more than 25man raid)
	enableDebuffHighlight = true, -- enable *dispelable* debuff highlight for raid frames
	showRaidDebuffs = true, -- enable important debuff icons to show on raid units
	showtot = true, -- show target of target frame
	showpet = true, -- show pet frame
	showfocus = true, -- show focus frame
	showfocustarget = true, -- show focus target frame
	showBossFrames = true, -- show boss frame
	showArenaFrames = true, -- show arena frame
	TotemBars = true, -- show Totem Bars
	MTFrames = true, -- show main tank frames
	Reputationbar = true, -- show Reputation bar
	Experiencebar = true, -- show Experience bar
	showPlayerAuras = false, -- use a custom player buffs/debuffs frame instead of Blizzard's default.
	ThreatBar = true,  -- show Threat Bar
	showRunebar = true, -- show DK rune bar
	showHolybar = true, -- show Paladin HolyPower bar
	showEclipsebar = true, -- show druid Eclipse bar
	showShardbar = true, -- show Warlock SoulShard bar
	RCheckIcon = true, -- show raid check icon
	Castbars = true, -- use built-in castbars
	showLFDIcons = true, -- Show dungeon role icons in raid/party
	showPortrait = true,
	--Frame positions

	--player
	playerx = -260,
	playery = 450,

	--target
	targetx = 0,
	targety = 340,

	--tot
	totx = 20,
	toty = 0,

	--focus
	focusx = 10,
	focusy = -100,

	--pet 
	petx = -20,
	pety = 0,
}

DB["actionbar"]= {
	barinset = 10,	
	buttonsize   = 26,
	buttonspacing   = 5,
	barscale = 1,
	petbarscale = 0.9,
	macroname = false,
	itemcount = true,
	hotkeys = true,
	
	bar1fade = true,
	
	bar2mouseover = false,
	bar2fade = true,
	
	bar3mouseover = false,
	bar3fade = true,
	
	bar4mouseover = true,
	bar4fade = true,
	
	bar5mouseover = true,
	bar5fade = true,
	
	stancebarmouseover = false,
	stancebarfade = false,
	
	petbarmouseover = false,
	petbarfade = true,
}