local R, C, L, DB = unpack(select(2, ...))

DB["media"]={
	blank = "RayUI Blank",
	normal = "RayUI Normal",
	glow = "RayUI GlowBorder",
	font = "RayUI Font",
	dmgfont = "RayUI Combat",
	pxfont = "RayUI Pixel",
	cdfont = "RayUI Roadway",
	fontsize = 12,
	fontflag = "THINOUTLINE",
	warning = "RayUI Warning",
	backdropcolor = { .05,.05,.05, .9},
	bordercolor = {0,0,0,1},	
}

DB["general"]={
	uiscale = 0.80,
	logo = true,
}

DB["worldmap"]={
	enable = true,
	lock = false,
	scale = 0.8,
	ejbuttonscale = 0.6,
	partymembersize = 25,
}

DB["minimap"]={
	enable = true,
}

DB["nameplates"]={
	enable = true,
}

DB["bag"]={
	enable = true,
}

DB["chat"]={
	enable = true,
	height = 140,
	width = 400,
	autohide = true,
	autoshow = true,
	autohidetime = 10,
}

DB["tooltip"]={
	enable = true,
	cursor = true,
}

DB["buff"]={
	enable = true,
}

DB["cooldownflash"]={
	enable = true,
}

DB["uf"]={
	powerColorClass = true,
	healthColorClass = false,
	smooth = true,
	smoothColor = true,
	powerheight = 0.13,
	showParty = true,
	showBossFrames = true,
	showArenaFrames = true,
	separateEnergy = false,
	vengeance = true,
}

DB["raid"]={
	enable = true,
    width = 60,
    height = 22,
    spacing = 8,
    numCol = 5,
    showwhensolo = false,
    showplayerinparty = true,
    showgridwhenparty = false,
    horizontal = false,
    growth = "RIGHT",
    powerbarsize = .1,
    outsideRange = .40,
    arrow = true,
    arrowmouseover = true,
    healbar = true,
    healoverflow = true,
    healothersonly = false,
    roleicon = false,    
    indicatorsize = 5,
    symbolsize = 11,
    leadersize = 12,
    aurasize = 18,
    deficit = false, --缺失生命
    perc = false, --百分比
    actual = false, --当前生命
    afk = true,
    highlight = true,
    dispel = true,
    tooltip = true,
    hidemenu = false,
}

DB["actionbar"]={
	buttonsize   = 28,
	buttonspacing   = 6,
	barscale = 1,
	petbarscale = 0.9,
	macroname = false,
	itemcount = true,
	hotkeys = true,
	showgrid = true,
	
	bar1fade = true,
	
	bar2mouseover = false,
	bar2fade = true,
	
	bar3mouseover = false,
	bar3fade = true,
	
	bar4mouseover = false,
	bar4fade = false,
	
	bar5mouseover = true,
	bar5fade = true,
	
	stancebarmouseover = false,
	stancebarfade = false,
	
	petbarmouseover = false,
	petbarfade = true,
	
	cooldownalpha = false,
	cdalpha = 1,
	readyalpha = 0.3,
	stancealpha = false,
}

DB["misc"]={
	anounce = true,
	auction = true,
	autodez = true,
	autorelease = true,
	merchant = true,
		poisons = true,
	quest = true,
		automation = true,
	reminder = true,
	raidbuffreminder = true,
		raidbuffreminderparty = false,
}

DB["skins"]={
	skada = true,
		skadaposition = true,
	dbm = true,
		dbmposition = true,
	ace3 = true,
	acp = true,
	atlasloot = true,
	bigwigs = true,
	gladius = true,
}

local SpecialList = {
	["夏琉"] = true,
}

if SpecialList[R.myname] then
	R.SpecialFunc = true
end