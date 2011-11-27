local R, C, L, DB = unpack(select(2, ...))
if not C["nameplates"].enable then return end

local FONTSIZE = 10
local hpHeight = 7
local hpWidth = 110
local iconSize = 20		--Size of all Icons, RaidIcon/ClassIcon/Castbar Icon
local cbHeight = 5
local cbWidth = 110
local blankTex = "Interface\\Buttons\\WHITE8x8"	
local OVERLAY = [=[Interface\TargetingFrame\UI-TargetingFrame-Flash]=]
local numChildren = -1
local frames = {}
local noscalemult = 768/string.match(GetCVar("gxResolution"), "%d+x(%d+)")
local function SpellName(id)
	local name, _, _, _, _, _, _, _, _ = GetSpellInfo(id) 	
	return name
end

local goodR, goodG, goodB = 75/255,  175/255, 76/255
local badR, badG, badB = 0.78, 0.25, 0.25
local transitionR, transitionG, transitionB = 218/255, 197/255, 92/255
local transitionR2, transitionG2, transitionB2 = 240/255, 154/255, 17/255

local hostilecolor = {0.78, 0.25, 0.25}
local friendlyplayercolor = {75/255,  175/255, 76/255}
local neutralcolor = {218/255, 197/255, 92/255}
local friendlynpccolor = {0.31, 0.45, 0.63}

local DebuffWhiteList = {
	-- Death Knight
		[SpellName(47476)] = true, --strangulate
		[SpellName(49203)] = true, --hungering cold
	-- Druid
		[SpellName(33786)] = true, --Cyclone
		[SpellName(2637)] = true, --Hibernate
		[SpellName(339)] = true, --Entangling Roots
		[SpellName(80964)] = true, --Skull Bash
		[SpellName(78675)] = true, --Solar Beam
	-- Hunter
		[SpellName(3355)] = true, --Freezing Trap Effect
		--[SpellName(60210)] = true, --Freezing Arrow Effect
		[SpellName(1513)] = true, --scare beast
		[SpellName(19503)] = true, --scatter shot
		[SpellName(34490)] = true, --silence shot
	-- Mage
		[SpellName(31661)] = true, --Dragon's Breath
		[SpellName(61305)] = true, --Polymorph
		[SpellName(18469)] = true, --Silenced - Improved Counterspell
		[SpellName(122)] = true, --Frost Nova
		[SpellName(55080)] = true, --Shattered Barrier
		[SpellName(82691)] = true, --Ring of Frost
	-- Paladin
		[SpellName(20066)] = true, --Repentance
		[SpellName(10326)] = true, --Turn Evil
		[SpellName(853)] = true, --Hammer of Justice
	-- Priest
		[SpellName(605)] = true, --Mind Control
		[SpellName(64044)] = true, --Psychic Horror
		[SpellName(8122)] = true, --Psychic Scream
		[SpellName(9484)] = true, --Shackle Undead
		[SpellName(15487)] = true, --Silence
	-- Rogue
		[SpellName(2094)] = true, --Blind
		[SpellName(1776)] = true, --Gouge
		[SpellName(6770)] = true, --Sap
		[SpellName(18425)] = true, --Silenced - Improved Kick
	-- Shaman
		[SpellName(51514)] = true, --Hex
		[SpellName(3600)] = true, --Earthbind
		[SpellName(8056)] = true, --Frost Shock
		[SpellName(63685)] = true, --Freeze
		[SpellName(39796)] = true, --Stoneclaw Stun
	-- Warlock
		[SpellName(710)] = true, --Banish
		[SpellName(6789)] = true, --Death Coil
		[SpellName(5782)] = true, --Fear
		[SpellName(5484)] = true, --Howl of Terror
		[SpellName(6358)] = true, --Seduction
		[SpellName(30283)] = true, --Shadowfury
		[SpellName(89605)] = true, --Aura of Foreboding
	-- Warrior
		[SpellName(20511)] = true, --Intimidating Shout
	-- Racial
		[SpellName(25046)] = true, --Arcane Torrent
		[SpellName(20549)] = true, --War Stomp
	--PVE
}

local PlateBlacklist = {
	--Shaman Totems
	["Earth Elemental Totem"] = true,
	["Fire Elemental Totem"] = true,
	["Fire Resistance Totem"] = true,
	["Flametongue Totem"] = true,
	["Frost Resistance Totem"] = true,
	["Healing Stream Totem"] = true,
	["Magma Totem"] = true,
	["Mana Spring Totem"] = true,
	["Nature Resistance Totem"] = true,
	["Searing Totem"] = true,
	["Stoneclaw Totem"] = true,
	["Stoneskin Totem"] = true,
	["Strength of Earth Totem"] = true,
	["Windfury Totem"] = true,
	["Totem of Wrath"] = true,
	["Wrath of Air Totem"] = true,

	--Army of the Dead
	["Army of the Dead Ghoul"] = true,

	--Hunter Trap
	["Venomous Snake"] = true,
	["Viper"] = true,
	
	--Misc
	["Lava Parasite"] = true,

	--Test
	--["Unbound Seer"] = true,
}
local NamePlates = CreateFrame("Frame", nil, UIParent)
NamePlates:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
NamePlates:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

local function QueueObject(parent, object)
	parent.queue = parent.queue or {}
	parent.queue[object] = true
end

local function HideObjects(parent)
	for object in pairs(parent.queue) do
		if(object:GetObjectType() == 'Texture') then
			object:SetTexture(nil)
			object.SetTexture = function() return end
		elseif (object:GetObjectType() == 'FontString') then
			object.ClearAllPoints = function() return end
			object.SetFont = function() return end
			object.SetPoint = function() return end
			object:Hide()
			object.Show = function() return end
			object.SetText = function() return end
			object.SetShadowOffset = function() return end
		else
			object:Hide()
			object.Show = function() return end
		end
	end
end

--Create a fake backdrop frame using textures
local function CreateVirtualFrame(parent, point)
	if point == nil then point = parent end
	
	if point.backdrop or parent.backdrop then return end
	
	parent.backdrop = CreateFrame("Frame", nil ,parent)
	parent.backdrop:SetPoint("TOPLEFT", -noscalemult*1, noscalemult*1)
	parent.backdrop:SetPoint("BOTTOMRIGHT", noscalemult*1, -noscalemult*1)
	parent.backdrop:CreateShadow("Default", -1, 2)

	parent.backdrop2 = parent:CreateTexture(nil, "BORDER")
	parent.backdrop2:SetDrawLayer("BORDER", -7)
	parent.backdrop2:SetAllPoints(point)
	parent.backdrop2:SetTexture(.05,.05,.05)
end

local function SetVirtualBorder(parent, r, g, b)

end

--Create our Aura Icons
local function CreateAuraIcon(parent)
	local button = CreateFrame("Frame",nil,parent)
	button:SetWidth(20)
	button:SetHeight(20)
	
	button:CreateShadow()
	
	button.bord = button:CreateTexture(nil, "BORDER")
	button.bord:SetTexture(0, 0, 0, 1)
	button.bord:SetPoint("TOPLEFT",button,"TOPLEFT", noscalemult,-noscalemult)
	button.bord:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-noscalemult,noscalemult)
	
	button.bg2 = button:CreateTexture(nil, "ARTWORK")
	button.bg2:SetTexture(unpack(C["media"].backdropcolor))
	button.bg2:SetPoint("TOPLEFT",button,"TOPLEFT", noscalemult*2,-noscalemult*2)
	button.bg2:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-noscalemult*2,noscalemult*2)	
	
	button.icon = button:CreateTexture(nil, "OVERLAY")
	button.icon:SetPoint("TOPLEFT",button,"TOPLEFT", noscalemult*3,-noscalemult*3)
	button.icon:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-noscalemult*3,noscalemult*3)
	button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	button.cd = CreateFrame("Cooldown",nil,button)
	button.cd:SetAllPoints(button)
	button.cd:SetReverse(true)
	button.count = button:CreateFontString(nil,"OVERLAY")
	button.count:SetFont(C["media"].font,9,C["media"].fontflag)
	button.count:SetShadowColor(0, 0, 0, 0.4)
	button.count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 2)
	return button
end

--Update an Aura Icon
local function UpdateAuraIcon(button, unit, index, filter)
	local name,_,icon,count,debuffType,duration,expirationTime,_,_,_,spellID = UnitAura(unit,index,filter)
	
	if debuffType then
		button.bord:SetTexture(DebuffTypeColor[debuffType].r, DebuffTypeColor[debuffType].g, DebuffTypeColor[debuffType].b)
	else
		button.bord:SetTexture(1, 0, 0, 1)
	end
	button.icon:SetTexture(icon)
	button.cd:SetCooldown(expirationTime-duration,duration)
	button.expirationTime = expirationTime
	button.duration = duration
	button.spellID = spellID
	if count > 1 then 
		button.count:SetText(count)
	else
		button.count:SetText("")
	end
	button.cd:SetScript("OnUpdate", function(self) if not button.cd.timer then self:SetScript("OnUpdate", nil) return end button.cd.timer.text:SetFont(C["media"].font,11,C["media"].fontflag) button.cd.timer.text:SetShadowColor(0, 0, 0, 0.4) end)
	button:Show()
end

--Filter auras on nameplate, and determine if we need to update them or not.
local function OnAura(frame, unit)
	if not frame.icons or not frame.unit then return end
	local i = 1
	for index = 1,40 do
		if i > 5 then return end
		local match
		local name,_,_,_,_,duration,_,caster,_,_,spellid = UnitAura(frame.unit,index,"HARMFUL")
		
		if caster == "player" then match = true end
		if DebuffWhiteList[name] then match = true end
		
		if duration and match == true then
			if not frame.icons[i] then frame.icons[i] = CreateAuraIcon(frame) end
			local icon = frame.icons[i]
			if i == 1 then icon:SetPoint("RIGHT",frame.icons,"RIGHT") end
			if i ~= 1 and i <= 5 then icon:SetPoint("RIGHT", frame.icons[i-1], "LEFT", -2, 0) end
			i = i + 1
			UpdateAuraIcon(icon, frame.unit, index, "HARMFUL")
		end
	end
	for index = i, #frame.icons do frame.icons[index]:Hide() end
end

--Color the castbar depending on if we can interrupt or not, 
--also resize it as nameplates somehow manage to resize some frames when they reappear after being hidden
local function UpdateCastbar(frame)
	frame:ClearAllPoints()
	frame:SetSize(cbWidth, cbHeight)
	frame:SetPoint('TOP', frame:GetParent().hp, 'BOTTOM', 0, -8)
	frame:GetStatusBarTexture():SetHorizTile(true)
	if(frame.shield:IsShown()) then
		frame:SetStatusBarColor(0.78, 0.25, 0.25, 1)
	end
end	

--Determine whether or not the cast is Channelled or a Regular cast so we can grab the proper Cast Name
local function UpdateCastText(frame, curValue)
	local minValue, maxValue = frame:GetMinMaxValues()
	
	if UnitChannelInfo("target") then
		frame.time:SetFormattedText("%.1f ", curValue)
		frame.name:SetText(select(1, (UnitChannelInfo("target"))))
	end
	
	if UnitCastingInfo("target") then
		frame.time:SetFormattedText("%.1f ", maxValue - curValue)
		frame.name:SetText(select(1, (UnitCastingInfo("target"))))
	end
end

--Sometimes castbar likes to randomly resize
local OnValueChanged = function(self, curValue)
	UpdateCastText(self, curValue)
	if self.needFix then
		UpdateCastbar(self)
		self.needFix = nil
	end
end

--Sometimes castbar likes to randomly resize
local OnSizeChanged = function(self)
	self.needFix = true
end

--We need to reset everything when a nameplate it hidden, this is so theres no left over data when a nameplate gets reshown for a differant mob.
local function OnHide(frame)
	frame.hp:SetStatusBarColor(frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor)
	frame.overlay:Hide()
	frame.cb:Hide()
	frame.unit = nil
	frame.threatStatus = nil
	frame.guid = nil
	frame.hasClass = nil
	frame.isFriendly = nil
	frame.hp.rcolor = nil
	frame.hp.gcolor = nil
	frame.hp.bcolor = nil
	if frame.icons then
		for _,icon in ipairs(frame.icons) do
			icon:Hide()
		end
	end	
	
	frame:SetScript("OnUpdate",nil)
end

--Color Nameplate
local function Colorize(frame)
	local r,g,b = frame.healthOriginal:GetStatusBarColor()
	
	for class, color in pairs(RAID_CLASS_COLORS) do
		local r, g, b = floor(r*100+.5)/100, floor(g*100+.5)/100, floor(b*100+.5)/100
		if RAID_CLASS_COLORS[class].r == r and RAID_CLASS_COLORS[class].g == g and RAID_CLASS_COLORS[class].b == b then
			frame.hasClass = true
			frame.isFriendly = false
			frame.hp:SetStatusBarColor(unpack(R.colors.class[class]))
			return
		end
	end
	
	if g+b == 0 then -- hostile
		r,g,b = unpack(R.colors.reaction[1])
		frame.isFriendly = false
	elseif r+b == 0 then -- friendly npc
		r,g,b = unpack(R.colors.power["MANA"])
		frame.isFriendly = true
	elseif r+g > 1.95 then -- neutral
		r,g,b = unpack(R.colors.reaction[4])
		frame.isFriendly = false
	elseif r+g == 0 then -- friendly player
		r,g,b = unpack(R.colors.reaction[5])
		frame.isFriendly = true
	else -- enemy player
		frame.isFriendly = false
	end
	frame.hasClass = false
	
	frame.hp:SetStatusBarColor(r,g,b)
end

--HealthBar OnShow, use this to set variables for the nameplate, also size the healthbar here because it likes to lose it's
--size settings when it gets reshown
local function UpdateObjects(frame)
	local frame = frame:GetParent()
	
	local r, g, b = frame.hp:GetStatusBarColor()	
	
	--Have to reposition this here so it doesnt resize after being hidden
	frame.hp:ClearAllPoints()
	frame.hp:SetSize(hpWidth, hpHeight)	
	frame.hp:SetPoint('TOP', frame, 'TOP', 0, -15)
	frame.hp:GetStatusBarTexture():SetHorizTile(true)
	
	frame.hp:SetMinMaxValues(frame.healthOriginal:GetMinMaxValues())
	frame.hp:SetValue(frame.healthOriginal:GetValue())

	
	--Colorize Plate
	Colorize(frame)
	frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor = frame.hp:GetStatusBarColor()
	frame.hp.hpbg:SetTexture(frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor, 0.25)
	SetVirtualBorder(frame.hp, 0, 0, 0, 1)
	frame.hp.name:SetTextColor(frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor)
	
	--Set the name text
	frame.hp.name:SetText(frame.hp.oldname:GetText())
	
	local level, elite, mylevel = tonumber(frame.hp.oldlevel:GetText()), frame.hp.elite:IsShown(), UnitLevel("player")
	frame.hp.level:ClearAllPoints()
	frame.hp.level:SetPoint("RIGHT", frame.hp, "RIGHT", 2, 0)
	
	frame.hp.level:SetTextColor(frame.hp.oldlevel:GetTextColor())
	if frame.hp.boss:IsShown() then
		frame.hp.level:SetText("??")
		frame.hp.level:SetTextColor(0.8, 0.05, 0)
		frame.hp.level:Show()
	elseif not elite and level == mylevel then
		frame.hp.level:Hide()
	else
		frame.hp.level:SetText(level..(elite and "+" or ""))
		frame.hp.level:Show()
	end
	
	frame.overlay:ClearAllPoints()
	frame.overlay:SetAllPoints(frame.hp)
	
	if frame.icons then return end
	frame.icons = CreateFrame("Frame",nil,frame)
	frame.icons:SetPoint("BOTTOMRIGHT",frame.hp,"TOPRIGHT", 0, FONTSIZE+5)
	frame.icons:SetWidth(20 + hpWidth)
	frame.icons:SetHeight(25)
	frame.icons:SetFrameLevel(frame.hp:GetFrameLevel()+2)
	frame:RegisterEvent("UNIT_AURA")
	frame:HookScript("OnEvent", OnAura)

	HideObjects(frame)
end

--This is where we create most 'Static' objects for the nameplate, it gets fired when a nameplate is first seen.
local function SkinObjects(frame)
	local oldhp, cb = frame:GetChildren()
	local threat, hpborder, overlay, oldname, oldlevel, bossicon, raidicon, elite = frame:GetRegions()
	local _, cbborder, cbshield, cbicon = cb:GetRegions()

	--Health Bar
	frame.healthOriginal = oldhp
	local hp = CreateFrame("Statusbar", nil, frame)
	hp:SetFrameLevel(oldhp:GetFrameLevel())
	hp:SetFrameStrata(oldhp:GetFrameStrata())
	hp:SetStatusBarTexture(C["media"].normal)
	CreateVirtualFrame(hp)
	
	hp.level = hp:CreateFontString(nil, "OVERLAY")
	hp.level:SetFont(C["media"].font, FONTSIZE, C["media"].fontflag)
	hp.level:SetShadowColor(0, 0, 0, 0.4)
	hp.level:SetTextColor(1, 1, 1)
	hp.level:SetShadowOffset(R.mult, -R.mult)	
	hp.oldlevel = oldlevel
	hp.boss = bossicon
	hp.elite = elite
	
	hp.value = hp:CreateFontString(nil, "OVERLAY")	
	hp.value:SetFont(C["media"].font, FONTSIZE, C["media"].fontflag)
	hp.value:SetShadowColor(0, 0, 0, 0.4)
	hp.value:SetPoint("CENTER", hp)
	hp.value:SetTextColor(1,1,1)
	hp.value:SetShadowOffset(R.mult, -R.mult)
	
	--Create Name Text
	hp.name = hp:CreateFontString(nil, 'OVERLAY')
	hp.name:SetPoint('BOTTOMLEFT', hp, 'TOPLEFT', -10, 3)
	hp.name:SetPoint('BOTTOMRIGHT', hp, 'TOPRIGHT', 10, 3)
	hp.name:SetFont(C["media"].font, FONTSIZE, C["media"].fontflag)
	hp.name:SetShadowColor(0, 0, 0, 0.4)
	hp.name:SetShadowOffset(R.mult, -R.mult)
	hp.oldname = oldname

	hp.hpbg = hp:CreateTexture(nil, 'BORDER')
	hp.hpbg:SetAllPoints(hp)
	hp.hpbg:SetTexture(1,1,1,0.25) 		
	
	hp:HookScript('OnShow', UpdateObjects)
	frame.hp = hp
	
	--Cast Bar
	cb:SetStatusBarTexture(C["media"].normal)
	CreateVirtualFrame(cb)
	
	--Create Cast Time Text
	cb.time = cb:CreateFontString(nil, "ARTWORK")
	cb.time:SetPoint("RIGHT", cb, "LEFT", -1, 0)
	cb.time:SetFont(C["media"].font, FONTSIZE, C["media"].fontflag)
	cb.time:SetShadowColor(0, 0, 0, 0.4)
	cb.time:SetTextColor(1, 1, 1)
	cb.time:SetShadowOffset(R.mult, -R.mult)

	--Create Cast Name Text
	cb.name = cb:CreateFontString(nil, "ARTWORK")
	cb.name:SetPoint("TOP", cb, "BOTTOM", 0, -3)
	cb.name:SetFont(C["media"].font, FONTSIZE, C["media"].fontflag)
	cb.name:SetTextColor(1, 1, 1)
	cb.name:SetShadowColor(0, 0, 0, 0.4)
	cb.name:SetShadowOffset(R.mult, -R.mult)		
	
	--Setup CastBar Icon
	cbicon:ClearAllPoints()
	cbicon:SetPoint("TOPLEFT", hp, "TOPRIGHT", 8, 0)		
	cbicon:SetSize(iconSize, iconSize)
	cbicon:SetTexCoord(.07, .93, .07, .93)
	cbicon:SetDrawLayer("OVERLAY")
	cb.icon = cbicon
	CreateVirtualFrame(cb, cb.icon)
	
	cb.shield = cbshield
	cbshield:ClearAllPoints()
	cbshield:SetPoint("TOP", cb, "BOTTOM")
	cb:HookScript('OnShow', UpdateCastbar)
	cb:HookScript('OnSizeChanged', OnSizeChanged)
	cb:HookScript('OnValueChanged', OnValueChanged)			
	frame.cb = cb
	
	--Highlight
	overlay:SetTexture(1,1,1,0.15)
	overlay:SetAllPoints(hp)	
	frame.overlay = overlay

	--Reposition and Resize RaidIcon
	raidicon:ClearAllPoints()
	raidicon:SetPoint("BOTTOM", hp, "TOP", 0, 16)
	raidicon:SetSize(iconSize*1.4, iconSize*1.4)
	raidicon:SetTexture([[Interface\AddOns\!RayUI\media\raidicons.blp]])	
	frame.raidicon = raidicon
	
	--Hide Old Stuff
	QueueObject(frame, oldhp)
	QueueObject(frame, oldlevel)
	QueueObject(frame, threat)
	QueueObject(frame, hpborder)
	QueueObject(frame, cbshield)
	QueueObject(frame, cbborder)
	QueueObject(frame, oldname)
	QueueObject(frame, bossicon)
	QueueObject(frame, elite)
	
	UpdateObjects(hp)
	UpdateCastbar(cb)
	
	frame:HookScript('OnHide', OnHide)
	frames[frame] = true
	frame.RayUIPlate = true
end

local function UpdateThreat(frame, elapsed)
	frame.hp:Show()
	if frame.hasClass == true then return end
	if not frame.region:IsShown() then
		if InCombatLockdown() and frame.isFriendly ~= true then
			--No Threat
			if R.Role == "Tank" then
				frame.hp:SetStatusBarColor(badR, badG, badB)
				frame.hp.hpbg:SetTexture(badR, badG, badB, 0.25)
				frame.threatStatus = "BAD"
			else
				frame.hp:SetStatusBarColor(goodR, goodG, goodB)
				frame.hp.hpbg:SetTexture(goodR, goodG, goodB, 0.25)
				frame.threatStatus = "GOOD"
			end		
		else
			--Set colors to their original, not in combat
			frame.hp:SetStatusBarColor(frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor)
			frame.hp.hpbg:SetTexture(frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor, 0.25)
			frame.threatStatus = nil
		end
	else
		--Ok we either have threat or we're losing/gaining it
		local r, g, b = frame.region:GetVertexColor()
		if g + b == 0 then
			--Have Threat
			if R.Role == "Tank" then
				frame.hp:SetStatusBarColor(goodR, goodG, goodB)
				frame.hp.hpbg:SetTexture(goodR, goodG, goodB, 0.25)
				frame.threatStatus = "GOOD"
			else
				frame.hp:SetStatusBarColor(badR, badG, badB)
				frame.hp.hpbg:SetTexture(badR, badG, badB, 0.25)
				frame.threatStatus = "BAD"
			end
		else
			--Losing/Gaining Threat
			if R.Role == "Tank" then
				if frame.threatStatus == "GOOD" then
					--Losing Threat
					frame.hp:SetStatusBarColor(transitionR2, transitionG2, transitionB2)	
					frame.hp.hpbg:SetTexture(transitionR2, transitionG2, transitionB2, 0.25)				
				else
					--Gaining Threat
					frame.hp:SetStatusBarColor(transitionR, transitionG, transitionB)	
					frame.hp.hpbg:SetTexture(transitionR, transitionG, transitionB, 0.25)	
				end
			else
				if frame.threatStatus == "GOOD" then
					--Losing Threat
					frame.hp:SetStatusBarColor(transitionR, transitionG, transitionB)	
					frame.hp.hpbg:SetTexture(transitionR, transitionG, transitionB, 0.25)				
				else
					--Gaining Threat
					frame.hp:SetStatusBarColor(transitionR2, transitionG2, transitionB2)	
					frame.hp.hpbg:SetTexture(transitionR2, transitionG2, transitionB2, 0.25)	
				end				
			end
		end
	end
end

--Create our blacklist for nameplates, so prevent a certain nameplate from ever showing
local function CheckBlacklist(frame, ...)
	if PlateBlacklist[frame.hp.name:GetText()] then
		frame:SetScript("OnUpdate", function() end)
		frame.hp:Hide()
		frame.cb:Hide()
		frame.overlay:Hide()
		frame.hp.oldlevel:Hide()
	end
end

--When becoming intoxicated blizzard likes to re-show the old level text, this should fix that
local function HideDrunkenText(frame, ...)
	if frame and frame.hp.oldlevel and frame.hp.oldlevel:IsShown() then
		frame.hp.oldlevel:Hide()
	end
end

--Force the name text of a nameplate to be behind other nameplates unless it is our target
local function AdjustNameLevel(frame, ...)
	if UnitName("target") == frame.hp.name:GetText() and frame:GetAlpha() == 1 then
		frame.hp.name:SetDrawLayer("OVERLAY")
	else
		frame.hp.name:SetDrawLayer("BORDER")
	end
end

--Health Text, also border coloring for certain plates depending on health
local function ShowHealth(frame, ...)
	-- show current health value
	local minHealth, maxHealth = frame.healthOriginal:GetMinMaxValues()
	local valueHealth = frame.healthOriginal:GetValue()
	local d =(valueHealth/maxHealth)*100
	
	--Match values
	frame.hp:SetValue(valueHealth - 1)	--Bug Fix 4.1
	frame.hp:SetValue(valueHealth)	
	
	frame.hp.value:SetText(R.ShortValue(valueHealth).." - "..(string.format("%d%%", math.floor((valueHealth/maxHealth)*100))))
	
	--Change frame style if the frame is our target or not
	if UnitName("target") == frame.hp.name:GetText() and frame:GetAlpha() == 1 then
		--Targetted Unit
		frame.hp.name:SetTextColor(1, 1, 1)
	else
		--Not Targetted
		-- frame.hp.name:SetTextColor(1, 1, 1)
		frame.hp.name:SetTextColor(frame.hp:GetStatusBarColor())
	end
			
	--Setup frame shadow to change depending on enemy players health, also setup targetted unit to have white shadow
	if frame.hasClass == true or frame.isFriendly == true then
		if(d <= 50 and d >= 20) then
			SetVirtualBorder(frame.hp, 1, 1, 0)
		elseif(d < 20) then
			SetVirtualBorder(frame.hp, 1, 0, 0)
		else
			SetVirtualBorder(frame.hp, 0, 0, 0, 1)
		end
	elseif (frame.hasClass ~= true and frame.isFriendly ~= true) then
		SetVirtualBorder(frame.hp, 0, 0, 0, 1)
	end
end

--Scan all visible nameplate for a known unit.
local function CheckUnit_Guid(frame, ...)
	--local numParty, numRaid = GetNumPartyMembers(), GetNumRaidMembers()
	if UnitExists("target") and frame:GetAlpha() == 1 and UnitName("target") == frame.hp.name:GetText() then
		frame.guid = UnitGUID("target")
		frame.unit = "target"
		OnAura(frame, "target")
	elseif frame.overlay:IsShown() and UnitExists("mouseover") and UnitName("mouseover") == frame.hp.name:GetText() then
		frame.guid = UnitGUID("mouseover")
		frame.unit = "mouseover"
		OnAura(frame, "mouseover")
	else
		frame.unit = nil
	end	
end

--Update settings for nameplate to match config
local function CheckSettings(frame, ...)
	--Width
	if frame.hp:GetWidth() ~= 110 then
		frame.hp:Width(110)
		hpWidth = 110
	end
end

--Attempt to match a nameplate with a GUID from the combat log
local function MatchGUID(frame, destGUID, spellID)
	if not frame.guid then return end
	
	
	if frame.guid == destGUID then
		for _,icon in ipairs(frame.icons) do 
			if icon.spellID == spellID then 
				icon:Hide() 
			end 
		end
	end
end

--Run a function for all visible nameplates, we use this for the blacklist, to check unitguid, and to hide drunken text
local function ForEachPlate(functionToRun, ...)
	for frame in pairs(frames) do
		if frame:IsShown() then
			functionToRun(frame, ...)
		end
	end
end

--Check if the frames default overlay texture matches blizzards nameplates default overlay texture
local select = select
local function HookFrames(...)
	for index = 1, select('#', ...) do
		local frame = select(index, ...)
		local region = frame:GetRegions()
		
		if(not frames[frame] and (frame:GetName() and frame:GetName():find("NamePlate%d")) and region and region:GetObjectType() == 'Texture' and region:GetTexture() == OVERLAY) then
			SkinObjects(frame)
			frame.region = region
		end
	end
end

--Core right here, scan for any possible nameplate frames that are Children of the WorldFrame
CreateFrame('Frame'):SetScript('OnUpdate', function(self, elapsed)
	if(WorldFrame:GetNumChildren() ~= numChildren) then
		numChildren = WorldFrame:GetNumChildren()
		HookFrames(WorldFrame:GetChildren())
	end

	if(self.elapsed and self.elapsed > 0.2) then
		ForEachPlate(UpdateThreat, self.elapsed)
		ForEachPlate(AdjustNameLevel)
		self.elapsed = 0
	else
		self.elapsed = (self.elapsed or 0) + elapsed
	end
	
	ForEachPlate(ShowHealth)
	ForEachPlate(CheckBlacklist)
	ForEachPlate(HideDrunkenText)
	ForEachPlate(CheckUnit_Guid)
	ForEachPlate(CheckSettings)
end)

function NamePlates:COMBAT_LOG_EVENT_UNFILTERED(_, event, ...)
	if event == "SPELL_AURA_REMOVED" then
		local _, sourceGUID, _, _, _, destGUID, _, _, _, spellID = ...
		
		if sourceGUID == UnitGUID("player") then
			ForEachPlate(MatchGUID, destGUID, spellID)
		end
	end
end

NamePlates:RegisterEvent("PLAYER_ENTERING_WORLD")
function NamePlates:PLAYER_ENTERING_WORLD()
	SetCVar("threatWarning", 3)
	SetCVar("bloatthreat", 0)
	SetCVar("bloattest", 1)
	SetCVar("bloatnameplates", 0)
end