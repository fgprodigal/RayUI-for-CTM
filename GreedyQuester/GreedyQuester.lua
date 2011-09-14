local frame = CreateFrame("FRAME", "GreedyQuester", UIParent)
frame:RegisterEvent("QUEST_COMPLETE")
frame:SetScript("OnEvent", function() 
  local max, max_index = 0, 0
  for x=1,GetNumQuestChoices() do 
    local item = GetQuestItemLink("choice", x)
    if item then
      local price = select(11, GetItemInfo(item))
      if price > max then
        max, max_index = price, x
      end
    end
  end
  local button = _G["QuestInfoItem"..max_index]
  if button then button:Click() end
end)