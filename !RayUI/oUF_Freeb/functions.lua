local R, C, DB = unpack(select(2, ...))

local ADDON_NAME, ns = ...
local oUF = oUF_Freeb or ns.oUF or oUF

local buttonTex = "Interface\\AddOns\\!RayUI\\media\\buttontex"
local height, width = 22, 240
local scale = 1.0
local hpheight = .85 -- .70 - .90 

local auraborders = false

local onlyShowPlayer = false -- only show player debuffs on target

local pixelborder = false

local createFont = function(parent, layer, font, fontsiz, thinoutline, r, g, b, justify)
    local string = parent:CreateFontString(nil, layer)
    string:SetFont(font, fontsiz, thinoutline)
    string:SetShadowOffset(0.625, -0.625)
    string:SetTextColor(r, g, b)
    if justify then
        string:SetJustifyH(justify)
    end

    return string
end

function R.multicheck(check, ...)
    for i=1, select('#', ...) do
        if check == select(i, ...) then return true end
    end
    return false
end

local backdrop = {
    bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
    insets = {top = 0, left = 0, bottom = 0, right = 0},
}

local backdrop2 = {
    bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
    insets = {top = -R.mult, left = -R.mult, bottom = -R.mult, right = -R.mult},
}

local frameBD = {
    edgeFile = C["media"].glow, edgeSize = R.Scale(5),
    bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
    insets = {left = R.Scale(3), right = R.Scale(3), top = R.Scale(3), bottom = R.Scale(3)}
}

function R.createBackdrop(parent, anchor) 
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetFrameStrata("LOW")

    if pixelborder then
        frame:SetAllPoints(anchor)
        frame:SetBackdrop(backdrop2)
    else
        frame:Point("TOPLEFT", anchor, "TOPLEFT", -4, 4)
        frame:Point("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 4, -4)
        frame:SetBackdrop(frameBD)
    end

    frame:SetBackdropColor(0, 0, 0, 0.8)
    frame:SetBackdropBorderColor(0, 0, 0)

    return frame
end

function R.FocusText(self)
	local focusdummy = CreateFrame("BUTTON", "focusdummy", self, "SecureActionButtonTemplate")
	focusdummy:SetFrameStrata("HIGH")
	focusdummy:SetWidth(50)
	focusdummy:SetHeight(25)
	focusdummy:Point("TOP", self,0,0)
	focusdummy:EnableMouse(true)
	focusdummy:RegisterForClicks("AnyUp")
	focusdummy:SetAttribute("type", "macro")
	focusdummy:SetAttribute("macrotext", "/focus")
	focusdummy:SetBackdrop({
		bgFile =  [=[Interface\ChatFrame\ChatFrameBackground]=],
        edgeFile = "Interface\\Buttons\\WHITE8x8",
		edgeSize = 1,
		insets = {
			left = 0,
			right = 0,
			top = 0,
			bottom = 0
		}
	})
	focusdummy:SetBackdropColor(.1,.1,.1,0)
	focusdummy:SetBackdropBorderColor(0,0,0,0)

	focusdummytext = focusdummy:CreateFontString(self,"OVERLAY")
	focusdummytext:Point("CENTER", self,0,0)
	focusdummytext:SetFont(C["media"].font, C["media"].fontsize, C["media"].fontflag)
	focusdummytext:SetText("焦点")
	focusdummytext:SetVertexColor(1,0.2,0.1,0)

	focusdummy:SetScript("OnLeave", function(self) focusdummytext:SetVertexColor(1,0.2,0.1,0) end)
	focusdummy:SetScript("OnEnter", function(self) focusdummytext:SetTextColor(.6,.6,.6) end)	
end

function R.ClearFocusText(self)
	local clearfocus = CreateFrame("BUTTON", "focusdummy", self, "SecureActionButtonTemplate")
	clearfocus:SetFrameStrata("HIGH")
	clearfocus:SetWidth(30)
	clearfocus:SetHeight(20)
	clearfocus:Point("TOP", self,0, 0)
	clearfocus:EnableMouse(true)
	clearfocus:RegisterForClicks("AnyUp")
	clearfocus:SetAttribute("type", "macro")
	clearfocus:SetAttribute("macrotext", "/clearfocus")
	
	clearfocus:SetBackdrop({
		bgFile =  [=[Interface\ChatFrame\ChatFrameBackground]=],
        edgeFile = "Interface\\Buttons\\WHITE8x8",
		edgeSize = 1,
		insets = {
			left = 0,
			right = 0,
			top = 0,
			bottom = 0
		}
	})
	clearfocus:SetBackdropColor(.1,.1,.1,0)
	clearfocus:SetBackdropBorderColor(0,0,0,0)

	clearfocustext = clearfocus:CreateFontString(self,"OVERLAY")
	clearfocustext:Point("CENTER", self,0,0)
	clearfocustext:SetFont(C["media"].font, C["media"].fontsize, C["media"].fontflag)
	clearfocustext:SetText("取消焦点")
	clearfocustext:SetVertexColor(1,0.2,0.1,0)

	clearfocus:SetScript("OnLeave", function(self) clearfocustext:SetVertexColor(1,0.2,0.1,0) end)
	clearfocus:SetScript("OnEnter", function(self) clearfocustext:SetTextColor(.6,.6,.6) end)
end

local formatTime = function(s)
	local day, hour, minute = 86400, 3600, 60
	if s >= day then
		return format("%dd", floor(s/day + 0.5)), s % day
	elseif s >= hour then
		return format("%dh", floor(s/hour + 0.5)), s % hour
	elseif s >= minute then
		return format("%dm", floor(s/minute + 0.5)), s % minute
	elseif s >= minute / 12 then
		return floor(s + 0.5), (s * 100 - floor(s * 100))/100
	end
	-- return format("%.1f", s), (s * 100 - floor(s * 100))/100
	return format("%d", s), (s * 100 - floor(s * 100))/100
end

local setTimer = function (self, elapsed)
	if self.timeLeft then
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= 0.1 then
			if not self.first then
				self.timeLeft = self.timeLeft - self.elapsed
			else
				self.timeLeft = self.timeLeft - GetTime()
				self.first = false
			end
			if self.timeLeft > 0 then
				local time = formatTime(self.timeLeft)
					self.time:SetText(time)
				if self.timeLeft < 5 then
					self.time:SetTextColor(1, 0, 0)
				elseif self.timeLeft<60 then
					self.time:SetTextColor(1, 1, 0)
				else
					self.time:SetTextColor(1, 1, 1)
				end
			else
				self.time:Hide()
				self:SetScript("OnUpdate", nil)
			end
			self.elapsed = 0
		end
	end
end

function R.postCreateIcon(element, button)
	local unit = button:GetParent():GetParent().unit
	element.disableCooldown = true
	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	
	-- local h = CreateFrame("Frame", nil, button)
	-- h:SetFrameLevel(0)
	-- h:Point("TOPLEFT",-2,2)
	-- h:Point("BOTTOMRIGHT",2,-2)
	-- h:CreateShadow()
	button.bg = R.createBackdrop(button, button)
	local time = button:CreateFontString(nil, "OVERLAY")
	if unit == "focus" then
		time:SetFont(C["media"].font, 16, "OUTLINE")
	else
		time:SetFont(C["media"].font, 22, "OUTLINE")
	end
    time:SetShadowColor(0,0,0,1)
    time:SetShadowOffset(0.5,-0.5)
	local count = button:CreateFontString(nil, "OVERLAY")
	if unit == "focus" then
		count:SetFont(C["media"].font, 12, "OUTLINE")
	else
		count:SetFont(C["media"].font, 18, "OUTLINE")
    end
	count:SetShadowColor(0,0,0,1)
    count:SetShadowOffset(0.5,-0.5)
	time:Point("CENTER", button, "CENTER", 2, 0)
	time:SetJustifyH("CENTER")
	time:SetVertexColor(1,1,1)
	button.time = time
	count:Point("CENTER", button, "BOTTOMRIGHT", 0, 3)
	count:SetJustifyH("RIGHT")
	button.count = count
	button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	button.icon:SetDrawLayer("ARTWORK")
end

function R.postUpdateIcon(element, unit, button, index)
	local name, _, _, _, dtype, duration, expirationTime, unitCaster, isStealable = UnitAura(unit, index, button.filter)
	
	if duration and duration > 0 then
		button.time:Show()
		button.timeLeft = expirationTime	
		button:SetScript("OnUpdate", setTimer)			
	else
		button.time:Hide()
		button.timeLeft = math.huge
		button:SetScript("OnUpdate", nil)
	end

	if(button.debuff) then
		if(unit == "target") then	
			if (unitCaster == "player" or unitCaster == "vehicle") then
				button.icon:SetDesaturated(false)                 
			elseif(not UnitPlayerControlled(unit)) then -- If Unit is Player Controlled don"t desaturate debuffs
				button:SetBackdropColor(0, 0, 0)
				button.overlay:SetVertexColor(0.3, 0.3, 0.3)      
				button.icon:SetDesaturated(true)  
			end
		end
		button.bg:SetBackdropBorderColor(0, 0, 0)
	else
		if (isStealable or ((R.myclass == "PRIEST" or R.myclass == "SHAMAN" or R.myclass == "MAGE") and dtype == "Magic")) and not UnitIsFriend("player", unit) then
			button.bg:SetBackdropBorderColor(78/255, 150/255, 222/255)
		else
			button.bg:SetBackdropBorderColor(0, 0, 0)
		end
	end
	button:SetScript('OnMouseUp', function(self, mouseButton)
		if mouseButton == 'RightButton' then
			CancelUnitBuff('player', index)
	end end)
	button.first = true
end

function R.postCreateIconSmall(auras, button)
    local count = button.count
    count:ClearAllPoints()
    count:Point("TOPLEFT", -4, 2)
    count:SetFontObject(nil)
    count:SetFont(C["media"].font, 13, "THINOUTLINE")
    count:SetTextColor(.8, .8, .8)

    auras.disableCooldown = true

    button.icon:SetTexCoord(.1, .9, .1, .9)
    button.bg = R.createBackdrop(button, button)
	
    if auraborders then
        auras.showDebuffType = true
        button.overlay:SetTexture(buttonTex)
        button.overlay:Point("TOPLEFT", button, "TOPLEFT", -2, 2)
        button.overlay:Point("TOPLEFT", button, "TOPLEFT", 2, -2)
        button.overlay:SetTexCoord(0, 1, 0.02, 1)
    else
        button.overlay:Hide()
    end

    local remaining = createFont(button, "OVERLAY", C["media"].font, 13, "THINOUTLINE", 0.99, 0.99, 0.99)
    remaining:Point("BOTTOMRIGHT", 4, -4)
    button.remaining = remaining
end

local CreateAuraTimer = function(self,elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed

    if self.elapsed < .2 then return end
    self.elapsed = 0

    local timeLeft = self.expires - GetTime()
    if timeLeft <= 0 then
        return
    else
        self.remaining:SetText(formatTime(timeLeft))
    end
end

local playerUnits = {
	player = true,
	pet = true,
	vehicle = true,
}

function R.postUpdateIconSmall(icons, unit, icon, index, offset)
	local name, _, _, _, dtype, duration, expirationTime, unitCaster = UnitAura(unit, index, icon.filter)

	local texture = icon.icon
	if playerUnits[icon.owner] or UnitIsFriend('player', unit) or not icon.debuff then
		texture:SetDesaturated(false)
	else
		texture:SetDesaturated(true)
	end

	if duration and duration > 0 then
		icon.remaining:Show()
	else
		icon.remaining:Hide()
	end

	--[[if icon.debuff then
	icon.bg:SetBackdropBorderColor(.4, 0, 0)
	else
	icon.bg:SetBackdropBorderColor(0, 0, 0)
	end]]

	icon.duration = duration
	icon.expires = expirationTime
	icon:SetScript("OnUpdate", CreateAuraTimer)
end


function R.CustomFilter(icons, unit, icon, name, _, _, _, _, _, _, caster)
	local auraname, _, _, _, dtype, duration, expirationTime, unitCaster, isStealable, _, spellID = UnitAura(unit, name)
	if(not UnitBuff(unit, name)) then
		local isPlayer

		if R.multicheck(caster, 'player', 'vechicle', 'pet') then
			isPlayer = true
		end

		if((icons.onlyShowPlayer and isPlayer and (not R.DebuffBlackList[name])) or (not icons.onlyShowPlayer and name and (not R.DebuffBlackList[name]))) then
			icon.isPlayer = isPlayer
			icon.owner = caster
			return true
		else
			return false
		end
	else
		if (isStealable or ((R.myclass == "PRIEST" or R.myclass == "SHAMAN" or R.myclass == "MAGE") and dtype == "Magic")) and not UnitIsFriend("player", unit) then
			return true
		elseif UnitIsFriend("player", unit) then
			return true
		else
			return false
		end
	end
	
	-- if buffexist and not UnitCanAttack("player",unit) then
		-- return true
	-- end
		
	--Only Show Stealable
	-- if buffexist and UnitCanAttack("player",unit) and isStealable then
		-- return true
	-- end
	
end

function R.CustomBuffFilter(icons, ...)
    local unit, icon, name, _, _, _, _, _, _, caster = ...
	if R.BuffWhiteList[R.myclass][name] then
		return true
	else
		return false
	end
end

function R.Portrait(frame)
	local portrait = CreateFrame("PlayerModel", nil, frame)
	portrait.PostUpdate = function(frame) 
											portrait:SetAlpha(0.15) 
											if frame:GetModel() and frame:GetModel().find and frame:GetModel():find("worgenmale") then
												frame:SetCamera(1)
											end	
										end
	portrait:SetAllPoints(frame.Health)
	table.insert(frame.__elements, HidePortrait)
	frame.Portrait = portrait
end

function R.Update_Common(frame)
	frame.Health.colorClass = nil
	frame.Health.colorReaction = nil
	frame.Health.colorTapping = nil
	frame.Health.colorDisconnected = nil
	if C["ouf"].HealthcolorClass then
        frame.Health.colorClass = true
        frame.Health.colorReaction = true
		frame.Health.colorTapping = true
		frame.Health.colorDisconnected = true
        frame.Health.bg.multiplier = .2
    else
		frame.Health:SetStatusBarColor(.1, .1, .1, 1)
        frame.Health.bg:SetVertexColor(1,1,1,.6)
    end
	if frame.Power then
		frame.Power.colorClass = nil
		frame.Power.colorPower = nil
		if C["ouf"].Powercolor then
			frame.Power.colorClass = true
			frame.Power.bg.multiplier = .2
		else
			frame.Power.colorPower = true
			frame.Power.bg.multiplier = .2
		end
	end
	frame:SetScale(C["ouf"].scale)
	frame:UpdateAllElements()
end

function R.Update_Player(frame)
	if C["ouf"].showPortrait then
		if not frame:IsElementEnabled('Portrait') then
			R.Portrait(frame)
			frame:EnableElement('Portrait')
			frame.Portrait:Show()
		end
	else
		if frame:IsElementEnabled('Portrait') then
			frame:DisableElement('Portrait')
			frame.Portrait:Hide()
		end		
	end
	if frame.Buffs then 
		frame.Buffs:ClearAllPoints() 
		frame.Buffs:Hide()
		frame.Buffs = nil
	end
	if frame.Debuffs then 
		frame.Debuffs:ClearAllPoints()
		frame.Debuffs:Hide()
		frame.Debuffs = nil
	end
	if frame.Auras then 
		frame.Auras:ClearAllPoints()
		frame.Auras:Hide()
		frame.Auras = nil
	end
	if frame:IsElementEnabled('Aura') then
		frame:DisableElement('Aura')
	end		
	if C["ouf"].PlayerBuffFilter then
		local _, class = UnitClass("player")
		local b = CreateFrame("Frame", nil, frame)
		b.size = 30
		b.num = 14
		b.spacing = 4.8
		if R.multicheck(class, "DEATHKNIGHT", "WARLOCK", "PALADIN", "SHAMAN") then
			b:Point("BOTTOMRIGHT", frame,  "TOPRIGHT", 0, 10)
		else
			b:Point("BOTTOMRIGHT", frame,  "TOPRIGHT", 0, 5)
		end
		b.initialAnchor = "BOTTOMRIGHT"
		b["growth-x"] = "LEFT"
		b["growth-y"] = "UP"
		b:SetHeight((b.size+b.spacing)*4)
		b:SetWidth(frame:GetWidth())
		b.CustomFilter = R.CustomBuffFilter
		b.PostCreateIcon = R.postCreateIcon
		b.PostUpdateIcon = R.postUpdateIcon

		frame.Buffs = b
		frame:EnableElement('Aura')
	end
	if R.TableIsEmpty(R.SavePath["UFPos"]["Freeb - Player"]) then
		if C["ouf"].HealFrames and R.isHealer then
			frame:ClearAllPoints()
			frame:Point("BOTTOM", -350, 350)
			frame.Castbar:ClearAllPoints()
			frame.Castbar:Point("TOP", frame, "BOTTOM", 0, -35)
			frame.Castbar:Width(frame:GetWidth())
			frame.Castbar:Height(10)
		else
			frame:ClearAllPoints()
			frame:Point("BOTTOM", -300, 450)
			frame.Castbar:ClearAllPoints()
			frame.Castbar:Point("BOTTOM", UIParent, "BOTTOM", 0, 305)
			frame.Castbar:Width(rABS_MainMenuBar:GetWidth())
			frame.Castbar:Height(5)
		end
	end
	R.Update_Common(frame)
	frame:UpdateAllElements()
end

function R.Update_Target(frame)
	if C["ouf"].showPortrait then
		if not frame:IsElementEnabled('Portrait') then
			R.Portrait(frame)
			frame:EnableElement('Portrait')
			frame.Portrait:Show()
		end
	else
		if frame:IsElementEnabled('Portrait') then
			frame:DisableElement('Portrait')
			frame.Portrait:Hide()
		end		
	end
	if frame.Buffs then 
		frame.Buffs:ClearAllPoints() 
		frame.Buffs:Hide()
		frame.Buffs = nil
	end
	if frame.Debuffs then 
		frame.Debuffs:ClearAllPoints()
		frame.Debuffs:Hide()
		frame.Debuffs = nil
	end
	if frame.Auras then 
		frame.Auras:ClearAllPoints()
		frame.Auras:Hide()
		frame.Auras = nil
	end
	if frame:IsElementEnabled('Aura') then
		frame:DisableElement('Aura')
	end		
	if (C["ouf"].HealFrames and R.isHealer) or not C["ouf"].DebuffOnyshowPlayer then
		local debuffs = CreateFrame("Frame", nil, frame)
		debuffs:SetHeight(height)
		debuffs:SetWidth(245)
		debuffs.initialAnchor = "BOTTOMLEFT"
		debuffs.spacing = 5
		debuffs.num = 9
		debuffs["growth-x"] = "RIGHT"
		debuffs["growth-y"] = "DOWN"
		debuffs:Point("TOPLEFT", frame, "BOTTOMLEFT", 0, 50)
		debuffs.size = height

		debuffs.PostCreateIcon = R.postCreateIconSmall
		debuffs.PostUpdateIcon = R.postUpdateIconSmall

		frame.Debuffs = debuffs

		local buffs = CreateFrame("Frame", nil, frame)
		buffs:SetHeight(height+1)
		buffs:SetWidth(190)
		buffs:Point("LEFT", frame, "RIGHT", 5, 0)
		buffs.spacing = 4
		buffs["growth-x"] = "RIGHT"
		buffs["growth-y"] = "DOWN"
		buffs.size = height
		buffs.initialAnchor = "TOPLEFT"
		buffs.onlyShowPlayer = onlyShowPlayer

		buffs.PostCreateIcon = R.postCreateIconSmall
		buffs.PostUpdateIcon = R.postUpdateIconSmall

		frame.Buffs = buffs
		frame.Buffs.num = 32
		frame:EnableElement('Aura')
		
		frame.Castbar:ClearAllPoints()
		frame.Castbar:Point("TOP", frame, "BOTTOM", 0, -35)
		frame.Castbar:Width(frame:GetWidth())
		frame.Castbar:Height(10)
	else
		Auras = CreateFrame("Frame", nil, frame)
		Auras:SetHeight(42)
		Auras:SetWidth(frame:GetWidth())
		Auras.initialAnchor = "BOTTOMLEFT"
		Auras["growth-x"] = "RIGHT"		
		Auras["growth-y"] = "DOWN"
		Auras.numBuffs = 24
		Auras.numDebuffs = 10
		Auras.size = 18
		Auras.spacing = 4.8
		Auras["growth-y"] = "UP"
		Auras.size = 30
		Auras.onlyShowPlayer = true
		Auras.CustomFilter = R.CustomFilter			
		Auras:Point("BOTTOMLEFT", frame, "TOPLEFT", 0, 5)
		Auras.gap = true
		Auras.PostCreateIcon = R.postCreateIcon
		Auras.PostUpdateIcon = R.postUpdateIcon
		frame.Auras = Auras
		frame:EnableElement('Aura')
		
		frame:Point("BOTTOM", -300, 450)
		frame.Castbar:ClearAllPoints()
		frame.Castbar:Point("CENTER", UIParent, "CENTER", 0, 50)
		frame.Castbar:Width(240)
		frame.Castbar:Height(5)
	end
	if R.TableIsEmpty(R.SavePath["UFPos"]["Freeb - Target"]) then
		if C["ouf"].HealFrames and R.isHealer then
			frame:ClearAllPoints()
			frame:Point("BOTTOM", 350, 350)
		else
			frame:ClearAllPoints()
			frame:Point("BOTTOM", 0, 340)
		end
	end
	R.Update_Common(frame)
	frame:UpdateAllElements()
end

function R.Update_ToT(frame)
	R.Update_Common(frame)
	if R.TableIsEmpty(R.SavePath["UFPos"]["Freeb - Targettarget"]) then
		if C["ouf"].HealFrames and R.isHealer then
			frame:ClearAllPoints()
			frame:Point("TOPLEFT", oUF_FreebTarget, "BOTTOMLEFT", 0, -15)
		else
			frame:ClearAllPoints()
			frame:Point("BOTTOMLEFT", oUF_FreebTarget, "BOTTOMRIGHT", 10, 1)
		end
	end
	frame:UpdateAllElements()
end

function R.Update_Pet(frame)
	R.Update_Common(frame)
	if R.TableIsEmpty(R.SavePath["UFPos"]["Freeb - Pet"]) then
		if C["ouf"].HealFrames and R.isHealer then
			frame:ClearAllPoints()
			frame:Point("BOTTOM", 0, 160)
		else
			frame:ClearAllPoints()
			frame:Point("BOTTOM", 0, 220)
		end
	end
	frame:UpdateAllElements()
end

function R.Update_Focus(frame)
	R.Update_Common(frame)
	frame:UpdateAllElements()
end

function R.Update_FocusTarget(frame)
	R.Update_Common(frame)
	frame:UpdateAllElements()
end

function R.Update_Party(frame)
	for i=1, frame:GetNumChildren() do
		local child = select(i, frame:GetChildren())
		if child then
			if C["ouf"].showPortrait then
				if not child:IsElementEnabled('Portrait') then
					R.Portrait(child)
					child:EnableElement('Portrait')
					child.Portrait:Show()
				end
			else
				if child:IsElementEnabled('Portrait') then
					child:DisableElement('Portrait')
					child.Portrait:Hide()
				end	
			end
			R.Update_Common(child)
			child:UpdateAllElements()
		end		
	end
	if C["ouf"].HealFrames and R.isHealer then
		frame:SetAttribute("showParty", false)
		RegisterAttributeDriver(frame, 'state-visibility', "hide")
	else
		frame:SetAttribute("showParty", true)
		RegisterAttributeDriver(frame, 'state-visibility', "[@raid6,exists] hide;show")
	end
end

function R.Update_Boss(frame)
	for i = 1, MAX_BOSS_FRAMES do
		local child = _G[frame..i]
		if child then
			R.Update_Common(child)
			child:UpdateAllElements()
		end		
	end	
end

function R.Update_Raid()
	for i = 1, 5 do
		local frame = _G["Raid_Freebgrid"..i]
		for j=1, frame:GetNumChildren() do
			if C["ouf"].HealFrames and R.isHealer then
				frame:SetScale(1.25)
			else
				frame:SetScale(1)
			end
			local child = select(j, frame:GetChildren())
			if child then
				R.Update_Common(child)
				child:UpdateAllElements()
			end
		end	
	end
	local frame = _G["Raid_Freebgrid1"]
	if R.TableIsEmpty(R.SavePath["UFPos"]["Freebgrid"]) then
		if C["ouf"].HealFrames and R.isHealer then
			frame:ClearAllPoints()
			frame:Point("TOPLEFT", UIParent, "BOTTOM", - frame:GetChildren():GetWidth()*2.5 -  frame:GetAttribute("columnSpacing")*2, frame:GetChildren():GetHeight()*5 +  frame:GetAttribute("columnSpacing")*4 + 150)
		else
			frame:ClearAllPoints()
			frame:Point("TOPLEFT", UIParent, "BOTTOM", - frame:GetChildren():GetWidth()*2.5 -  frame:GetAttribute("columnSpacing")*2, frame:GetChildren():GetHeight()*5 +  frame:GetAttribute("columnSpacing")*4 + 40)
		end
	end
end

function R.Update_All()
	R.Update_Player(oUF_FreebPlayer)
	R.Update_Target(oUF_FreebTarget)
	R.Update_ToT(oUF_FreebTargettarget)
	R.Update_Focus(oUF_FreebFocus)
	R.Update_Pet(oUF_FreebPet)	
	R.Update_FocusTarget(oUF_FreebFocustarget)
	R.Update_Boss("oUF_FreebBoss")
	R.Update_Party(oUF_Party)
	R.Update_Raid()
end