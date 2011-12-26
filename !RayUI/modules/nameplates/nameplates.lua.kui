--[[
	Kui Nameplates
	Kesava-Auchindoun
	As part of Kui
	
	TODO try to use default cast bar
	TODO add options to change the cast bar's uninterruptible glow/bar colour
]]

local R, C, L, DB = unpack(select(2, ...))
if not C["nameplates"].enable then return end

local nameplates = CreateFrame("Frame")
local loadedGUIDs, loadedNames, targetExists = {}, {}
local noscalemult = 768/string.match(GetCVar("gxResolution"), "%d+x(%d+)")

local config = {
	fade = true,
	fadespeed = .5,
	fadedalpha = .3,
	highlight = true,
	combopoints = true,
	spellicon = true,
	spellname = true,
	casttime = true,
	castbarcolor = { .2, .6, .1 },
	color = {
		{ .7, .2, .1 },		-- hated
		{ 1, .8, 0 },		-- neutral
		{ .2, .6, .1 },		-- friendly
		{ 218/255, 197/255, 92/255 },			--transition1
		{ 240/255, 154/255, 17/255 },			--transition2
	}
}

local DebuffWhiteList = {
	-- Death Knight
		[GetSpellInfo(47476)] = true, --strangulate
		[GetSpellInfo(49203)] = true, --hungering cold
	-- Druid
		[GetSpellInfo(33786)] = true, --Cyclone
		[GetSpellInfo(2637)] = true, --Hibernate
		[GetSpellInfo(339)] = true, --Entangling Roots
		[GetSpellInfo(80964)] = true, --Skull Bash
		[GetSpellInfo(78675)] = true, --Solar Beam
	-- Hunter
		[GetSpellInfo(3355)] = true, --Freezing Trap Effect
		--[GetSpellInfo(60210)] = true, --Freezing Arrow Effect
		[GetSpellInfo(1513)] = true, --scare beast
		[GetSpellInfo(19503)] = true, --scatter shot
		[GetSpellInfo(34490)] = true, --silence shot
	-- Mage
		[GetSpellInfo(31661)] = true, --Dragon's Breath
		[GetSpellInfo(61305)] = true, --Polymorph
		[GetSpellInfo(18469)] = true, --Silenced - Improved Counterspell
		[GetSpellInfo(122)] = true, --Frost Nova
		[GetSpellInfo(55080)] = true, --Shattered Barrier
		[GetSpellInfo(82691)] = true, --Ring of Frost
	-- Paladin
		[GetSpellInfo(20066)] = true, --Repentance
		[GetSpellInfo(10326)] = true, --Turn Evil
		[GetSpellInfo(853)] = true, --Hammer of Justice
	-- Priest
		[GetSpellInfo(605)] = true, --Mind Control
		[GetSpellInfo(64044)] = true, --Psychic Horror
		[GetSpellInfo(8122)] = true, --Psychic Scream
		[GetSpellInfo(9484)] = true, --Shackle Undead
		[GetSpellInfo(15487)] = true, --Silence
	-- Rogue
		[GetSpellInfo(2094)] = true, --Blind
		[GetSpellInfo(1776)] = true, --Gouge
		[GetSpellInfo(6770)] = true, --Sap
		[GetSpellInfo(18425)] = true, --Silenced - Improved Kick
	-- Shaman
		[GetSpellInfo(51514)] = true, --Hex
		[GetSpellInfo(3600)] = true, --Earthbind
		[GetSpellInfo(8056)] = true, --Frost Shock
		[GetSpellInfo(63685)] = true, --Freeze
		[GetSpellInfo(39796)] = true, --Stoneclaw Stun
	-- Warlock
		[GetSpellInfo(710)] = true, --Banish
		[GetSpellInfo(6789)] = true, --Death Coil
		[GetSpellInfo(5782)] = true, --Fear
		[GetSpellInfo(5484)] = true, --Howl of Terror
		[GetSpellInfo(6358)] = true, --Seduction
		[GetSpellInfo(30283)] = true, --Shadowfury
		[GetSpellInfo(89605)] = true, --Aura of Foreboding
	-- Warrior
		[GetSpellInfo(20511)] = true, --Intimidating Shout
	-- Racial
		[GetSpellInfo(25046)] = true, --Arcane Torrent
		[GetSpellInfo(20549)] = true, --War Stomp
	--PVE
}

local PlateBlacklist = {
	--圖騰
	[GetSpellInfo(2062)] = true,  --土元素圖騰
	[GetSpellInfo(2894)] = true,  --火元素圖騰
	[GetSpellInfo(8184)] = true,  --元素抗性圖騰
	[GetSpellInfo(8227)] = true,  --火舌圖騰
	[GetSpellInfo(5394)] = true,  --治療之泉圖騰
	[GetSpellInfo(8190)] = true,  --熔岩圖騰
	[GetSpellInfo(5675)] = true,  --法力之泉圖騰
	[GetSpellInfo(3599)] = true,  --灼熱圖騰
	[GetSpellInfo(5730)] = true,  --石爪圖騰
	[GetSpellInfo(8071)] = true,  --石甲圖騰
	[GetSpellInfo(8075)] = true,  --大地之力圖騰
	[GetSpellInfo(8512)] = true,  --風怒圖騰
	[GetSpellInfo(3738)] = true,  --風懲圖騰
	[GetSpellInfo(87718)] = true,  --平静思绪圖騰

	--亡者大軍
	["亡者军团食尸鬼"] = true,
	["食屍鬼大軍"] = true,
	["Army of the Dead Ghoul"] = true,

	--陷阱
	["Venomous Snake"] = true,
	["毒蛇"] = true,
	["剧毒蛇"] = true,

	["Viper"] = true,
	["響尾蛇"] = true,
	
	--Misc
	["Lava Parasite"] = true,
	["熔岩蟲"] = true,
	["熔岩寄生虫"] = true,
}

-- combat log events to listen to for cast warnings/healing
local castEvents = {
	['SPELL_CAST_START'] = true,
	['SPELL_CAST_SUCCESS'] = true,
	['SPELL_INTERRUPT'] = true,
	['SPELL_HEAL'] = true,
	['SPELL_PERIODIC_HEAL'] = true
}

function nameplates.CreateFontString(parent, args)
	local ob, font, size, outline, alpha, shadow
	args = args or {}

	if args.reset then
		-- to change an already existing fontString
		ob = parent
	else
		ob = parent:CreateFontString(nil, 'OVERLAY')
	end

	font	= args.font or C.media.font
	size	= args.size or 12
	outline	= args.outline or nil
	alpha	= args.alpha or 1
	shadow	= args.shadow or false
	
	ob:SetFont(font, size, outline)
	ob:SetAlpha(alpha)
	
	if shadow then
		ob:SetShadowColor(0, 0, 0, 1)
		ob:SetShadowOffset(type(shadow) == 'table' and unpack(shadow) or 1, -1)
	elseif not shadow and args.reset then
		-- remove the shadow
		ob:SetShadowColor(0, 0, 0, 0)
	end
	
	return ob
end

-- Frame fading functions
-- (without the taint of UIFrameFade & without the lag of AnimationGroups)
nameplates.frameFadeFrame = CreateFrame('Frame')
nameplates.FADEFRAMES = {}

nameplates.frameIsFading = function(frame)
	for index, value in pairs(nameplates.FADEFRAMES) do
		if value == frame then
			return true
		end
	end
end

nameplates.frameFadeRemoveFrame = function(frame)
	tDeleteItem(nameplates.FADEFRAMES, frame)
end

nameplates.frameFadeOnUpdate = function(self, elapsed)
	local frame, info
	for index, value in pairs(nameplates.FADEFRAMES) do
		frame, info = value, value.fadeInfo
		
		info.fadeTimer = (info.fadeTimer and info.fadeTimer + elapsed) or 0
		
		if info.fadeTimer < info.timeToFade then
			-- perform animation in either direction
			if info.mode == 'IN' then
				frame:SetAlpha(
					(info.fadeTimer / info.timeToFade) *
					(info.endAlpha - info.startAlpha) +
					info.startAlpha
				)
			elseif info.mode == 'OUT' then
				frame:SetAlpha(
					((info.timeToFade - info.fadeTimer) / info.timeToFade) *
					(info.startAlpha - info.endAlpha) + info.endAlpha
				)
			end
		else
			-- animation has ended
			frame:SetAlpha(info.endAlpha)
			
			-- I knew I'd discover something useful by copying this
			if info.fadeHoldTime and info.fadeHoldTime > 0 then
				info.fadeHoldTime = info.fadeHoldTime - elapsed
			else
				-- hold time is nil/has elapsed
				nameplates.frameFadeRemoveFrame(frame)
				
				if info.finishedFunc then
					info.finishedFunc()
					info.finishedFunc = nil
				end
			end
		end
	end
	
	if #nameplates.FADEFRAMES == 0 then
		self:SetScript('OnUpdate', nil)
	end
end

nameplates.frameFade = function(frame, info)
    if not frame then return end

    info		= info or {}
    info.mode	= info.mode or 'IN'
	
    if info.mode == 'IN' then
		info.startAlpha	= info.startAlpha or 0
		info.endAlpha	= info.endAlpha or 1
	elseif info.mode == 'OUT' then
		info.startAlpha	= info.startAlpha or 1
		info.endAlpha	= info.endAlpha or 0
	end
	
	frame:SetAlpha(info.startAlpha)
	frame.fadeInfo = info
	
	if not nameplates.frameIsFading(frame) then
		tinsert(nameplates.FADEFRAMES, frame)
		nameplates.frameFadeFrame:SetScript('OnUpdate', nameplates.frameFadeOnUpdate)
	end
end

------------------------------------------------------------- Frame functions --
-- set colour of health bar according to reaction/threat
local function SetHealthColour(self)

	if InCombatLockdown() and not self.friend then
		self.health.reset = true
		if not self.glow:IsShown() then
			if R.Role == "Tank" then
				self.health:SetStatusBarColor(unpack(config.color[1]))
				self.threatStatus = "BAD"
				self:SetGlowColour(unpack(config.color[1]))
			else
				self.health:SetStatusBarColor(unpack(config.color[3]))
				self.threatStatus = "GOOD"
				self:SetGlowColour()
			end
		else
			local r, g, b = self.glow:GetVertexColor()
			if g + b == 0 then
			--Have Threat
				if R.Role == "Tank" then
					self.health:SetStatusBarColor(unpack(config.color[3]))
					self.threatStatus = "GOOD"
					self:SetGlowColour()
				else
					self.health:SetStatusBarColor(unpack(config.color[1]))
					self.threatStatus = "BAD"
					self:SetGlowColour(unpack(config.color[1]))
				end
			else
				--Losing/Gaining Threat
				if R.Role == "Tank" then
					if self.threatStatus == "GOOD" then
						--Losing Threat
						self.health:SetStatusBarColor(unpack(config.color[5]))
						self:SetGlowColour(unpack(config.color[1]))
					else
						--Gaining Threat
						self.health:SetStatusBarColor(unpack(config.color[4]))
						self:SetGlowColour()
					end
				else
					if self.threatStatus == "GOOD" then
						--Losing Threat
						self.health:SetStatusBarColor(unpack(config.color[4]))
						self:SetGlowColour()
					else
						--Gaining Threat
						self.health:SetStatusBarColor(unpack(config.color[5]))
						self:SetGlowColour(unpack(config.color[1]))
					end				
				end
			end
		end
		return
	end

	frame.threatStatus = nil
	self:SetGlowColour()

	local r, g, b = self.oldHealth:GetStatusBarColor()
	if	self.health.reset  or
		r ~= self.health.r or
		g ~= self.health.g or
		b ~= self.health.b
	then
		-- store the default colour
		self.health.r, self.health.g, self.health.b = r, g, b
		self.health.reset, self.friend = nil, nil
		
		if g > .9 and r == 0 and b == 0 then
			-- friendly NPC
			self.friend = true
			r, g, b = unpack(config.color[3])
		elseif b > .9 and r == 0 and g == 0 then
			-- friendly player
			self.friend = true
			r, g, b = 0, .3, .6
		elseif r > .9 and g == 0 and b == 0 then
			-- enemy NPC
			r, g, b = unpack(config.color[1])
		elseif (r + g) > 1.8 and b == 0 then
			-- neutral NPC
			r, g, b = unpack(config.color[2])
		end
			-- enemy player, use default UI colour
		
		self.health:SetStatusBarColor(r, g, b)
	end
end

local function SetGlowColour(self, r, g, b, a)
	if not r then
		-- set default colour
		r, g, b = 0, 0, 0
	end

	if not a then
		a = .85
	end
	
    -- self.bg:SetVertexColor(r, g, b, a)
    self.bg:SetBackdropBorderColor(r, g, b, a)
end

local function SetCastWarning(self, spellName, spellSchool)
	self.castWarning.ag:Stop()

	if	spellName == nil then
		-- hide the warning instantly when interrupted
		self.castWarning:SetAlpha(0)
	else
		local col = COMBATLOG_DEFAULT_COLORS.schoolColoring[spellSchool] or
			{r = 1, g = 1, b = 1}
	
		self.castWarning:SetText(spellName)
		self.castWarning:SetTextColor(col.r, col.g, col.b)
		self.castWarning:SetAlpha(1)
		
		self.castWarning.ag:Play()
	end
end

local function SetIncomingWarning(self, amount)
	if amount == 0 then return end
	self.incWarning.ag:Stop()

	if amount > 0 then
		-- healing
		amount = '+'..amount
		self.incWarning:SetTextColor(0, 1, 0)
	else
		-- damage (nyi)
		self.incWarning:SetTextColor(1, 0, 0)
	end

	self.incWarning:SetText(amount)

	self.incWarning:SetAlpha(1)
	self.incWarning.ag.fade:SetEndDelay(.5)
	
	self.incWarning.ag:Play()
end

-- Show the frame's castbar if it is casting
-- TODO update this for other units (party1target etc)
local function IsFrameCasting(self)
	if not self.castbar or not self.target then return end

	local name = UnitCastingInfo('target')
	local channel = false
	
	if not name then
		name = UnitChannelInfo('target')
		channel = true
	end
		
	if name then
		-- if they're casting or channeling, try to show a castbar
		nameplates.UNIT_SPELLCAST_START(self, 'target', channel)
	end
end

local function StoreFrameGUID(self, guid)
	if not guid then return end
	if self.guid and loadedGUIDs[self.guid] then
		if self.guid ~= guid then
			-- the currently stored guid is incorrect
			loadedGUIDs[self.guid] = nil
		else
			return
		end
	end
	
	self.guid = guid
	loadedGUIDs[guid] = self
	
	if loadedNames[self.name.text] == self then
		loadedNames[self.name.text] = nil
	end
end

--------------------------------------------------------- Update combo points --
local function ComboPointsUpdate(self)
	if self.points and self.points > 0 then
		local size = (13 + ((18 - 13) / 5) * self.points)
		local blue = (1 - (1 / 5) * self.points)
	
		self:SetText(self.points)
		self:SetFont(C.media.font, size, 'OUTLINE')
		self:SetTextColor(1, 1, blue)
	elseif self:GetText() then
		self:SetText('')
	end
end

----------------------------------------------------- Castbar script handlers --
local function OnCastbarUpdate(bar, elapsed)
	if bar.channel then
		bar.progress = bar.progress - elapsed
	else
		bar.progress = bar.progress + elapsed
	end
	
	if	not bar.duration or
		((not bar.channel and bar.progress >= bar.duration) or
		(bar.channel and bar.progress <= 0))
	then
		-- hide the castbar bg
		bar:GetParent():Hide()
		bar.progress = 0
		return
	end
	
	-- display progress
	if bar.max then
		bar.curr:SetText(string.format("%.1f", bar.progress))
		
		if bar.delay == 0 or not bar.delay then
			bar.max:SetText(string.format("%.1f", bar.duration))
		else
			-- display delay
			if bar.channel then
				-- time is removed
				bar.max:SetText(string.format("%.1f", bar.duration)..
					'|cffff0000-'..string.format("%.1f", bar.delay)..'|r')
			else
				-- time is added
				bar.max:SetText(string.format("%.1f", bar.duration)..
					'|cffff0000+'..string.format("%.1f", bar.delay)..'|r')
			end
		end
	end
	
	bar:SetValue(bar.progress/bar.duration)
end

---------------------------------------------------- Update health bar & text --
-- TODO: holy memory usage batman
local function OnHealthValueChanged(oldBar, curr)
	local frame	= oldBar:GetParent()
	local min, max	= oldBar:GetMinMaxValues()
	local big = format("%d%%", floor(curr / max * 100))
	
	frame.health:SetMinMaxValues(min, max)
	frame.health:SetValue(curr)
	
	frame.health.p:SetText(big)
end

------------------------------------------------------- Frame script handlers --
local function OnFrameShow(self)
	-- reset name
	self.name.text = self.oldName:GetText()
	self.name:SetText(self.name.text)
	
	-- classifications
	if self.boss:IsVisible() then
		self.level:SetText('??b')
		self.level:SetTextColor(1, 0, 0)
		self.level:Show()
	elseif self.state:IsVisible() then
		if self.state:GetTexture() == "Interface\\Tooltips\\EliteNameplateIcon"
		then
			self.level:SetText(self.level:GetText()..'+')
		else
			self.level:SetText(self.level:GetText()..'r')
		end
	end
	
	if self.state:IsVisible() then
		-- hide the elite/rare dragon
		self.state:Hide()
	end
	
	self:UpdateFrame()
	self:UpdateFrameCritical()
	
	self:SetGlowColour()
	self:IsCasting()
end

local function OnFrameHide(self)
	if self.guid then
		-- remove guid from the store and unset it
		loadedGUIDs[self.guid] = nil
		self.guid = nil
		
		if self.cp then
			self.cp.points = nil
			self.cp:Update()
		end
	end
	
	if loadedNames[self.name.text] == self then
		-- remove name from store
		-- if there are name duplicates, this will be recreated in an onupdate
		loadedNames[self.name.text] = nil
	end
	
	self.lastAlpha	= 0
	self.fadingTo	= nil
	self.hasThreat	= nil
	self.target		= nil
	
	-- unset stored health bar colours
	self.health.r, self.health.g, self.health.b, self.health.reset
		= nil, nil, nil, nil
	
	if self.castbar then
		-- reset cast bar
		self.castbar.duration = nil
		self.castbar.id = nil
		self.castbarbg:Hide()
	end
	
	if self.castWarning then
		-- reset cast warning
		self.castWarning:SetText()
		self.castWarning.ag:Stop()
		
		self.incWarning:SetText()
	end
end

local function OnFrameEnter(self)
	if self.highlight then
		self.highlight:Show()
	end

	self:StoreGUID(UnitGUID('mouseover'))
end

local function OnFrameLeave(self)
	if self.highlight then
		self.highlight:Hide()
	end
end

local function OnFrameUpdate(self, e)
	if PlateBlacklist[self.name:GetText()] then
		self:Hide()
		return
	end

	self.elapsed	= self.elapsed + e
	self.critElap	= self.critElap + e
	
	self.defaultAlpha = self:GetAlpha()
	------------------------------------------------------------------- Alpha --
	if self.currentAlpha and self.defaultAlpha ~= self.currentAlpha then
		-- ignore default UI's alpha changes
		self:SetAlpha(self.currentAlpha)
	end

	if	self.defaultAlpha == 1 and targetExists then
		self.currentAlpha = 1
	elseif	targetExists then
		self.currentAlpha = config.fadedalpha or .3
	else
		self.currentAlpha = 1
	end
	------------------------------------------------------------------ Fading --
	if config.fade then
		-- track changes in the alpha level and intercept them
		if self.currentAlpha ~= self.lastAlpha then
			if not self.fadingTo or self.fadingTo ~= self.currentAlpha then
				if nameplates.frameIsFading(self) then
					nameplates.frameFadeRemoveFrame(self)
				end
			
				-- fade to the new value
				self.fadingTo 		= self.currentAlpha
				local alphaChange	= (self.fadingTo - (self.lastAlpha or 0))
				
				nameplates.frameFade(self, {
					mode		= alphaChange < 0 and 'OUT' or 'IN',
					timeToFade	= abs(alphaChange) * (config.fadespeed or .5),
					startAlpha	= self.lastAlpha or 0,
					endAlpha	= self.fadingTo,
					finishedFunc = function()
						self.fadingTo = nil
					end,
				})
			end
			
			self.lastAlpha = self.currentAlpha
		end
	end
	
	-- call delayed updates
	if self.elapsed > 1 then
		self.elapsed = 0
		self:UpdateFrame()
	end
	
	if self.critElap > .1 then
		self.critElap = 0
		self:UpdateFrameCritical()
	end
end

-- stuff that can be updated less often
local function UpdateFrame(self)
	-- Health bar colour
	self:SetHealthColour()
	
	-- force health update (as self.friend is managed by SetHealthColour)
	OnHealthValueChanged(self.oldHealth, self.oldHealth:GetValue())
	
	if self.cp then
		-- combo points
		self.cp:Update()
	end
end

local function UpdateFrameCritical(self)
	self:SetHealthColour()
	------------------------------------------------------------ Target stuff --
	if	targetExists and self.defaultAlpha == 1 and self.name.text == UnitName('target') then
		-- this frame is targetted
		if not self.target then
			-- the frame just became targetted
			self.target = true
			self:StoreGUID(UnitGUID('target'))
			
			-- check if the frame is casting
			self:IsCasting()
		end
	elseif self.target then
		self.target = nil
	end
	--------------------------------------------------------------- Mouseover --
	if self.oldHighlight:IsShown() then
		if not self.highlighted then
			self.highlighted = true
			OnFrameEnter(self)
		end
	elseif self.highlighted then
		self.highlighted = false
		OnFrameLeave(self)
	end
end

--------------------------------------------------------------- KNP functions --
function nameplates:GetNameplate(guid, name)
	local gf, nf = loadedGUIDs[guid], loadedNames[name]

	if gf then
		return gf
	elseif nf then
		return nf
	else
		return nil
	end
end

function nameplates:IsNameplate(frame)
	if frame:GetName() and not string.find(frame:GetName(), "^NamePlate") then
		return false
	end
	
	local overlayRegion = select(2, frame:GetRegions())
    return (overlayRegion and
		overlayRegion:GetObjectType() == "Texture" and
		overlayRegion:GetTexture() == "Interface\\Tooltips\\Nameplate-Border")
end

function nameplates:InitFrame(frame)
	-- TODO: this is just a tad long
	frame.init = true

	local healthBar, castBar = frame:GetChildren()
	local _, castbarOverlay, shieldedRegion, spellIconRegion
		= castBar:GetRegions()
	
    local
		glowRegion, overlayRegion, highlightRegion, nameTextRegion,
		levelTextRegion, bossIconRegion, raidIconRegion, stateIconRegion
		= frame:GetRegions() 
    
	highlightRegion:SetTexture(nil)
	bossIconRegion:SetTexture(nil)
	shieldedRegion:SetTexture(nil)
	castbarOverlay:SetTexture(nil)
	glowRegion:SetTexture(nil)

	-- disable default cast bar
	castBar:SetParent(nil)
	castbarOverlay.Show = function() return end
	castBar:SetScript('OnShow', function() castBar:Hide() end)
	
	frame.bg	= overlayRegion
	frame.glow	= glowRegion
	frame.boss	= bossIconRegion
	frame.state	= stateIconRegion
	frame.level	= levelTextRegion
	
	if config.spellicon then
		frame.spell = spellIconRegion
	end
	
	frame.oldHealth = healthBar
	frame.oldHealth:Hide()
	
	frame.oldName = nameTextRegion
	frame.oldName:Hide()
	
	frame.oldHighlight = highlightRegion
	
    ---------------------------------------------------------- Frame functions--
    frame.UpdateFrame			= UpdateFrame
    frame.UpdateFrameCritical	= UpdateFrameCritical
    frame.SetHealthColour   	= SetHealthColour
    frame.SetGlowColour     	= SetGlowColour
	frame.IsCasting				= IsFrameCasting
	frame.StoreGUID				= StoreFrameGUID
    
    ------------------------------------------------------------------ Layout --
	-- health bar --------------------------------------------------------------
	-- size & point are set OnFrameShow
	frame.health = CreateFrame('StatusBar', nil, frame)
	frame.health:SetStatusBarTexture(C.media.normal)
	
	frame.health:SetWidth(110)
	frame.health:SetHeight(10)
	
	frame.health:ClearAllPoints()
	frame.health:SetPoint("CENTER")
	
	-- so i suppose I have to make sure it's in front of itself
	frame.health:SetFrameLevel(frame:GetFrameLevel()+1)
	
	-- frame background --------------------------------------------------------
	-- this also provides the shadow & threat glow
	frame.bg:SetTexture(nil)
	frame.bg = CreateFrame("Frame", nil, frame)
	if frame:GetFrameLevel() - 1 >0 then
		frame.bg:SetFrameLevel(frame:GetFrameLevel() - 1)
	else
		frame.bg:SetFrameLevel(0)
	end
	frame.bg:SetBackdrop({
		bgFile = C.media.blank,
		edgeFile = C.media.glow,
		edgeSize = 2*noscalemult,
		insets = {
			top = 2*noscalemult, left = 2*noscalemult, bottom = 2*noscalemult, right = 2*noscalemult
		}
	})
	frame.bg:SetPoint('TOPLEFT', frame.health, -3*noscalemult, 3*noscalemult)
	frame.bg:SetPoint('BOTTOMRIGHT', frame.health, 3*noscalemult, -3*noscalemult)
	frame.bg:SetBackdropColor(0, 0, 0, .85)

	-- overlay (text is parented to this) --------------------------------------
	frame.overlay = CreateFrame('Frame', nil, frame)
	frame.overlay:SetAllPoints(frame.health)
	
	frame.overlay:SetFrameLevel(frame.health:GetFrameLevel()+1)
	
	-- highlight ---------------------------------------------------------------
	if config.highlight then
		frame.highlight = frame.overlay:CreateTexture(nil, 'ARTWORK')
		frame.highlight:SetTexture(C.media.blank)
		
		frame.highlight:SetAllPoints(frame.health)
		
		frame.highlight:SetVertexColor(1, 1, 1)
		frame.highlight:SetAlpha(.2)
		frame.highlight:Hide()
	end
	
	-- health text -------------------------------------------------------------
	frame.health.p = nameplates.CreateFontString(frame.overlay, {
		font = C.media.font, size = 11, outline = "OUTLINE" })
	frame.health.p:SetJustifyH('RIGHT')
	
	frame.health.p:SetPoint('BOTTOMRIGHT', frame.health, 'TOPRIGHT', -2, -3)
	
	-- level text --------------------------------------------------------------
	frame.level = nameplates.CreateFontString(frame.level, { reset = true,
		font = C.media.font, size = 9, outline = 'OUTLINE' })
	frame.level:SetParent(frame.overlay)
	
	frame.level:ClearAllPoints()
	frame.level:SetPoint('BOTTOMLEFT', frame.health, 'TOPLEFT', 2, -3)

	-- name text ---------------------------------------------------------------
	frame.name = nameplates.CreateFontString(frame.overlay, {
		font = C.media.font, size = 9, outline = 'OUTLINE' })
	frame.name:SetJustifyH('LEFT')

	frame.name:SetHeight(8)

	frame.name:SetPoint('LEFT', frame.level, 'RIGHT', -2, 0)
	frame.name:SetPoint('RIGHT', frame.health.p, 'LEFT')
	
	-- combo point text --------------------------------------------------------
	if config.combopoints then
		frame.cp = nameplates.CreateFontString(frame.health,
			{ font = C.media.font, size = 13, outline = 'OUTLINE', shadow = true })
		frame.cp:SetPoint('LEFT', frame.health, 'RIGHT', 5, 1)
		
		frame.cp.Update = ComboPointsUpdate
	end
	
	if not frame.icons then
		frame.icons = CreateFrame("Frame",nil,frame)
		frame.icons:SetPoint("BOTTOMRIGHT",frame.health,"TOPRIGHT", 0, 5)
		frame.icons:SetPoint("BOTTOMLEFT",frame.health,"TOPLEFT", 0, 5)
		frame.icons:SetHeight(25)
		frame.icons:SetFrameLevel(frame.health:GetFrameLevel()+2)
	end
	
	-- TODO move this (and similar things) into functions
	-- cast bar background -------------------------------------------------
	frame.castbarbg = CreateFrame("Frame", nil, frame)
	frame.castbarbg:SetFrameStrata('BACKGROUND');
	frame.castbarbg:SetBackdrop({
		bgFile = C.media.blank,
		edgeFile = C.media.glow,
		edgeSize = 5*noscalemult,
		insets = {
			top = 5*noscalemult, left = 5*noscalemult, bottom = 5*noscalemult, right = 5*noscalemult
		}
	})
	
	frame.castbarbg:SetBackdropColor(0, 0, 0, .85)
	frame.castbarbg:SetBackdropBorderColor(0, 0, 0, .85)
	frame.castbarbg:SetHeight(15)
	
	frame.castbarbg:SetPoint('TOPLEFT', frame.bg, 'BOTTOMLEFT', -3*noscalemult, 4*noscalemult)
	frame.castbarbg:SetPoint('TOPRIGHT', frame.bg, 'BOTTOMRIGHT', 3*noscalemult, 0)
	
	frame.castbarbg:Hide()
	
	-- cast bar ------------------------------------------------------------
	frame.castbar = CreateFrame("StatusBar", nil, frame.castbarbg)
	frame.castbar:SetStatusBarTexture(C.media.normal)		
	
	frame.castbar:SetPoint('TOPLEFT', frame.castbarbg, 'TOPLEFT', 6*noscalemult, -6*noscalemult)
	frame.castbar:SetPoint('BOTTOMLEFT', frame.castbarbg, 'BOTTOMLEFT', 6*noscalemult, 6*noscalemult)
	frame.castbar:SetPoint('RIGHT', frame.castbarbg, 'RIGHT', -6*noscalemult, 0)
	
	frame.castbar:SetMinMaxValues(0, 1)

	-- cast bar text -------------------------------------------------------
	if config.spellname then
		frame.castbar.name = nameplates.CreateFontString(frame.castbar, {
			font = C.media.font, size = 9, outline = "OUTLINE" })
		frame.castbar.name:SetPoint('TOPLEFT', frame.castbar, 'BOTTOMLEFT', 2, -1)
	end
	
	if config.casttime then
		frame.castbar.max = nameplates.CreateFontString(frame.castbar, {
			font = C.media.font, size = 9, outline = "OUTLINE" })
		frame.castbar.max:SetPoint('TOPRIGHT', frame.castbar, 'BOTTOMRIGHT', -2, -1)

		frame.castbar.curr = nameplates.CreateFontString(frame.castbar, {
			font = C.media.font, size = 8, outline = "OUTLINE" })
		frame.castbar.curr:SetAlpha(.5)
		frame.castbar.curr:SetPoint('TOPRIGHT', frame.castbar.max, 'TOPLEFT', -1, -1)
	end

	if frame.spell then
		-- cast bar icon background ----------------------------------------
		-- frame.spellbg = frame.castbarbg:CreateTexture(nil, 'BACKGROUND')
		-- frame.spellbg:SetTexture(C.media.blank)
		frame.spellbg = CreateFrame("Frame", nil, frame.castbarbg)
		frame.spellbg:SetFrameLevel(0)
		frame.spellbg:SetBackdrop({
			bgFile = C.media.blank,
			edgeFile = C.media.glow,
			edgeSize = 2*noscalemult,
			insets = {
				top = 2*noscalemult, left = 2*noscalemult, bottom = 2*noscalemult, right = 2*noscalemult
			}
		})
		frame.spellbg:SetSize(24, 24)
		frame.spellbg:SetBackdropColor(0, 0, 0, .85)
		frame.spellbg:SetBackdropBorderColor(0, 0, 0, .85)
		frame.spellbg:SetPoint('TOPRIGHT', frame.bg, 'TOPLEFT', -noscalemult, 0)
		
		-- cast bar icon ---------------------------------------------------
		frame.spell:ClearAllPoints()
		frame.spell:SetParent(frame.castbarbg)
		
		frame.spell:SetPoint('TOPLEFT', frame.spellbg, 'TOPLEFT', 3*noscalemult, -3*noscalemult)
		frame.spell:SetPoint('BOTTOMRIGHT', frame.spellbg, 'BOTTOMRIGHT', -3*noscalemult, 3*noscalemult)
		
		frame.spell:SetTexCoord(.08, .92, .08, .92)
	end
	
	-- scripts -------------------------------------------------------------
	frame.castbar:HookScript('OnShow', function(bar)
		if bar.interruptible then
			bar:SetStatusBarColor(unpack(config.castbarcolor))
			bar:GetParent():SetBackdropBorderColor(0, 0, 0, .85)
		else
			bar:SetStatusBarColor(.8, .1, .1)			
			bar:GetParent():SetBackdropBorderColor(1, .1, .2, .5)
		end
	end)

	frame.castbar:SetScript('OnUpdate', OnCastbarUpdate)
    
    ----------------------------------------------------------------- Scripts --
	frame:SetScript('OnShow', OnFrameShow)
	frame:SetScript('OnHide', OnFrameHide)
    frame:SetScript('OnUpdate', OnFrameUpdate)
	
	frame.oldHealth:SetScript('OnValueChanged', OnHealthValueChanged)

	------------------------------------------------------------ Finishing up --
    frame.elapsed	= 0
	frame.critElap	= 0
	
	-- force OnShow
	OnFrameShow(frame)
end

---------------------------------------------------------------------- Events --
function nameplates:UNIT_COMBO_POINTS()
	local target = UnitGUID('target')
	if not target or not loadedGUIDs[target] then return end
	target = loadedGUIDs[target]
	
	if target.cp then
		target.cp.points = GetComboPoints('player', 'target')
		target.cp:Update()	
	end
	
	-- clear points on other frames
	for guid, frame in pairs(loadedGUIDs) do
		if frame.cp and guid ~= target.guid then
			frame.cp.points = nil
			frame.cp:Update()
		end
	end
end

-- custom cast bar events ------------------------------------------------------
function nameplates.UNIT_SPELLCAST_START(frame, unit, channel)
	local cb = frame.castbar
	local	
		name, _, text, texture, startTime, endTime, _, castID,
		notInterruptible
		
	if channel then
		name, _, text, texture, startTime, endTime, _, castID, notInterruptible
			= UnitChannelInfo(unit)
	else
		name, _, text, texture, startTime, endTime, _, castID, notInterruptible
			= UnitCastingInfo(unit)
	end
	
	if not name then
		frame.castbarbg:Hide()
		return
	end

	cb.id 				= castID
	cb.channel			= channel
	cb.interruptible 	= not notInterruptible
	cb.duration			= (endTime/1000) - (startTime/1000)
	cb.delay			= 0
	
	if frame.spell then
		frame.spell:SetTexture(texture)
	end
	
	if cb.name then
		cb.name:SetText(name)
	end
	
	if cb.channel then
		cb.progress	= (endTime/1000) - GetTime()
	else
		cb.progress	= GetTime() - (startTime/1000)
	end
	
	frame.castbarbg:Show()
end

function nameplates.UNIT_SPELLCAST_DELAYED(frame, unit, channel)
	local cb = frame.castbar
	local _, name, startTime, endTime
	
	if channel then
		name, _, _, _, startTime, endTime = UnitChannelInfo(unit)
	else
		name, _, _, _, startTime, endTime = UnitCastingInfo(unit)
	end
	
	if not name then
		return
	end
	
	local newProgress
	if cb.channel then
		newProgress	= (endTime/1000) - GetTime()
	else
		newProgress	= GetTime() - (startTime/1000)
	end
	
	cb.delay = (cb.delay or 0) + cb.progress - newProgress
	cb.progress = newProgress
end

function nameplates.UNIT_SPELLCAST_CHANNEL_START(frame, unit)
	nameplates.UNIT_SPELLCAST_START(frame, unit, true)
end

function nameplates.UNIT_SPELLCAST_CHANNEL_UPDATE(frame, unit)
	nameplates.UNIT_SPELLCAST_DELAYED(frame, unit, true)
end

function nameplates.UNIT_SPELLCAST_STOP(frame, unit)
	frame.castbarbg:Hide()
end

function nameplates.UNIT_SPELLCAST_FAILED(frame, unit)
	frame.castbarbg:Hide()
end

function nameplates.UNIT_SPELLCAST_INTERRUPTED(frame, unit)
	frame.castbarbg:Hide()
end

function nameplates.UNIT_SPELLCAST_CHANNEL_STOP(frame, unit)
	frame.castbarbg:Hide()
end

local function CreateAuraIcon(parent)
	local button = CreateFrame("Frame",nil,parent)
	button:SetWidth(20)
	button:SetHeight(20)

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
	button.cd:SetScript("OnUpdate", function(self)
		if not button.cd.timer then
			self:SetScript("OnUpdate", nil)
			return
		end
		button.cd.timer.text:SetFont(C["media"].font,11,C["media"].fontflag)
		button.cd.timer.text:SetShadowColor(0, 0, 0, 0.4)
	end)
	button:Show()
end

function nameplates:UNIT_AURA(unit)
	if unit == 'player' then return end
	local guid, name, frame = UnitGUID(unit), GetUnitName(unit), nil
	frame = nameplates:GetNameplate(guid, name)
	if not frame or not frame.icons then return end

	local i = 1
	for index = 1, BUFF_MAX_DISPLAY do
		if i > 5 then return end
		local match
		local name,_,_,_,_,duration,_,caster,_,_,spellid = UnitAura(unit,index,"HARMFUL")
		
		if caster == "player" then match = true end
		if DebuffWhiteList[name] then match = true end
		
		if duration and match == true then
			if not frame.icons[i] then frame.icons[i] = CreateAuraIcon(frame) end
			local icon = frame.icons[i]
			if i == 1 then icon:SetPoint("RIGHT",frame.icons,"RIGHT") end
			if i ~= 1 and i <= 5 then icon:SetPoint("RIGHT", frame.icons[i-1], "LEFT", -2, 0) end
			i = i + 1
			UpdateAuraIcon(icon, unit, index, "HARMFUL")
		end
	end
	for index = i, #frame.icons do frame.icons[index]:Hide() end
end

function nameplates:COMBAT_LOG_EVENT_UNFILTERED(_, event, ...)
	if event == "SPELL_AURA_REMOVED" then
		local _, sourceGUID, _, _, _, destGUID, _, _, _, spellID = ...
		
		if sourceGUID == UnitGUID("player") then
			local f = loadedGUIDs[destGUID]
			if not f then return end
			for _,icon in ipairs(f.icons) do 
				if icon.spellID == spellID then 
					icon:Hide() 
				end 
			end
		end
	end
end

-- custom cast bar event handler -----------------------------------------------
local function UnitCastEvent(event, unit, ...)
	if unit == 'player' then return end
	local guid, name, f = UnitGUID(unit), GetUnitName(unit), nil
	--guid, name = UnitGUID('target'), GetUnitName('target')
	
	-- fetch the unit's nameplate
	f = nameplates:GetNameplate(guid, name)
	if f then
		if not f.castbar then return end
		if	event == 'UNIT_SPELLCAST_STOP' or
			event == 'UNIT_SPELLCAST_FAILED' or
			event == 'UNIT_SPELLCAST_INTERRUPTED'
		then
			-- these occasionally fire after a new _START
			local _, _, castID = ...
			if f.castbar.id ~= castID then
				return
			end
		end
		
		nameplates[event](f, unit)
	end
end

local WorldFrame = WorldFrame

nameplates.frames = 0
local function OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 1) + elapsed	
	
	if self.elapsed >= .1 then
		local i, f, frames
		frames = select('#', WorldFrame:GetChildren())
		
		if frames ~= nameplates.frames then
			for i = 1, frames do
				f = select(i, WorldFrame:GetChildren())

				if self:IsNameplate(f) and not f.init then
					self:InitFrame(f)
				end
			end
			
			nameplates.frames = frames
		end		
		self.elapsed = 0
	end
end

nameplates:RegisterEvent('UNIT_SPELLCAST_START')
nameplates:RegisterEvent('UNIT_SPELLCAST_FAILED')
nameplates:RegisterEvent('UNIT_SPELLCAST_STOP')
nameplates:RegisterEvent('UNIT_SPELLCAST_INTERRUPTED')
nameplates:RegisterEvent('UNIT_SPELLCAST_DELAYED')
nameplates:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START')
nameplates:RegisterEvent('UNIT_SPELLCAST_CHANNEL_UPDATE')
nameplates:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP')

nameplates:RegisterEvent('PLAYER_TARGET_CHANGED')
nameplates:RegisterEvent('PLAYER_ENTERING_WOLRD')
nameplates:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
nameplates:RegisterEvent('UNIT_COMBO_POINTS')
nameplates:RegisterEvent('UNIT_AURA')

nameplates:SetScript('OnUpdate', OnUpdate)

nameplates:SetScript('OnEvent', function(self, event, ...)
	if event == "PLAYER_ENTERING_WOLRD" then
		self:UnregisterEvent("PLAYER_ENTERING_WOLRD")
		SetCVar("threatWarning", 3)
		SetCVar("bloatthreat", 0)
		SetCVar("bloattest", 1)
		SetCVar("bloatnameplates", 0)
	elseif event == "PLAYER_TARGET_CHANGED" then
		targetExists = UnitExists('target')
	elseif event == "UNIT_COMBO_POINTS" then
		self:UNIT_COMBO_POINTS()
	elseif event == "UNIT_AURA" then
		self:UNIT_AURA(...)
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		nameplates:COMBAT_LOG_EVENT_UNFILTERED(...)
	else
		UnitCastEvent(event, ...)
	end
end)