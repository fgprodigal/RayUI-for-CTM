local R, C, L, DB = unpack(select(2, ...))
if not C["chat"].enable then return end

local AutoApply = true											-- /setchat upon UI loading
--Setchat parameters. Those parameters will apply to ChatFrame1 when you use /setchat
local def_position = {"BOTTOMLEFT",UIParent,"BOTTOMLEFT",10,30} -- Chat Frame position
local chat_height = 140
local chat_width = 400
local fontsize = 15
local fontFlag = "THINOUTLINE"
--other variables
local eb_point = {"BOTTOMLEFT", 10, 165}		-- Editbox position
local eb_width = chat_width						-- Editbox width
local tscol = "64C2F5"						-- Timestamp coloring
local TimeStampsCopy = true
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

---------------- > Function to move and scale chatframes 
function SetChatColor()
	--Adjust Chat Colors
	--General
	ChangeChatColor("CHANNEL1", 195/255, 230/255, 232/255)
	--Trade
	ChangeChatColor("CHANNEL2", 232/255, 158/255, 121/255)
	--Local Defense
	ChangeChatColor("CHANNEL3", 232/255, 228/255, 121/255)
end
SlashCmdList["SETCHATCOLOR"] = SetChatColor
SLASH_SETCHATCOLOR1 = "/setchatcolor"

function SetChat()
    FCF_SetLocked(ChatFrame1, nil)
	FCF_SetChatWindowFontSize(self, ChatFrame1, fontsize) 
    ChatFrame1:ClearAllPoints()
	ChatFrame1:SetPoint("TOPLEFT", ChatBG, "TOPLEFT", 2, -2)
	ChatFrame1:SetPoint("BOTTOMRIGHT", ChatBG, "BOTTOMRIGHT", -2, 4)
    -- ChatFrame1:SetPoint(unpack(def_position))
    -- ChatFrame1:SetWidth(chat_width)
    -- ChatFrame1:SetHeight(chat_height)
    ChatFrame1:SetFrameLevel(8)
    -- ChatFrame1:SetUserPlaced(false)
	for i=1,10 do local cf = _G["ChatFrame"..i] FCF_SetWindowAlpha(cf, 0) end
    FCF_SavePositionAndDimensions(ChatFrame1)
	FCF_SetLocked(ChatFrame1, 1)
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
		eb:SetPoint("TOPRIGHT", cf, "TOPRIGHT", 0, 35)
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
	frame:CreateShadow("Background")
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
	local _, _, _, _, _, _, _, _, docked, _ = GetChatWindowInfo(id)
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

---------------- > Channel names
local gsub = _G.string.gsub
local time = _G.time
local newAddMsg = {}

local chn, rplc
do
	rplc = {
		"[綜合]", --General
		"[交易]", --Trade
		"[世界防務]", --WorldDefense
		"[本地防務]", --LocalDefense
		"[尋求組隊]", --LookingForGroup
		"[公會招募]", --GuildRecruitment
		"[戰場]", --Battleground
		"[戰場領袖]", --Battleground Leader
		"[G]", --Guild
		"[P]", --Party
		"[隊長]", --Party Leader
		"[隊長]", --Party Leader (Guide)
		"[O]", --Officer
		"[Raid]", --Raid
		"[RL]", --Raid Leader
		"[團隊警告]", --Raid Warning
	}
	chn = {
		"%[%d+%. General.-%]",
		"%[%d+%. Trade.-%]",
		"%[%d+%. WorldDefense%]",
		"%[%d+%. LocalDefense.-%]",
		"%[%d+%. LookingForGroup%]",
		"%[%d+%. GuildRecruitment.-%]",
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
	}
	local L = GetLocale()
	if L == "ruRU" then --Russian
		chn[1] = "%[%d+%. Общий.-%]"
		chn[2] = "%[%d+%. Торговля.-%]"
		chn[3] = "%[%d+%. Оборона: глобальный%]" --Defense: Global
		chn[4] = "%[%d+%. Оборона.-%]" --Defense: Zone
		chn[5] = "%[%d+%. Поиск спутников%]"
		chn[6] = "%[%d+%. Гильдии.-%]"
	elseif L == "deDE" then --German
		chn[1] = "%[%d+%. Allgemein.-%]"
		chn[2] = "%[%d+%. Handel.-%]"
		chn[3] = "%[%d+%. Weltverteidigung%]"
		chn[4] = "%[%d+%. LokaleVerteidigung.-%]"
		chn[5] = "%[%d+%. SucheNachGruppe%]"
		chn[6] = "%[%d+%. Gildenrekrutierung.-%]"
	elseif L == "zhTW" then --繁體中文
		chn[1] = "%[%d+%. 綜合-%]"
		chn[2] = "%[%d+%. 交易-%]"
		chn[3] = "%[%d+%. 世界防務%]"
		chn[4] = "%[%d+%. 本地防務-%]"
		chn[5] = "%[%d+%. 尋求組隊%]"
		chn[6] = "%[%d+%. 工會招募-%]"

	end
end
local function AddMessage(frame, text, ...)
	for i = 1, 16 do
		text = gsub(text, chn[i], rplc[i])
	end
	--If Blizz timestamps is enabled, stamp anything it misses
	if CHAT_TIMESTAMP_FORMAT and not text:find("|r") then
		text = BetterDate(CHAT_TIMESTAMP_FORMAT, time())..text
	end
	text = gsub(text, "%[(%d0?)%. .-%]", "[%1]") --custom channels
	return newAddMsg[frame:GetName()](frame, text, ...)
end
do
	for i = 1, 5 do
		if i ~= 2 then -- skip combatlog
			local f = _G[format("%s%d", "ChatFrame", i)]
			newAddMsg[format("%s%d", "ChatFrame", i)] = f.AddMessage
			f.AddMessage = AddMessage
		end
	end
end
---------------- > Enable/Disable mouse for editbox
eb_mouseon = function()
	for i =1, 10 do
		local eb = _G['ChatFrame'..i..'EditBox']
		eb:EnableMouse(true)
	end
end
eb_mouseoff = function()
	for i =1, 10 do
		local eb = _G['ChatFrame'..i..'EditBox']
		eb:EnableMouse(false)
	end
end
hooksecurefunc("ChatFrame_OpenChat",eb_mouseon)
hooksecurefunc("ChatEdit_SendText",eb_mouseoff)

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
		f:SetScript("OnHyperlinkLeave", LinkHover.OnHyperlinkLeave)
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

---------------- > Per-line chat copy via time stamps
if TimeStampsCopy then
	local AddMsg = {}
	local AddMessage = function(frame, text, ...)
		text = string.gsub(text, "%[(%d+)%. .-%]", "[%1]")
		text = ('|cffffffff|Hm_Chat|h|r%s|h %s'):format('|cff'..tscol..''..date('[%H:%M]')..'|r', text)
		return AddMsg[frame:GetName()](frame, text, ...)
	end
	for i = 1, 10 do
		if i ~= 2 then
			AddMsg["ChatFrame"..i] = _G["ChatFrame"..i].AddMessage
			_G["ChatFrame"..i].AddMessage = AddMessage
		end
	end
end

---------------- > URL copy Module
local tlds = {
	"[Cc][Oo][Mm]", "[Uu][Kk]", "[Nn][Ee][Tt]", "[Dd][Ee]", "[Ff][Rr]", "[Ee][Ss]",
	"[Bb][Ee]", "[Cc][Cc]", "[Uu][Ss]", "[Kk][Oo]", "[Cc][Hh]", "[Tt][Ww]",
	"[Cc][Nn]", "[Rr][Uu]", "[Gg][Rr]", "[Ii][Tt]", "[Ee][Uu]", "[Tt][Vv]",
	"[Nn][Ll]", "[Hh][Uu]", "[Oo][Rr][Gg]", "[Ss][Ee]", "[Nn][Oo]", "[Ff][Ii]"
}

local uPatterns = {
	'(http://%S+)',
	'(www%.%S+)',
	'(%d+%.%d+%.%d+%.%d+:?%d*)',
}

local cTypes = {
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_YELL",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_SAY",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BN_CONVERSATION",
}

for _, event in pairs(cTypes) do
	ChatFrame_AddMessageEventFilter(event, function(self, event, text, ...)
		for i=1, 24 do
			local result, matches = string.gsub(text, "(%S-%."..tlds[i].."/?%S*)", "|cff8A9DDE|Hurl:%1|h[%1]|h|r")
			if matches > 0 then
				return false, result, ...
			end
		end
 		for _, pattern in pairs(uPatterns) do
			local result, matches = string.gsub(text, pattern, '|cff8A9DDE|Hurl:%1|h[%1]|h|r')
			if matches > 0 then
				return false, result, ...
			end
		end 
	end)
end

local GetText = function(...)
	for l = 1, select("#", ...) do
		local obj = select(l, ...)
		if obj:GetObjectType() == "FontString" and obj:IsMouseOver() then
			return obj:GetText()
		end
	end
end

local SetIRef = SetItemRef
SetItemRef = function(link, text, ...)
	local txt, frame
	if link:sub(1, 6) == 'm_Chat' then
		frame = GetMouseFocus():GetParent()
		txt = GetText(frame:GetRegions())
		txt = txt:gsub("|c%x%x%x%x%x%x%x%x(.-)|r", "%1")
		txt = txt:gsub("|H.-|h(.-)|h", "%1")
	elseif link:sub(1, 3) == 'url' then
		frame = GetMouseFocus():GetParent()
		txt = link:sub(5)
	end
	if txt then
		local editbox
		if GetCVar('chatStyle') == 'classic' then
			editbox = LAST_ACTIVE_CHAT_EDIT_BOX
		else
			editbox = _G['ChatFrame'..frame:GetID()..'EditBox']
		end
		editbox:Show()
		editbox:Insert(txt)
		editbox:HighlightText()
		editbox:SetFocus()
		return
	end
	return SetIRef(link, text, ...)
end

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
SetCVar("chatStyle", "classic")

local ChatBG = CreateFrame("Frame", "ChatBG", UIParent)
ChatBG:CreatePanel("Default", C["chat"].width, C["chat"].height, "BOTTOMLEFT",UIParent,"BOTTOMLEFT",15,30)
GeneralDockManager:SetParent(ChatBG)

for i=1,NUM_CHAT_WINDOWS do
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
	chatebbg.bd:SetPoint("TOPLEFT", 2, -2)
	chatebbg.bd:SetPoint("BOTTOMRIGHT", -2, 2)
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
		
local ChatPosUpdate = CreateFrame("Frame")
ChatPosUpdate:SetScript("OnUpdate", function(self, elapsed)
	if(self.elapsed and self.elapsed > 1) then
		for i=1,NUM_CHAT_WINDOWS do
			if _G["ChatFrame"..i] == COMBATLOG then
				_G["ChatFrame"..i]:ClearAllPoints(ChatBG)
				_G["ChatFrame"..i]:SetPoint("TOPLEFT", ChatBG, "TOPLEFT", 2, -2 - CombatLogQuickButtonFrame_Custom:GetHeight())
				_G["ChatFrame"..i]:SetPoint("BOTTOMRIGHT", ChatBG, "BOTTOMRIGHT", -2, 4)
			else				
				_G["ChatFrame"..i]:ClearAllPoints(ChatBG)
				_G["ChatFrame"..i]:SetPoint("TOPLEFT", ChatBG, "TOPLEFT", 2, -2)
				_G["ChatFrame"..i]:SetPoint("BOTTOMRIGHT", ChatBG, "BOTTOMRIGHT", -2, 4)
			end
		end
	else
		self.elapsed = (self.elapsed or 0) + elapsed
	end
end)