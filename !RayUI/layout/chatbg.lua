local R, C, L, DB = unpack(select(2, ...))
-----------------------------------------------------
-- ChatBackground
-----------------------------------------------------
SetCVar("chatStyle", "classic")

local ChatBG = CreateFrame("Frame", "ChatBG", UIParent)
ChatBG:CreatePanel("Default", 400, 140, "BOTTOMLEFT",UIParent,"BOTTOMLEFT",15,30)
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