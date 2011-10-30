--Create a Mover frame by Elv

local R, C, L, DB = unpack(select(2, ...))
local ADDON_NAME = ...

R.CreatedMovers = {}

local print = function(...)
	return print('|cff7aa6d6Ray|r|cffff0000U|r|cff7aa6d6I|r: ', ...)
end

local function CreateMover(parent, name, text, overlay, postdrag)
	if not parent then return end --If for some reason the parent isnt loaded yet
	
	if overlay == nil then overlay = true end
	
	local p, p2, p3, p4, p5 = parent:GetPoint()
	
	R.Movers = R.SavePath["movers"]
	
	if R.Movers == {} then R.Movers = nil end
	if R.Movers and R.Movers[name] == {} or (R.Movers and R.Movers[name] and R.Movers[name]["moved"] == false) then 
		R.Movers[name] = nil
	end
	
	local f = CreateFrame("Button", name, UIParent)
	f:SetFrameLevel(parent:GetFrameLevel() + 1)
	f:SetWidth(parent:GetWidth())
	f:SetHeight(parent:GetHeight())
	
	if overlay == true then
		f:SetFrameStrata("DIALOG")
	else
		f:SetFrameStrata("BACKGROUND")
	end
	if R["Movers"] and R["Movers"][name] then
		f:SetPoint(R["Movers"][name]["p"], UIParent, R["Movers"][name]["p2"], R["Movers"][name]["p3"], R["Movers"][name]["p4"])
	else
		f:SetPoint(p, p2, p3, p4, p5)
	end
	f:SetTemplate("Transparent")
	f.bd = CreateFrame("Button",nil, f)
	f.bd:CreateButton("Default", f:GetWidth(), f:GetHeight(), "CENTER", f, "CENTER", 0, 0)
	f.bd:ClearAllPoints()
	f.bd:SetPoint("TOPLEFT")
	f.bd:SetPoint("BOTTOMRIGHT")
	f.bd:SetFrameLevel(0)
	f:RegisterForDrag("LeftButton", "RightButton")
	f:SetScript("OnDragStart", function(self) 
		if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
		self:StartMoving() 
	end)
	
	f:SetScript("OnDragStop", function(self) 
		if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
		self:StopMovingOrSizing()
		
		if not R.SavePath["movers"] then R.SavePath["movers"] = {} end
		
		R.Movers = R.SavePath["movers"]
		
		R.Movers[name] = {}
		local p, _, p2, p3, p4 = self:GetPoint()
		R.Movers[name]["p"] = p
		R.Movers[name]["p2"] = p2
		R.Movers[name]["p3"] = p3
		R.Movers[name]["p4"] = p4
		
		if postdrag ~= nil and type(postdrag) == 'function' then
			postdrag(self)
		end
		
		self:SetUserPlaced(false)
	end)	
	
	parent:ClearAllPoints()
	parent:SetPoint(p3, f, p3, 0, 0)
	parent.ClearAllPoints = function() return end
	parent.SetAllPoints = function() return end
	parent.SetPoint = function() return end

	local fs = f:CreateFontString(nil, "OVERLAY")
	fs:SetFont(C["media"].font, C["media"].fontsize)
	fs:SetShadowOffset(R.mult*1.2, -R.mult*1.2)
	fs:SetJustifyH("CENTER")
	fs:SetPoint("CENTER")
	fs:SetText(text or name)
	fs:SetTextColor(1, 1, 1)
	f:SetFontString(fs)
	f.text = fs
	
	f:SetScript("OnEnter", function(self) 
		self.text:SetTextColor(self.bd.glow:GetBackdropBorderColor())
		self.bd:StartGlow()
	end)
	f:SetScript("OnLeave", function(self)
		self.text:SetTextColor(1, 1, 1)
		self.bd:StopGlow()
	end)
	
	f:SetMovable(true)
	f:Hide()	
	
	if postdrag ~= nil and type(postdrag) == 'function' then
		f:RegisterEvent("PLAYER_ENTERING_WORLD")
		f:SetScript("OnEvent", function(self, event)
			postdrag(f)
			self:UnregisterAllEvents()
		end)
	end	
end

function R.CreateMover(parent, name, text, overlay, postdrag)
	local p, p2, p3, p4, p5 = parent:GetPoint()

	if R.CreatedMovers[name] == nil then 
		R.CreatedMovers[name] = {}
		R.CreatedMovers[name]["parent"] = parent
		R.CreatedMovers[name]["text"] = text
		R.CreatedMovers[name]["overlay"] = overlay
		R.CreatedMovers[name]["postdrag"] = postdrag
		R.CreatedMovers[name]["p"] = p
		R.CreatedMovers[name]["p2"] = p2 or "UIParent"
		R.CreatedMovers[name]["p3"] = p3
		R.CreatedMovers[name]["p4"] = p4
		R.CreatedMovers[name]["p5"] = p5
	end	
	
	CreateMover(parent, name, text, overlay, postdrag)
end

function R.ToggleMovers()
	if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
	
	if RayUF or oUF then
		R.MoveoUF()
	end
	
	for name, _ in pairs(R.CreatedMovers) do
		if _G[name]:IsShown() then
			_G[name]:Hide()
		else
			_G[name]:Show()
		end
	end
end

function R.ResetMovers(arg)
	if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
	if arg == "" then
		for name, _ in pairs(R.CreatedMovers) do
			local n = _G[name]
			_G[name]:ClearAllPoints()
			_G[name]:SetPoint(R.CreatedMovers[name]["p"], R.CreatedMovers[name]["p2"], R.CreatedMovers[name]["p3"], R.CreatedMovers[name]["p4"], R.CreatedMovers[name]["p5"])
			
			
			R.Movers = nil
			R.SavePath["movers"] = R.Movers
			
			for key, value in pairs(R.CreatedMovers[name]) do
				if key == "postdrag" and type(value) == 'function' then
					value(n)
				end
			end
		end	
	else
		for name, _ in pairs(R.CreatedMovers) do
			for key, value in pairs(R.CreatedMovers[name]) do
				local mover
				if key == "text" then
					if arg == value then 
						_G[name]:ClearAllPoints()
						_G[name]:SetPoint(R.CreatedMovers[name]["p"], R.CreatedMovers[name]["p2"], R.CreatedMovers[name]["p3"], R.CreatedMovers[name]["p4"], R.CreatedMovers[name]["p5"])						
						
						if R.Movers then
							R.Movers[name] = nil
						end
						R.SavePath["movers"] = R.Movers
						
						if R.CreatedMovers[name]["postdrag"] ~= nil and type(R.CreatedMovers[name]["postdrag"]) == 'function' then
							R.CreatedMovers[name]["postdrag"](_G[name])
						end
					end
				end
			end	
		end
	end
end

local loadmovers = CreateFrame("Frame")
loadmovers:RegisterEvent("ADDON_LOADED")
loadmovers:RegisterEvent("PLAYER_REGEN_DISABLED")
loadmovers:SetScript("OnEvent", function(self, event, addon)
	if event == "ADDON_LOADED" then
		if addon ~= ADDON_NAME then return end
		for name, _ in pairs(R.CreatedMovers) do
			local n = name
			local p, t, o, pd
			for key, value in pairs(R.CreatedMovers[name]) do
				if key == "parent" then
					p = value
				elseif key == "text" then
					t = value
				elseif key == "overlay" then
					o = value
				elseif key == "postdrag" then
					pd = value
				end
			end
			CreateMover(p, n, t, o, pd)
		end
		self:UnregisterEvent("ADDON_LOADED")
	else
		local err = false
		for name, _ in pairs(R.CreatedMovers) do
			if _G[name]:IsShown() then
				err = true
				_G[name]:Hide()
			end
		end
			if err == true then
				print(ERR_NOT_IN_COMBAT)			
			end		
	end
end)

SLASH_MOVEUI1 = "/moveui"
SlashCmdList["MOVEUI"] = R.ToggleMovers