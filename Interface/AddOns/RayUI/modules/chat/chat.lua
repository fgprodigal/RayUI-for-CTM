﻿local R, L, P = unpack(select(2, ...)) --Inport: Engine, Locales, ProfileDB
local CH = R:NewModule("Chat", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0", "AceConsole-3.0")
CH.modName = L["聊天栏"]

local tokennum, matchTable = 1, {}
local currentLink
local lines = {}
local frame = nil
local editBox = nil
local isf = nil
local sizes = {
	":14:14",
	":16:16",
	":12:20",
	":14",
}

CH.LinkHoverShow = {
	["achievement"] = true,
	["enchant"]     = true,
	["glyph"]       = true,
	["item"]        = true,
	["quest"]       = true,
	["spell"]       = true,
	["talent"]      = true,
	["unit"]        = true,
}

local function CreatCopyFrame()
	local S = R:GetModule("Skins")
	frame = CreateFrame("Frame", "CopyFrame", UIParent)
	S:SetBD(frame)
	frame:SetScale(1)
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	frame:Size(400,400)
	frame:Hide()
	frame:EnableMouse(true)
	frame:SetFrameStrata("DIALOG")

	local scrollArea = CreateFrame("ScrollFrame", "CopyScroll", frame, "UIPanelScrollFrameTemplate")
	scrollArea:Point("TOPLEFT", frame, "TOPLEFT", 8, -30)
	scrollArea:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 8)
	
	S:ReskinScroll(CopyScrollScrollBar)

	editBox = CreateFrame("EditBox", "CopyBox", frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontNormal)
	editBox:SetWidth(scrollArea:GetWidth())
	editBox:Height(200)
	editBox:SetScript("OnEscapePressed", function()
		frame:Hide()
	end)
	
	--EXTREME HACK..
	editBox:SetScript("OnTextSet", function(self)
		local text = self:GetText()
		
		for _, size in pairs(sizes) do
			if string.find(text, size) then
				self:SetText(string.gsub(text, size, ":12:12"))
			end		
		end
	end)

	scrollArea:SetScrollChild(editBox)

	local close = CreateFrame("Button", "CopyCloseButton", frame, "UIPanelCloseButton")
	close:EnableMouse(true)
	close:SetScript("OnMouseUp", function()
		frame:Hide()
	end)
	
	S:ReskinClose(close)	
	close:ClearAllPoints()
	close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -7, -5)
	isf = true
end

local function GetLines(...)
	--[[		Grab all those lines		]]--
	local ct = 1
	for i = select("#", ...), 1, -1 do
		local region = select(i, ...)
		if region:GetObjectType() == "FontString" then
			lines[ct] = tostring(region:GetText())
			ct = ct + 1
		end
	end
	return ct - 1
end

local function Copy(cf)
	local _, size = cf:GetFont()
	FCF_SetChatWindowFontSize(cf, cf, 0.01)
	local lineCt = GetLines(cf:GetRegions())
	local text = table.concat(lines, "\n", 1, lineCt)
	FCF_SetChatWindowFontSize(cf, cf, size)
	if not isf then CreatCopyFrame() end
	if frame:IsShown() then frame:Hide() return end
	frame:Show()
	editBox:SetText(text)
end

local function ChatCopyButtons(id)
	local cf = _G[format("ChatFrame%d",  id)]
	local tab = _G[format("ChatFrame%dTab", id)]
	local name = FCF_GetChatWindowInfo(id)
	local point = GetChatWindowSavedPosition(id)
	local _, fontSize = FCF_GetChatWindowInfo(id)
	local button = _G[format("ButtonCF%d", id)]
	
	if not button then
		local button = CreateFrame("Button", format("ButtonCF%d", id), cf)
		button:Height(22)
		button:Width(20)
		button:SetAlpha(0)
		button:SetPoint("TOPRIGHT", 0, 0)
		button:SetTemplate("Default", true)
		
		local buttontex = button:CreateTexture(nil, "OVERLAY")
		buttontex:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
		buttontex:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
		buttontex:SetTexture([[Interface\AddOns\RayUI\media\copy.tga]])
		
		if id == 1 then
			button:SetScript("OnMouseUp", function(self, btn)
				if btn == "RightButton" then
					ToggleFrame(ChatMenu)
				else
					Copy(cf)
				end
			end)
		else
			button:SetScript("OnMouseUp", function(self, btn)
				Copy(cf)
			end)		
		end
		
		button:SetScript("OnEnter", function() 
			button:SetAlpha(1) 
		end)
		button:SetScript("OnLeave", function() button:SetAlpha(0) end)
	end

end

function CH:GetOptions()
	local options = {
		width = {
			order = 5,
			name = L["长度"],
			type = "range",
			min = 300, max = 600, step = 1,
		},
		height = {
			order = 6,
			name = L["高度"],
			type = "range",
			min = 100, max = 300, step = 1,
		},
		spacer = {
			order = 7,
			name = " ",
			desc = " ",
			type = "description",
		},
		autohide = {
			order = 8,
			name = L["自动隐藏聊天栏"],
			desc = L["短时间内没有消息则自动隐藏聊天栏"],
			type = "toggle",
		},
		autohidetime = {
			order = 9,
			name = L["自动隐藏时间"],
			desc = L["设置多少秒没有新消息时隐藏"],
			type = "range",
			min = 5, max = 60, step = 1,
			disabled = function() return not self.db.autohide end,
		},
		autoshow = {
			order = 10,
			name = L["自动显示聊天栏"],
			desc = L["频道内有信消息则自动显示聊天栏，关闭后如有新密语会闪烁提示"],
			type = "toggle",
		},
	}
	return options
end

function CH:OnInitialize()
	self.db = R.db.Chat
end

function CH:Info()
	return L["|cff7aa6d6Ray|r|cffff0000U|r|cff7aa6d6I|r聊天模块."] 
end

function CH:EditBox_MouseOn()
	for i =1, 10 do
		local eb = _G["ChatFrame"..i.."EditBox"]
		local tab = _G["ChatFrame"..i.."Tab"]
		eb:EnableMouse(true)
		tab:EnableMouse(false)
	end
end

function  CH:EditBox_MouseOff()
	for i =1, 10 do
		local eb = _G["ChatFrame"..i.."EditBox"]
		local tab = _G["ChatFrame"..i.."Tab"]
		eb:EnableMouse(false)
		tab:EnableMouse(true)
	end
end

local tlds = {
	ONION = true,
	-- Copied from http://data.iana.org/TLD/tlds-alpha-by-domain.txt
	-- Version 2008041301, Last Updated Mon Apr 21 08:07:00 2008 UTC
	AC = true,
	AD = true,
	AE = true,
	AERO = true,
	AF = true,
	AG = true,
	AI = true,
	AL = true,
	AM = true,
	AN = true,
	AO = true,
	AQ = true,
	AR = true,
	ARPA = true,
	AS = true,
	ASIA = true,
	AT = true,
	AU = true,
	AW = true,
	AX = true,
	AZ = true,
	BA = true,
	BB = true,
	BD = true,
	BE = true,
	BF = true,
	BG = true,
	BH = true,
	BI = true,
	BIZ = true,
	BJ = true,
	BM = true,
	BN = true,
	BO = true,
	BR = true,
	BS = true,
	BT = true,
	BV = true,
	BW = true,
	BY = true,
	BZ = true,
	CA = true,
	CAT = true,
	CC = true,
	CD = true,
	CF = true,
	CG = true,
	CH = true,
	CI = true,
	CK = true,
	CL = true,
	CM = true,
	CN = true,
	CO = true,
	COM = true,
	COOP = true,
	CR = true,
	CU = true,
	CV = true,
	CX = true,
	CY = true,
	CZ = true,
	DE = true,
	DJ = true,
	DK = true,
	DM = true,
	DO = true,
	DZ = true,
	EC = true,
	EDU = true,
	EE = true,
	EG = true,
	ER = true,
	ES = true,
	ET = true,
	EU = true,
	FI = true,
	FJ = true,
	FK = true,
	FM = true,
	FO = true,
	FR = true,
	GA = true,
	GB = true,
	GD = true,
	GE = true,
	GF = true,
	GG = true,
	GH = true,
	GI = true,
	GL = true,
	GM = true,
	GN = true,
	GOV = true,
	GP = true,
	GQ = true,
	GR = true,
	GS = true,
	GT = true,
	GU = true,
	GW = true,
	GY = true,
	HK = true,
	HM = true,
	HN = true,
	HR = true,
	HT = true,
	HU = true,
	ID = true,
	IE = true,
	IL = true,
	IM = true,
	IN = true,
	INFO = true,
	INT = true,
	IO = true,
	IQ = true,
	IR = true,
	IS = true,
	IT = true,
	JE = true,
	JM = true,
	JO = true,
	JOBS = true,
	JP = true,
	KE = true,
	KG = true,
	KH = true,
	KI = true,
	KM = true,
	KN = true,
	KP = true,
	KR = true,
	KW = true,
	KY = true,
	KZ = true,
	LA = true,
	LB = true,
	LC = true,
	LI = true,
	LK = true,
	LR = true,
	LS = true,
	LT = true,
	LU = true,
	LV = true,
	LY = true,
	MA = true,
	MC = true,
	MD = true,
	ME = true,
	MG = true,
	MH = true,
	MIL = true,
	MK = true,
	ML = true,
	MM = true,
	MN = true,
	MO = true,
	MOBI = true,
	MP = true,
	MQ = true,
	MR = true,
	MS = true,
	MT = true,
	MU = true,
	MUSEUM = true,
	MV = true,
	MW = true,
	MX = true,
	MY = true,
	MZ = true,
	NA = true,
	NAME = true,
	NC = true,
	NE = true,
	NET = true,
	NF = true,
	NG = true,
	NI = true,
	NL = true,
	NO = true,
	NP = true,
	NR = true,
	NU = true,
	NZ = true,
	OM = true,
	ORG = true,
	PA = true,
	PE = true,
	PF = true,
	PG = true,
	PH = true,
	PK = true,
	PL = true,
	PM = true,
	PN = true,
	PR = true,
	PRO = true,
	PS = true,
	PT = true,
	PW = true,
	PY = true,
	QA = true,
	RE = true,
	RO = true,
	RS = true,
	RU = true,
	RW = true,
	SA = true,
	SB = true,
	SC = true,
	SD = true,
	SE = true,
	SG = true,
	SH = true,
	SI = true,
	SJ = true,
	SK = true,
	SL = true,
	SM = true,
	SN = true,
	SO = true,
	SR = true,
	ST = true,
	SU = true,
	SV = true,
	SY = true,
	SZ = true,
	TC = true,
	TD = true,
	TEL = true,
	TF = true,
	TG = true,
	TH = true,
	TJ = true,
	TK = true,
	TL = true,
	TM = true,
	TN = true,
	TO = true,
	TP = true,
	TR = true,
	TRAVEL = true,
	TT = true,
	TV = true,
	TW = true,
	TZ = true,
	UA = true,
	UG = true,
	UK = true,
	UM = true,
	US = true,
	UY = true,
	UZ = true,
	VA = true,
	VC = true,
	VE = true,
	VG = true,
	VI = true,
	VN = true,
	VU = true,
	WF = true,
	WS = true,
	YE = true,
	YT = true,
	YU = true,
	ZA = true,
	ZM = true,
	ZW = true,
}

local function RegisterMatch(text)
	local token = "\255\254\253"..tokennum.."\253\254\255"
	matchTable[token] = string.gsub(text, "%%", "%%%%")
	tokennum = tokennum + 1
	return token
end

local function Link(link, ...)
	if link == nil then
		return ""
	end
	return RegisterMatch(string.format("|cff8A9DDE|Hurl:%s|h[%s]|h|r", link, link))
end

local function Link_TLD(link, tld, ...)
	if link == nil or tld == nil then
		return ""
	end
	if tlds[tld:upper()] then
        return RegisterMatch(string.format("|cff8A9DDE|Hurl:%s|h[%s]|h|r", link, link))
    else
        return RegisterMatch(link)
    end
end

local patterns = {
		-- X://Y url
	{ pattern = "^(%a[%w%.+-]+://%S+)", matchfunc=Link},
	{ pattern = "%f[%S](%a[%w%.+-]+://%S+)", matchfunc=Link},
		-- www.X.Y url
	{ pattern = "^(www%.[-%w_%%]+%.%S+)", matchfunc=Link},
	{ pattern = "%f[%S](www%.[-%w_%%]+%.%S+)", matchfunc=Link},
		-- "W X"@Y.Z email (this is seriously a valid email)
	--{ pattern = "^(%"[^%"]+%"@[-%w_%%%.]+%.(%a%a+))", matchfunc=Link_TLD},
	--{ pattern = "%f[%S](%"[^%"]+%"@[-%w_%%%.]+%.(%a%a+))", matchfunc=Link_TLD},
		-- X@Y.Z email
	{ pattern = "(%S+@[-%w_%%%.]+%.(%a%a+))", matchfunc=Link_TLD},
		-- XXX.YYY.ZZZ.WWW:VVVV/UUUUU IPv4 address with port and path
	{ pattern = "^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d/%S+)", matchfunc=Link},
	{ pattern = "%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d/%S+)", matchfunc=Link},
		-- XXX.YYY.ZZZ.WWW:VVVV IPv4 address with port (IP of ts server for example)
	{ pattern = "^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d)%f[%D]", matchfunc=Link},
	{ pattern = "%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d)%f[%D]", matchfunc=Link},
		-- XXX.YYY.ZZZ.WWW/VVVVV IPv4 address with path
	{ pattern = "^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%/%S+)", matchfunc=Link},
	{ pattern = "%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%/%S+)", matchfunc=Link},
		-- XXX.YYY.ZZZ.WWW IPv4 address
	{ pattern = "^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%)%f[%D]", matchfunc=Link},
	{ pattern = "%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%)%f[%D]", matchfunc=Link},
		-- X.Y.Z:WWWW/VVVVV url with port and path
	{ pattern = "^([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d/%S+)", matchfunc=Link_TLD},
	{ pattern = "%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d/%S+)", matchfunc=Link_TLD},
		-- X.Y.Z:WWWW url with port (ts server for example)
	{ pattern = "^([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d)%f[%D]", matchfunc=Link_TLD},
	{ pattern = "%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d)%f[%D]", matchfunc=Link_TLD},
		-- X.Y.Z/WWWWW url with path
	{ pattern = "^([-%w_%%%.]+[-%w_%%]%.(%a%a+)/%S+)", matchfunc=Link_TLD},
	{ pattern = "%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+)/%S+)", matchfunc=Link_TLD},
		-- X.Y.Z url
	{ pattern = "^([-%w_%%%.]+[-%w_%%]%.(%a%a+))", matchfunc=Link_TLD},
	{ pattern = "%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+))", matchfunc=Link_TLD},
}

local function filterFunc(frame, event, msg, ...)
	if not msg then return false, msg, ... end
	for i, v in ipairs(patterns) do
		msg = string.gsub(msg, v.pattern, v.matchfunc)
	end
	for k,v in pairs(matchTable) do
		msg = string.gsub(msg, k, v)
		matchTable[k] = nil
	end
	return false, msg, ...
end

function CH:OnHyperlinkEnter(frame, linkData, link)
	local t = linkData:match("^(.-):")
	if CH.LinkHoverShow[t] then
		ShowUIPanel(GameTooltip)
		GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
		GameTooltip:SetHyperlink(link)
		GameTooltip:Show()
	end
end

function CH:OnHyperlinkLeave(frame, linkData, link)
	local t = linkData:match("^(.-):")
	if CH.LinkHoverShow[t] then
		HideUIPanel(GameTooltip)
	end
end

function CH:OnMouseScroll(frame, dir)
	if dir > 0 then
		if IsShiftKeyDown() then
			frame:ScrollToTop()
		elseif IsControlKeyDown() then
			--only need to scroll twice because of blizzards scroll
			frame:ScrollUp()
			frame:ScrollUp()
		end
	elseif dir < 0 then
		if IsShiftKeyDown() then
			frame:ScrollToBottom()
		elseif IsControlKeyDown() then
			--only need to scroll twice because of blizzards scroll
			frame:ScrollDown()
			frame:ScrollDown()
		end
	end
end

function CH:LinkHoverOnLoad()
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G["ChatFrame"..i]
		self:HookScript(cf, "OnHyperlinkEnter", "OnHyperlinkEnter")
		self:HookScript(cf, "OnHyperlinkLeave", "OnHyperlinkLeave")
	end
end

local function nocase(s)
    s = string.gsub(s, "%a", function (c)
       return string.format("[%s%s]", string.lower(c),
                                          string.upper(c))
    end)
    return s
end

local function changeName(msgHeader, name, msgCnt, chatGroup, displayName, msgBody)
	if name ~= R.myname then
		msgBody = msgBody:gsub("("..nocase(R.myname)..")" , "|cffffff00>>|r|cffff0000%1|r|cffffff00<<|r")
	end
	return ("|Hplayer:%s%s%s|h[%s]|h%s"):format(name, msgCnt, chatGroup, displayName, msgBody)
end

function CH:AddMessage(text, ...)
	if text:find(INTERFACE_ACTION_BLOCKED) then return end
	if text:find("BN_CONVERSATION") then

	else
		text = text:gsub("%[(%d0?)%. .-%]", "[%1]") --custom channels
		text = text:gsub("CHANNEL:", "")
	end
	if text and type(text) == "string" then
		text = text:gsub("(|Hplayer:([^:]+)([:%d+]*)([:%w+]*)|h%[(.-)%]|h)(.-)$", changeName)
	end
	if CHAT_TIMESTAMP_FORMAT and not text:find("|r") then
		text = BetterDate(CHAT_TIMESTAMP_FORMAT, time())..text
	end
	text = string.gsub(text, "%[(%d+)%. .-%]", "[%1]")
	text = ("|cffffffff|HTimeCopy|h|r%s|h %s"):format("|cff64C2F5"..date("[%H:%M]").."|r", text)
	return self.OldAddMessage(self, text, ...)
end

function CH:SetChatPosition()
	for i = 1, NUM_CHAT_WINDOWS do
		if _G["ChatFrame"..i] == COMBATLOG then
			_G["ChatFrame"..i]:ClearAllPoints()
			_G["ChatFrame"..i]:SetPoint("TOPLEFT", _G["ChatBG"], "TOPLEFT", 2, -2 - CombatLogQuickButtonFrame_Custom:GetHeight())
			_G["ChatFrame"..i]:SetPoint("BOTTOMRIGHT", _G["ChatBG"], "BOTTOMRIGHT", -2, 4)
		else				
			_G["ChatFrame"..i]:ClearAllPoints()
			_G["ChatFrame"..i]:SetPoint("TOPLEFT", _G["ChatBG"], "TOPLEFT", 2, -2)
			_G["ChatFrame"..i]:SetPoint("BOTTOMRIGHT", _G["ChatBG"], "BOTTOMRIGHT", -2, 4)
			FCF_SavePositionAndDimensions(_G["ChatFrame"..i])
			local _, _, _, _, _, _, shown, _, docked, _ = GetChatWindowInfo(i)
			if shown and not docked then
				FCF_DockFrame(_G["ChatFrame"..i])
			end
		end
	end
end

function CH:ApplyStyle()
	ChatFrameMenuButton:Kill()
	ChatFrameMenuButton:SetScript("OnShow", kill)
	FriendsMicroButton:Hide()
	FriendsMicroButton:Kill()

	if not _G["ChatBG"] then
		local ChatBG = CreateFrame("Frame", "ChatBG", UIParent)
		ChatBG:CreatePanel("Default", self.db.width, self.db.height, "BOTTOMLEFT",UIParent,"BOTTOMLEFT",15,30)
		GeneralDockManager:SetParent(ChatBG)
	end
	
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G["ChatFrame"..i]
		local tab = _G["ChatFrame"..i.."Tab"]
		local eb = _G["ChatFrame"..i.."EditBox"]

		cf:SetParent(ChatBG)
		local ebParts = {"Left", "Mid", "Right", "Middle"}
		for j = 1, #CHAT_FRAME_TEXTURES do 
			_G[format("ChatFrame%s", i)..CHAT_FRAME_TEXTURES[j]]:SetTexture(nil) 
		end
		for _, ebPart in ipairs(ebParts) do
			if _G["ChatFrame"..i.."EditBoxFocus"..ebPart] then
				_G["ChatFrame"..i.."EditBoxFocus"..ebPart]:SetHeight(18)
				_G["ChatFrame"..i.."EditBoxFocus"..ebPart]:SetTexture(nil)
				_G["ChatFrame"..i.."EditBoxFocus"..ebPart].SetTexture = function() return end
			end
			if _G["ChatFrame"..i.."EditBox"..ebPart] then
				_G["ChatFrame"..i.."EditBox"..ebPart]:SetTexture(nil)
				_G["ChatFrame"..i.."EditBox"..ebPart].SetTexture = function() return end
			end
			if _G["ChatFrame"..i.."TabHighlight"..ebPart] then
				_G["ChatFrame"..i.."TabHighlight"..ebPart]:SetTexture(nil)
				_G["ChatFrame"..i.."TabHighlight"..ebPart].SetTexture = function() return end
			end
			if _G["ChatFrame"..i.."TabSelected"..ebPart] then
				_G["ChatFrame"..i.."TabSelected"..ebPart]:SetTexture(nil)
				_G["ChatFrame"..i.."TabSelected"..ebPart].SetTexture = function() return end
			end
			if _G["ChatFrame"..i.."Tab"..ebPart] then
				_G["ChatFrame"..i.."Tab"..ebPart]:SetTexture(nil)
				_G["ChatFrame"..i.."Tab"..ebPart].SetTexture = function() return end
			end
		end
		if not _G["ChatFrame"..i.."EditBoxBG"] then
			local chatebbg = CreateFrame("Frame", "ChatFrame"..i.."EditBoxBG" , _G["ChatFrame"..i.."EditBox"])
			chatebbg:SetPoint("TOPLEFT", -2, -5)
			chatebbg:SetPoint("BOTTOMRIGHT", 2, 4)
			_G["ChatFrame"..i.."EditBoxLanguage"]:Kill()
		end
		ChatCopyButtons(i)
		if cf ~= COMBATLOG then
			cf.OldAddMessage = cf.AddMessage
			cf.AddMessage = CH.AddMessage
		end

		_G["ChatFrame"..i.."ButtonFrame"]:Kill()
		tab:SetAlpha(0)
		tab.noMouseAlpha = 0
		cf:SetFading(false)
		cf:SetMinResize(0,0)
		cf:SetMaxResize(0,0)
		cf:SetClampedToScreen(false)
		cf:SetClampRectInsets(0,0,0,0)
		_G["ChatFrame"..i.."TabText"]:SetFont(R["media"].font, 13)
		local editbox = CreateFrame("Frame", nil, UIParent)
		editbox:Height(22)
		editbox:SetWidth(ChatBG:GetWidth())
		editbox:SetPoint("BOTTOMLEFT", cf, "TOPLEFT",  -2, 6)
		editbox:CreateShadow("Background")
		editbox:Hide()
		eb:SetAltArrowKeyMode(false)
		eb:ClearAllPoints()
		eb:Point("TOPLEFT", editbox, 2, 6)
		eb:Point("BOTTOMRIGHT", editbox, -2, -3)
		eb:SetParent(UIParent)
		eb:Hide()
		editbox.finish_function = function()
			if eb:IsShown() then return end
			editbox:SetWidth(ChatBG:GetWidth())
			if eb._Show then
				eb.Show = eb._Show
			end
		end
		eb._Show = eb.Show
		eb:HookScript("OnShow", function(self)
			editbox.wpos = 100
			editbox.wspeed = 600
			editbox.wlimit = ChatBG:GetWidth()
			editbox.wmod = 1
			editbox:SetScript("OnUpdate", R.simple_width)
			UIFrameFadeIn(editbox, .3, 0, 1)
		end)
		eb:HookScript("OnHide", function(self)
			editbox.wpos = ChatBG:GetWidth()
			editbox.wspeed = -750
			editbox.wlimit = 1
			editbox.wmod = -1
			eb.Show = R.dummy
			editbox:SetScript("OnUpdate", R.simple_width)
			UIFrameFadeOut(editbox, .3, 1, 0)
		end)
		hooksecurefunc("ChatEdit_UpdateHeader", function()
				local type = _G["ChatFrame"..i.."EditBox"]:GetAttribute("chatType")
				if ( type == "CHANNEL" ) then
				local id = GetChannelName(_G["ChatFrame"..i.."EditBox"]:GetAttribute("channelTarget"))
					if id == 0 then
						editbox.border:SetBackdropBorderColor(unpack(R["media"].bordercolor))
					else
						editbox.border:SetBackdropBorderColor(ChatTypeInfo[type..id].r,ChatTypeInfo[type..id].g,ChatTypeInfo[type..id].b)
					end
				else
					editbox.border:SetBackdropBorderColor(ChatTypeInfo[type].r,ChatTypeInfo[type].g,ChatTypeInfo[type].b)
				end
			end)
		local function BottomButtonClick(self)
			self:GetParent():ScrollToBottom();
		end
		local bb = _G["ChatFrame"..i.."ButtonFrameBottomButton"]
		bb:SetParent(_G["ChatFrame"..i])
		bb:SetHeight(18)
		bb:SetWidth(18)
		bb:ClearAllPoints()
		bb:SetPoint("TOPRIGHT", cf, "TOPRIGHT", 0, -20)
		bb:SetAlpha(0.4)
		bb.SetPoint = function() end
		bb:SetScript("OnClick", BottomButtonClick)
		local font, path = cf:GetFont()
		cf:SetFont(font, path, R["media"].fontflag)
		cf:SetShadowColor(0, 0, 0, 0)
	end
end

function CH:SetChat()
	local whisperFound
	for i = 1, NUM_CHAT_WINDOWS do
		local chatName, _, _, _, _, _, shown = FCF_GetChatWindowInfo(_G["ChatFrame"..i]:GetID())
		if chatName == WHISPER then
			if shown then
				whisperFound = true
			elseif not shown and not whisperFound  then
				_G["ChatFrame"..i]:Show()
				whisperFound = true
			end
		end
	end
	if not whisperFound then
		FCF_OpenNewWindow(WHISPER)
	end
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G["ChatFrame"..i]
		FCF_SetChatWindowFontSize(nil, frame, 15)
		FCF_SetWindowAlpha(frame , 0)
		local chatName = FCF_GetChatWindowInfo(frame:GetID())
		if chatName == WHISPER then
			ChatFrame_RemoveAllMessageGroups(frame)
			ChatFrame_AddMessageGroup(frame, "WHISPER")
			ChatFrame_AddMessageGroup(frame, "BN_WHISPER")
		end
	end
    ChatFrame1:SetFrameLevel(8)
    FCF_SavePositionAndDimensions(ChatFrame1)
	FCF_SetLocked(ChatFrame1, 1)
	ChangeChatColor("CHANNEL1", 195/255, 230/255, 232/255)
	ChangeChatColor("CHANNEL2", 232/255, 158/255, 121/255)
	ChangeChatColor("CHANNEL3", 232/255, 228/255, 121/255)
	ToggleChatColorNamesByClassGroup(true, "SAY")
	ToggleChatColorNamesByClassGroup(true, "EMOTE")
	ToggleChatColorNamesByClassGroup(true, "YELL")
	ToggleChatColorNamesByClassGroup(true, "GUILD")
	ToggleChatColorNamesByClassGroup(true, "OFFICER")
	ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "WHISPER")
	ToggleChatColorNamesByClassGroup(true, "PARTY")
	ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID")
	ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND_LEADER")	
	ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL5")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL6")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL7")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL8")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL9")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL10")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL11")
	
	FCFDock_SelectWindow(GENERAL_CHAT_DOCK, ChatFrame1)
end

function CH:SetItemRef(link, text, button, chatFrame)
	local linkType, id = strsplit(":", link)
	if linkType == "TimeCopy" then
		frame = GetMouseFocus():GetParent()
		local text
		for i = 1, select("#", frame:GetRegions()) do
			local obj = select(i, frame:GetRegions())
			if obj:GetObjectType() == "FontString" and obj:IsMouseOver() then
				text = obj:GetText()
			end
		end
		text = text:gsub("|c%x%x%x%x%x%x%x%x(.-)|r", "%1")
		text = text:gsub("|H.-|h(.-)|h", "%1")
		local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()
		if (not ChatFrameEditBox:IsShown()) then
			ChatEdit_ActivateChat(ChatFrameEditBox)
		end
		ChatFrameEditBox:SetText(text)
		ChatFrameEditBox:HighlightText()
	elseif linkType == "url" then
		currentLink = string.sub(link, 5)
		StaticPopup_Show("UrlCopyDialog")
	elseif linkType == "RayUIDamegeMeters" then
		local meterID = tonumber(id)
		ShowUIPanel(ItemRefTooltip)
		if not ItemRefTooltip:IsShown() then
			ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
		end
		ItemRefTooltip:ClearLines()
		ItemRefTooltip:AddLine(CH.meters[meterID].title)
		ItemRefTooltip:AddLine(string.format(L["发布者"]..": %s", CH.meters[meterID].source))
		for k, v in ipairs(CH.meters[meterID].data) do
			local left, right = v:match("^(.*)  (.*)$")
			if left and right then
				ItemRefTooltip:AddDoubleLine(left, right, 1, 1, 1, 1, 1, 1)
			else
				ItemRefTooltip:AddLine(v, 1, 1, 1)
			end
		end
		ItemRefTooltip:Show()
	elseif linkType == "RayUILootCollector" then
		ShowUIPanel(ItemRefTooltip)
		if not ItemRefTooltip:IsShown() then ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE") end

		local roll = CH.rolls[tonumber(id)]
		local rolltype = roll[roll._winner][1]
		ItemRefTooltip:ClearLines()
		ItemRefTooltip:AddLine(rolltype.."|r - "..roll._link)
		local r, g, b = 1, 1, 1
		if roll[roll._winner][3] then
			r, g, b = RAID_CLASS_COLORS[roll[roll._winner][3]].r, RAID_CLASS_COLORS[roll[roll._winner][3]].g, RAID_CLASS_COLORS[roll[roll._winner][3]].b
		end
		ItemRefTooltip:AddDoubleLine(L["获胜者"]..": ", R:RGBToHex(r, g, b)..roll._winner.."|r")
		for i,v in pairs(roll) do
			if string.sub(i, 1, 1) ~= "_" and v[2] then
				local r, g, b = 1, 1, 1
				if v[3] then
					r, g, b = RAID_CLASS_COLORS[v[3]].r, RAID_CLASS_COLORS[v[3]].g, RAID_CLASS_COLORS[v[3]].b
				end
				if i == UnitName("player") then
					ItemRefTooltip:AddDoubleLine(R:RGBToHex(r, g, b)..i.."|r (|cffff0000"..YOU.."|r)", v[2])
				elseif i == roll._winner then
					ItemRefTooltip:AddDoubleLine(R:RGBToHex(r, g, b)..i.."|r (|cffff0000"..L["获胜者"].."|r)", v[2])
				else
					ItemRefTooltip:AddDoubleLine(R:RGBToHex(r, g, b)..i.."|r", v[2])
				end
			end
		end
		ItemRefTooltip:Show()
	else
		return self.hooks.SetItemRef(link, text, button)
	end
end

function CH:Initialize()
	CHAT_BATTLEGROUND_GET = "|Hchannel:Battleground|h".."[BG]".."|h %s:\32"
	CHAT_BATTLEGROUND_LEADER_GET = "|Hchannel:Battleground|h".."[BG]".."|h %s:\32"
	CHAT_BN_WHISPER_GET = "%s:\32"
	CHAT_GUILD_GET = "|Hchannel:Guild|h".."[G]".."|h %s:\32"
	CHAT_OFFICER_GET = "|Hchannel:o|h".."[O]".."|h %s:\32"
	CHAT_PARTY_GET = "|Hchannel:Party|h".."[P]".."|h %s:\32"
	CHAT_PARTY_GUIDE_GET = "|Hchannel:party|h".."[PL]".."|h %s:\32"
	CHAT_PARTY_LEADER_GET = "|Hchannel:party|h".."[PL]".."|h %s:\32"
	CHAT_RAID_GET = "|Hchannel:raid|h".."[R]".."|h %s:\32"
	CHAT_RAID_LEADER_GET = "|Hchannel:raid|h".."[R]".."|h %s:\32"
	CHAT_RAID_WARNING_GET = "[RW]".." %s:\32"
	CHAT_SAY_GET = "%s:\32"
	CHAT_WHISPER_GET = "%s:\32"
	CHAT_YELL_GET = "%s:\32"
	ERR_FRIEND_ONLINE_SS = ERR_FRIEND_ONLINE_SS:gsub("%]%|h", "]|h|cff00ffff")
	ERR_FRIEND_OFFLINE_S = ERR_FRIEND_OFFLINE_S:gsub("%%s", "%%s|cffff0000")

	TIMESTAMP_FORMAT_HHMM = "|cff64C2F5[%I:%M]|r "
	TIMESTAMP_FORMAT_HHMMSS = "|cff64C2F5[%I:%M:%S]|r "
	TIMESTAMP_FORMAT_HHMMSS_24HR = "|cff64C2F5[%H:%M:%S]|r "
	TIMESTAMP_FORMAT_HHMMSS_AMPM = "|cff64C2F5[%I:%M:%S %p]|r "
	TIMESTAMP_FORMAT_HHMM_24HR = "|cff64C2F5[%H:%M]|r "
	TIMESTAMP_FORMAT_HHMM_AMPM = "|cff64C2F5[%I:%M %p]|r "

	CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0
	CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0
	
	ChatTypeInfo.EMOTE.sticky = 0
	ChatTypeInfo.YELL.sticky = 0
	ChatTypeInfo.RAID_WARNING.sticky = 1
	ChatTypeInfo.WHISPER.sticky = 0
	ChatTypeInfo.BN_WHISPER.sticky = 0

	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_JOIN", function(msg) return true end)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_LEAVE", function(msg) return true end)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_NOTICE", function(msg) return true end)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_AFK", function(msg) return true end)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_DND", function(msg) return true end)
	
	self:SecureHook("ChatFrame_OpenChat", "EditBox_MouseOn")
	self:SecureHook("ChatEdit_OnShow", "EditBox_MouseOn")
	self:SecureHook("ChatEdit_SendText", "EditBox_MouseOff")
	self:SecureHook("ChatEdit_OnHide", "EditBox_MouseOff")
	self:SecureHook("FloatingChatFrame_OnMouseScroll", "OnMouseScroll")

	local events = {
		"CHAT_MSG_BATTLEGROUND", "CHAT_MSG_BATTLEGROUND_LEADER",
		"CHAT_MSG_CHANNEL", "CHAT_MSG_EMOTE",
		"CHAT_MSG_GUILD", "CHAT_MSG_OFFICER",
		"CHAT_MSG_PARTY", "CHAT_MSG_RAID",
		"CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING", "CHAT_MSG_PARTY_LEADER",
		"CHAT_MSG_SAY", "CHAT_MSG_WHISPER","CHAT_MSG_BN_WHISPER",
		"CHAT_MSG_WHISPER_INFORM", "CHAT_MSG_YELL", "CHAT_MSG_BN_WHISPER_INFORM","CHAT_MSG_BN_CONVERSATION"
	}
	for _,event in ipairs(events) do
		ChatFrame_AddMessageEventFilter(event, filterFunc)
	end

	self:LinkHoverOnLoad()
	self:ApplyStyle()
	self:AutoHide()
	self:SpamFilter()
	self:DamageMeterFilter()
	self:RollFilter()
	self:EasyChannel()
	self:ScheduleRepeatingTimer("SetChatPosition", 1)
	self:RawHook("SetItemRef", true)
	
	SetCVar("showTimestamps", "none")
	SetCVar("profanityFilter", 0)
	SetCVar("chatStyle", "classic")
	
	self:RegisterChatCommand("setchat", "SetChat")
end

StaticPopupDialogs["UrlCopyDialog"] = {
	text = L["URL Ctrl+C复制"],
	button2 = CLOSE,
	hasEditBox = 1,
	editBoxWidth = 400,
	OnShow = function(frame)
		local editBox = _G[frame:GetName().."EditBox"]
		if editBox then
			editBox:SetText(currentLink)
			editBox:SetFocus()
			editBox:HighlightText(0)
		end
		local button = _G[frame:GetName().."Button2"]
		if button then
			button:ClearAllPoints()
			button:SetWidth(200)
			button:SetPoint("CENTER", editBox, "CENTER", 0, -30)
		end
	end,
	EditBoxOnEscapePressed = function(frame) frame:GetParent():Hide() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	maxLetters=1024, -- this otherwise gets cached from other dialogs which caps it at 10..20..30...
}

R:RegisterModule(CH:GetName())