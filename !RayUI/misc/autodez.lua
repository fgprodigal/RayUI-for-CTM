local R, C, L, DB = unpack(select(2, ...))

local autogreed = CreateFrame("frame")
autogreed:RegisterEvent("START_LOOT_ROLL")
autogreed:SetScript("OnEvent", function(self, event, id)
	local name = select(2, GetLootRollItemInfo(id))
	
	--Auto Need Chaos Orb
	if (name == select(1, GetItemInfo(52078))) then
		RollOnLoot(id, 1)
	end
	
	if R.level ~= MAX_PLAYER_LEVEL then return end
	if(id and select(4, GetLootRollItemInfo(id))==2 and not (select(5, GetLootRollItemInfo(id)))) then
		if RollOnLoot(id, 3) then
			RollOnLoot(id, 3)
		else
			RollOnLoot(id, 2)
		end
	end
end)
