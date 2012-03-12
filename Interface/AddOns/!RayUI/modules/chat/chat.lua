local R, C, L, DB = unpack(select(2, ...))
if not C["chat"].enable then return end

local AutoApply = false											-- /setchat upon UI loading
--Setchat parameters. Those parameters will apply to ChatFrame1 when you use /setchat
local def_position = {"BOTTOMLEFT",UIParent,"BOTTOMLEFT",10,30} -- Chat Frame position
local fontsize = 15
local fontFlag = "THINOUTLINE"
--other variables
local eb_width = chat_width						-- Editbox width
local tscol = "64C2F5"						-- Timestamp coloring
local LinkHover = {}; LinkHover.show = {	-- enable (true) or disable (false) LinkHover functionality for different things in chat
	["achievement"] = true,
	["enchant"]     = true,
	["glyph"]       = true,
	["item"]        = true,
	["quest"]       = true,
	["spell"]       = true,
	["talent"]      = true,
	["unit"]        = true,}

---------------- > Sticky Channels
ChatTypeInfo.EMOTE.sticky = 0
ChatTypeInfo.YELL.sticky = 0
ChatTypeInfo.RAID_WARNING.sticky = 1
ChatTypeInfo.WHISPER.sticky = 0
ChatTypeInfo.BN_WHISPER.sticky = 0

-------------- > Custom timestamps color
do
	ChatFrame2ButtonFrameBottomButton:RegisterEvent("PLAYER_LOGIN")
	ChatFrame2ButtonFrameBottomButton:SetScript("OnEvent", function(f)
		TIMESTAMP_FORMAT_HHMM = "|cff"..tscol.."[%I:%M]|r "
		TIMESTAMP_FORMAT_HHMMSS = "|cff"..tscol.."[%I:%M:%S]|r "
		TIMESTAMP_FORMAT_HHMMSS_24HR = "|cff"..tscol.."[%H:%M:%S]|r "
		TIMESTAMP_FORMAT_HHMMSS_AMPM = "|cff"..tscol.."[%I:%M:%S %p]|r "
		TIMESTAMP_FORMAT_HHMM_24HR = "|cff"..tscol.."[%H:%M]|r "
		TIMESTAMP_FORMAT_HHMM_AMPM = "|cff"..tscol.."[%I:%M %p]|r "
		f:UnregisterEvent("PLAYER_LOGIN")
		f:SetScript("OnEvent", nil)
	end)
end

---------------- > Fading alpha
CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0
CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0

function SetChat()
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
		FCF_SetChatWindowFontSize(nil, frame, fontsize)
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

SlashCmdList["SETCHAT"] = SetChat
SLASH_SETCHAT1 = "/setchat"

if AutoApply then
	local f = CreateFrame"Frame"
	f:RegisterEvent("PLAYER_ENTERING_WORLD")
	f:SetScript("OnEvent", function() SetChat() end)
end

do
	-- Buttons Hiding/moving 
	local kill = function(f) f:Hide() end
	ChatFrameMenuButton:Hide()
	ChatFrameMenuButton:SetScript("OnShow", kill)
	FriendsMicroButton:Hide()
	FriendsMicroButton:SetScript("OnShow", kill)

	for i=1, 10 do
		local cf = _G[format("%s%d", "ChatFrame", i)]
	--fix fading
		local tab = _G["ChatFrame"..i.."Tab"]
		tab:SetAlpha(0)
		tab.noMouseAlpha = 0
		cf:SetFading(false)
		_G["ChatFrame"..i.."TabText"]:SetFont(C.media.font, 13)
	
	-- Hide chat textures
		for j = 1, #CHAT_FRAME_TEXTURES do
			_G["ChatFrame"..i..CHAT_FRAME_TEXTURES[j]]:SetTexture(nil)
		end
	--Unlimited chatframes resizing
		cf:SetMinResize(0,0)
		cf:SetMaxResize(0,0)
	
	--Allow the chat frame to move to the end of the screen
		cf:SetClampedToScreen(false)
		cf:SetClampRectInsets(0,0,0,0)
	
	--EditBox Module
		local ebParts = {'Left', 'Mid', 'Right'}
		local eb = _G['ChatFrame'..i..'EditBox']
		--local cf = _G[format("%s%d", "ChatFrame", i)]
		for _, ebPart in ipairs(ebParts) do
			_G['ChatFrame'..i..'EditBox'..ebPart]:SetTexture(0, 0, 0, 0)
			local ebed = _G['ChatFrame'..i..'EditBoxFocus'..ebPart]
			ebed:SetTexture(0,0,0,0.8)
			ebed:SetHeight(18)
		end
		eb:SetAltArrowKeyMode(false)
		eb:ClearAllPoints()
		eb:SetPoint("BOTTOMLEFT", cf, "TOPLEFT",  0, 3)
		-- eb:SetPoint("BOTTOMLEFT", UIParent, eb_point[1], eb_point[2], eb_point[3])
		eb:SetPoint("TOPRIGHT", cf, "TOPRIGHT", 0, 31)
		-- eb:SetPoint("BOTTOMRIGHT", UIParent, eb_point[1], eb_point[2]+eb_width, eb_point[3])
		eb:EnableMouse(false)
	
	--Remove scroll buttons
		local bf = _G['ChatFrame'..i..'ButtonFrame']
		bf:Hide()
		bf:SetScript("OnShow",  kill)
	
	--Scroll to the bottom button
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
		cf:SetFont(font, path, 'OUTLINE')
		
		--stupid dropshadow :D
		cf:SetShadowOffset(0, 0)
		cf:SetShadowColor(0, 0, 0, 0)
	end
end

-----------------------------------------------------------------------------
-- Copy on chatframes feature
-----------------------------------------------------------------------------

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

local function CreatCopyFrame()
	frame = CreateFrame("Frame", "CopyFrame", UIParent)
	R.SetBD(frame)
	frame:Height(200)
	frame:SetScale(1)
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	frame:SetSize(400,400)
	frame:Hide()
	frame:EnableMouse(true)
	frame:SetFrameStrata("DIALOG")

	local scrollArea = CreateFrame("ScrollFrame", "CopyScroll", frame, "UIPanelScrollFrameTemplate")
	scrollArea:Point("TOPLEFT", frame, "TOPLEFT", 8, -30)
	scrollArea:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 8)
	
	R.ReskinScroll(CopyScrollScrollBar)

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
	
	R.ReskinClose(close)	
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
		
		local buttontex = button:CreateTexture(nil, 'OVERLAY')
		buttontex:SetPoint('TOPLEFT', button, 'TOPLEFT', 2, -2)
		buttontex:SetPoint('BOTTOMRIGHT', button, 'BOTTOMRIGHT', -2, 2)
		buttontex:SetTexture([[Interface\AddOns\!RayUI\media\copy.tga]])
		
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

---------------- > TellTarget function
local function telltarget(msg)
	if not UnitExists("target") or not (msg and msg:len()>0) or not UnitIsFriend("player","target") then return end
	local name, realm = UnitName("target")
	if realm and not UnitIsSameServer("player", "target") then
		name = ("%s-%s"):format(name, realm)
	end
	SendChatMessage(msg, "WHISPER", nil, name)
end
SlashCmdList["TELLTARGET"] = telltarget
SLASH_TELLTARGET1 = "/tt"
SLASH_TELLTARGET2 = "/ее"
SLASH_TELLTARGET3 = "/wt"

---------------- > URL Copy
local tlds
local style = "|cff8A9DDE|Hurl:%s|h[%s]|h|r"
local tokennum, matchTable = 1, {}

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
	return RegisterMatch(string.format(style, link, link))
end

local function Link_TLD(link, tld, ...)
	if link == nil or tld == nil then
		return ""
	end
	if tlds[tld:upper()] then
        return RegisterMatch(string.format(style, link, link))
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
	--{ pattern = '^(%"[^%"]+%"@[-%w_%%%.]+%.(%a%a+))', matchfunc=Link_TLD},
	--{ pattern = '%f[%S](%"[^%"]+%"@[-%w_%%%.]+%.(%a%a+))', matchfunc=Link_TLD},
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

do
	local defaults = {
		profile = {
			mangleMumble = true,
			mangleTeamspeak = true
		}
	}
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
end

local currentLink
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

tlds = {
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

local OldSetItemRef = SetItemRef
local function URL_SetItemRef(link, text, button, chatFrame)
	if strsub(link, 1, 9) == "RayUIChat" then
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
	elseif (strsub(link, 1, 3) == "url") then
		currentLink = string.sub(link, 5)
		StaticPopup_Show("UrlCopyDialog")
	else
		OldSetItemRef(link, text, button, chatFrame)
	end
end
SetItemRef = URL_SetItemRef

---------------- > Channel names
local newAddMsg = {}

local rplc = {
		"[BG]", --Battleground
		"[BGL]", --Battleground Leader
		"[G]", --Guild
		"[P]", --Party
		"[PL]", --Party Leader
		"[PL]", --Party Leader (Guide)
		"[O]", --Officer
		"[R]", --Raid
		"[RL]", --Raid Leader
		"[RW]", --Raid Warning
	}
local chn = {
		gsub(CHAT_BATTLEGROUND_GET, ".*%[(.*)%].*", "%%[%1%%]"),
		gsub(CHAT_BATTLEGROUND_LEADER_GET, ".*%[(.*)%].*", "%%[%1%%]"),
		gsub(CHAT_GUILD_GET, ".*%[(.*)%].*", "%%[%1%%]"),
		gsub(CHAT_PARTY_GET, ".*%[(.*)%].*", "%%[%1%%]"),
		gsub(CHAT_PARTY_LEADER_GET, ".*%[(.*)%].*", "%%[%1%%]"),
		gsub(CHAT_PARTY_GUIDE_GET, ".*%[(.*)%].*", "%%[%1%%]"),
		gsub(CHAT_OFFICER_GET, ".*%[(.*)%].*", "%%[%1%%]"),
		gsub(CHAT_RAID_GET, ".*%[(.*)%].*", "%%[%1%%]"),
		gsub(CHAT_RAID_LEADER_GET, ".*%[(.*)%].*", "%%[%1%%]"),
		gsub(CHAT_RAID_WARNING_GET, ".*%[(.*)%].*", "%%[%1%%]"),
		gsub(CHAT_BN_CONVERSATION_GET_LINK, ".*%[(.*)%..*%].*", "%%[%1%%]"),
	}

do
	local function AddMessage(frame, text, ...)
		if text:find(INTERFACE_ACTION_BLOCKED) then return end
		if text:find("BN_CONVERSATION") then

		else			
			for i = 1, 10 do
				text = gsub(text, chn[i], rplc[i])
			end
			text = text:gsub("%[(%d0?)%. .-%]", "[%1]") --custom channels
			text = text:gsub("CHANNEL:", "")
		end
		-- text = URL_AddLinkSyntax(text)
		if CHAT_TIMESTAMP_FORMAT and not text:find("|r") then
			text = BetterDate(CHAT_TIMESTAMP_FORMAT, time())..text
		end
		text = string.gsub(text, "%[(%d+)%. .-%]", "[%1]")
		text = ('|cffffffff|HRayUIChat|h|r%s|h %s'):format('|cff'..tscol..''..date('[%H:%M]')..'|r', text)
		return newAddMsg[frame:GetName()](frame, text, ...)
	end
	for i = 1, 5 do
		if _G["ChatFrame"..i] ~= COMBATLOG then -- skip combatlog
			local f = _G[format("%s%d", "ChatFrame", i)]
			newAddMsg[format("%s%d", "ChatFrame", i)] = f.AddMessage
			f.AddMessage = AddMessage
		end
	end
end

---------------- > Enable/Disable mouse for editbox
local function eb_mouseon()
	for i =1, 10 do
		local eb = _G['ChatFrame'..i..'EditBox']
		local tab = _G['ChatFrame'..i..'Tab']
		eb:EnableMouse(true)
		tab:EnableMouse(false)
	end
end
local function  eb_mouseoff()
	for i =1, 10 do
		local eb = _G['ChatFrame'..i..'EditBox']
		local tab = _G['ChatFrame'..i..'Tab']
		eb:EnableMouse(false)
		tab:EnableMouse(true)
	end
end
hooksecurefunc("ChatFrame_OpenChat",eb_mouseon)
hooksecurefunc("ChatEdit_OnShow",eb_mouseon)
hooksecurefunc("ChatEdit_SendText",eb_mouseoff)
hooksecurefunc("ChatEdit_OnHide",eb_mouseoff)

---------------- > Show tooltips when hovering a link in chat (credits to Adys for his LinkHover)
function LinkHover.OnHyperlinkEnter(_this, linkData, link)
	local t = linkData:match("^(.-):")
	if LinkHover.show[t] then
		ShowUIPanel(GameTooltip)
		GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
		GameTooltip:SetHyperlink(link)
		GameTooltip:Show()
	end
end
function LinkHover.OnHyperlinkLeave(_this, linkData, link)
	local t = linkData:match("^(.-):")
	if LinkHover.show[t] then
		HideUIPanel(GameTooltip)
	end
end
local function LinkHoverOnLoad()
	for i = 1, NUM_CHAT_WINDOWS do
		local f = _G["ChatFrame"..i]
		f:SetScript("OnHyperlinkEnter", LinkHover.OnHyperlinkEnter)
		-- f:SetScript("OnHyperlinkLeave", LinkHover.OnHyperlinkLeave)
		f:SetScript("OnHyperlinkLeave", GameTooltip_Hide)
	end
end
LinkHoverOnLoad()

---------------- > Chat Scroll Module
hooksecurefunc('FloatingChatFrame_OnMouseScroll', function(self, dir)
	if dir > 0 then
		if IsShiftKeyDown() then
			self:ScrollToTop()
		elseif IsControlKeyDown() then
			--only need to scroll twice because of blizzards scroll
			self:ScrollUp()
			self:ScrollUp()
		end
	elseif dir < 0 then
		if IsShiftKeyDown() then
			self:ScrollToBottom()
		elseif IsControlKeyDown() then
			--only need to scroll twice because of blizzards scroll
			self:ScrollDown()
			self:ScrollDown()
		end
	end
end)

---------------- > afk/dnd msg filter
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_JOIN", function(msg) return true end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_LEAVE", function(msg) return true end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_NOTICE", function(msg) return true end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_AFK", function(msg) return true end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_DND", function(msg) return true end)

for i = 1, NUM_CHAT_WINDOWS do
	chat = _G[format("ChatFrame%s", i)]:GetName()
	for j = 1, #CHAT_FRAME_TEXTURES do 
		_G[chat..CHAT_FRAME_TEXTURES[j]]:SetTexture(nil) 
	end
	_G[format("ChatFrame%sTabLeft", i)]:SetTexture(nil)
	_G[format("ChatFrame%sTabMiddle", i)]:SetTexture(nil)
	_G[format("ChatFrame%sTabRight", i)]:SetTexture(nil)
	_G[format("ChatFrame%sTabSelectedLeft", i)]:SetTexture(nil)
	_G[format("ChatFrame%sTabSelectedMiddle", i)]:SetTexture(nil)
	_G[format("ChatFrame%sTabSelectedRight", i)]:SetTexture(nil) 
	_G[format("ChatFrame%sTabHighlightLeft", i)]:SetTexture(nil) 
	_G[format("ChatFrame%sTabHighlightMiddle", i)]:SetTexture(nil) 
	_G[format("ChatFrame%sTabHighlightRight", i)]:SetTexture(nil)
	ChatCopyButtons(i)
end

-----------------------------------------------------
-- ChatBackground
-----------------------------------------------------
local ChatBG = CreateFrame("Frame", "ChatBG", UIParent)
ChatBG:CreatePanel("Default", C["chat"].width, C["chat"].height, "BOTTOMLEFT",UIParent,"BOTTOMLEFT",15,30)
GeneralDockManager:SetParent(ChatBG)

for i=1, NUM_CHAT_WINDOWS do
	_G["ChatFrame"..i]:SetParent(ChatBG)
	local ebParts = {'Left', 'Mid', 'Right'}
	for _, ebPart in ipairs(ebParts) do
		_G['ChatFrame'..i..'EditBoxFocus'..ebPart]:SetTexture(0, 0, 0, 0)
		_G['ChatFrame'..i..'EditBoxFocus'..ebPart].SetTexture = function() return end
	end
	local chatebbg = CreateFrame("Frame",nil , _G["ChatFrame"..i.."EditBox"])
	chatebbg:SetPoint("TOPLEFT", -2, -5)
	chatebbg:SetPoint("BOTTOMRIGHT", 2, 4)
	chatebbg:CreateShadow("Background")
	chatebbg.bd = CreateFrame("Frame",nil , chatebbg)
	chatebbg.bd:SetAllPoints()
	chatebbg.bd:CreateBorder()
	_G["ChatFrame"..i.."EditBoxLanguage"]:Kill()
	
	hooksecurefunc("ChatEdit_UpdateHeader", function()
			local type = _G["ChatFrame"..i.."EditBox"]:GetAttribute("chatType")
			if ( type == "CHANNEL" ) then
			local id = GetChannelName(_G["ChatFrame"..i.."EditBox"]:GetAttribute("channelTarget"))
				if id == 0 then
					chatebbg.bd:SetBackdropBorderColor(unpack(C["media"].bordercolor))
				else
					chatebbg.bd:SetBackdropBorderColor(ChatTypeInfo[type..id].r,ChatTypeInfo[type..id].g,ChatTypeInfo[type..id].b)
				end
			else
				chatebbg.bd:SetBackdropBorderColor(ChatTypeInfo[type].r,ChatTypeInfo[type].g,ChatTypeInfo[type].b)
			end
		end)
end

local function SetChatPosition()
	for i = 1, NUM_CHAT_WINDOWS do
		if _G["ChatFrame"..i] == COMBATLOG then
			_G["ChatFrame"..i]:ClearAllPoints()
			_G["ChatFrame"..i]:SetPoint("TOPLEFT", ChatBG, "TOPLEFT", 2, -2 - CombatLogQuickButtonFrame_Custom:GetHeight())
			_G["ChatFrame"..i]:SetPoint("BOTTOMRIGHT", ChatBG, "BOTTOMRIGHT", -2, 4)
		else				
			_G["ChatFrame"..i]:ClearAllPoints()
			_G["ChatFrame"..i]:SetPoint("TOPLEFT", ChatBG, "TOPLEFT", 2, -2)
			_G["ChatFrame"..i]:SetPoint("BOTTOMRIGHT", ChatBG, "BOTTOMRIGHT", -2, 4)
			FCF_SavePositionAndDimensions(_G["ChatFrame"..i])
			local _, _, _, _, _, _, shown, _, docked, _ = GetChatWindowInfo(i)
			if shown and not docked then
				FCF_DockFrame(_G["ChatFrame"..i])
			end
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	SetChatPosition()
	SetCVar("showTimestamps", "none")
	SetCVar("profanityFilter", 0)
	SetCVar("chatStyle", "classic")
end)
f:SetScript("OnUpdate", function(self, elapsed)
	if InCombatLockdown() then return end
	if(self.elapsed and self.elapsed > 1) then
		SetChatPosition()
		self.elapsed = 0
	else
		self.elapsed = (self.elapsed or 0) + elapsed
	end
end)