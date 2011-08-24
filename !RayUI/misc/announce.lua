local R, C, DB = unpack(select(2, ...))

local announceinterrupt = "PARTY"
local announce = CreateFrame("Frame")
announce:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
announce:SetScript("OnEvent", function(self, _, _, event, _, _, sourceName, _, _, destName, _, _, _, _, spellID, spellName)
	if not (event == "SPELL_INTERRUPT" and (sourceName == UnitName("player") or sourceName == UnitName("pet"))) then return end
	
	
	if announceinterrupt == "PARTY" then
		if GetRealNumPartyMembers() > 0 then
			SendChatMessage(INTERRUPT.." "..destName.."的 \124cff71d5ff\124Hspell:"..spellID.."\124h["..spellName.."]\124h\124r!", "PARTY", nil, nil)
		end
	elseif announceinterrupt == "RAID" then
		if GetRealNumRaidMembers() > 0 then
			SendChatMessage(INTERRUPT.." "..destName.."的 \124cff71d5ff\124Hspell:"..spellID.."\124h["..spellName.."]\124h\124r!", "RAID", nil, nil)		
		elseif GetRealNumPartyMembers() > 0 then
			SendChatMessage(INTERRUPT.." "..destName.."的 \124cff71d5ff\124Hspell:"..spellID.."\124h["..spellName.."]\124h\124r!", "PARTY", nil, nil)
		end	
	elseif announceinterrupt == "SAY" then
		if GetRealNumRaidMembers() > 0 then
			SendChatMessage(INTERRUPT.." "..destName.."的 \124cff71d5ff\124Hspell:"..spellID.."\124h["..spellName.."]\124h\124r!", "SAY", nil, nil)		
	elseif GetRealNumPartyMembers() > 0 then
			SendChatMessage(INTERRUPT.." "..destName.."的 \124cff71d5ff\124Hspell:"..spellID.."\124h["..spellName.."]\124h\124r!",  "SAY", nil, nil)
		end		
	end
end)