local AFP_LINES = 10;
afp_OriginalAuctionFrameBrowse_Update = nil;
afp_BrowseList = {};
local afp_OldSetWidth = nil;
local shutdown = nil; --- use it to shut us down for compatibility reasons (string "reason")

function AuctionFilterPlus_OnLoad(self)
	self:RegisterEvent("AUCTION_ITEM_LIST_UPDATE");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("AUCTION_HOUSE_SHOW");
	-- Set localization for buttons (NOW DONE INTERNALLY)
	-- if (afp_FlyoutButton) then afp_FlyoutButton:SetText(AFP_BUTTON_TEXT_FILTER); end
	SlashCmdList["AUCTIONFILTERPLUS"] = afp_SlashHandler;
	SLASH_AUCTIONFILTERPLUS1 = "/auctionfilterplus"; -- Fixed by Aingnale@WorldOfWar
	SLASH_AUCTIONFILTERPLUS2 = "/afp";

	SlashCmdList["AUCTIONFILTERPLUSBUTTONS"] = afp_SlashHandlerSetButton;
	SLASH_AUCTIONFILTERPLUSBUTTONS1 = "/afpsetbutton";
	SLASH_AUCTIONFILTERPLUSBUTTONS2 = "/setbutton";
end

function AuctionFilterPlus_OnEvent(self, event, ...)

	if (event == "AUCTION_ITEM_LIST_UPDATE") then
		if shutdown then return end
		afp_AuctionFrameBrowse_Update();

	elseif event == "VARIABLES_LOADED" then
		afp_FlyoutLoad_OnClick();

	elseif (event == "AUCTION_HOUSE_SHOW") then
		--- Shutdown if Auc-Advanced 5.x has the Compact UI enabled.
		if ( AucAdvanced and AucAdvanced.Settings and AucAdvanced.Settings.GetSetting("util.compactui.activated") ) then
			shutdown = "AucAdvanced5-CompactUI Enabled.";
		end

		--- if we have a reason to abort inform the user and shutdown
		if shutdown then
			afp_Print("Shutting down. Reason: "..shutdown);
			return;
		end;

		if (not afp_OriginalAuctionFrameBrowse_Update) then
			afp_FlyoutLoad_OnClick();

			afp_OriginalAuctionFrameBrowse_Update = AuctionFrameBrowse_Update;
			AuctionFrameBrowse_Update = afp_AuctionFrameBrowse_Update;

			afp_OriginalBrowseButton_OnClick = BrowseButton_OnClick;
			BrowseButton_OnClick = afp_BrowseButton_OnClick;

			afp_OriginalAuctionFrameItem_OnEnter = AuctionFrameItem_OnEnter;
			AuctionFrameItem_OnEnter = afp_AuctionFrameItem_OnEnter;

			afp_OptionButton_PricePerUnit:SetParent(afp_FlyoutFrame);
			afp_OptionButton_HideNoBuyout:SetParent(afp_FlyoutFrame);
			afp_OptionButton_HideUnaffordable:SetParent(afp_FlyoutFrame);
			afp_OptionButton_StacksOf20:SetParent(afp_FlyoutFrame);
			afp_OptionButton_ExactName:SetParent(afp_FlyoutFrame);
			afp_OptionButton_GreyUnbid:SetParent(afp_FlyoutFrame);

			afp_FlyoutButton:ClearAllPoints()
			afp_FlyoutButton:SetParent(AuctionFrameBrowse);
			afp_FlyoutButton:SetPoint("LEFT","BrowseSearchButton","RIGHT", 2, 0);
			afp_FlyoutButton:Show();

			if (AH_ResetButton and AH_ResetButton:IsVisible()) then
				AH_ResetButton:Hide();
			end

			afp_FlyoutButton_OnClick();
		end
	end
end

function afp_SetWidth(obj, width)
  afp_OldSetWidth(obj, width);
end

function SortBuyoutButton_UpdateArrow(button, type, sort)
	if ( not IsAuctionSortReversed(type, sort) ) then
		getglobal(button:GetName().."Arrow"):SetTexCoord(0, 0.5625, 1.0, 0);
	else
		getglobal(button:GetName().."Arrow"):SetTexCoord(0, 0.5625, 0, 1.0);
	end
end

function afp_FixParents()
	afp_OptionText_HideUnaffordable:ClearAllPoints()
	afp_OptionText_HideNoBuyout:ClearAllPoints()
	afp_OptionText_PricePerUnit:ClearAllPoints()
	afp_OptionText_StacksOf20:ClearAllPoints()
	afp_OptionText_ExactName:ClearAllPoints()
	afp_OptionText_GreyUnbid:ClearAllPoints()

	afp_OptionText_HideUnaffordable:SetPoint("LEFT","afp_OptionButton_HideUnaffordable","RIGHT",2,1);
	afp_OptionText_HideNoBuyout:SetPoint("LEFT","afp_OptionButton_HideNoBuyout","RIGHT",2,1);
	afp_OptionText_PricePerUnit:SetPoint("LEFT","afp_OptionButton_PricePerUnit","RIGHT",2,1);
	afp_OptionText_StacksOf20:SetPoint("LEFT","afp_OptionButton_StacksOf20","RIGHT",2,1);
	afp_OptionText_ExactName:SetPoint("LEFT","afp_OptionButton_ExactName","RIGHT",2,1);
	afp_OptionText_GreyUnbid:SetPoint("LEFT","afp_OptionButton_GreyUnbid","RIGHT",2,1);
end

function afp_Tooltip(arg1,arg2,arg3,arg4,arg5,arg6)
	if (not arg3) then arg3 = "ANCHOR_LEFT"; end
	if (not arg4) then arg4 = 0; end
	if (not arg5) then arg5 = -40; end
	if (not arg6) then arg6 = afp_FlyoutFrame; end -- can use the reserved word "this" as arg6 if you want
	GameTooltip:SetOwner(arg6, arg3, arg4, arg5);
  GameTooltip:SetText(arg1);
  GameTooltip:AddLine("\n"..arg2, .75, .75, .75, 1);
  GameTooltip:Show();
end

function afp_AuctionFrameBrowse_OnEnter(self)
	local frame = self:GetName();
	if (not frame) then return; end
	if (frame == "afp_OptionButton_HideUnaffordable") then
		afp_Tooltip(AFP_TOOLTIP_TITLE_UNAFFORD, AFP_TOOLTIP_TEXT_UNAFFORD);
	elseif (frame == "afp_OptionButton_HideNoBuyout") then
		afp_Tooltip(AFP_TOOLTIP_TITLE_NOBUYOUT, AFP_TOOLTIP_TEXT_NOBUYOUT);
	elseif (frame == "afp_OptionButton_PricePerUnit") then
		afp_Tooltip(AFP_TOOLTIP_TITLE_PERUNIT, AFP_TOOLTIP_TEXT_PERUNIT);
	elseif (frame == "afp_OptionButton_StacksOf20") then
		afp_Tooltip(AFP_TOOLTIP_TITLE_STACK20, AFP_TOOLTIP_TEXT_STACK20);
	elseif (frame == "afp_OptionButton_ExactName") then
		afp_Tooltip(AFP_TOOLTIP_TITLE_EXACTNAME, AFP_TOOLTIP_TEXT_EXACTNAME);
	elseif (frame == "afp_OptionButton_GreyUnbid") then
		afp_Tooltip(AFP_TOOLTIP_TITLE_GREYUNBID, AFP_TOOLTIP_TEXT_GREYUNBID);
	end
end

function afp_FlyoutClear_OnClick()
	afp_OptionButton_PricePerUnit:SetChecked(0);
	afp_OptionButton_HideNoBuyout:SetChecked(0);
	afp_OptionButton_HideUnaffordable:SetChecked(0);
	afp_OptionButton_StacksOf20:SetChecked(0);
	afp_OptionButton_ExactName:SetChecked(0);
	afp_OptionButton_GreyUnbid:SetChecked(0);
	afp_Print(AFP_OPTEXT_CLEARED);
end

function afp_FlyoutSave_OnClick()
	afp_SavedSettings = {};
	afp_SavedSettings["afp_OptionButton_PricePerUnit"] = afp_OptionButton_PricePerUnit:GetChecked();
	afp_SavedSettings["afp_OptionButton_HideNoBuyout"] = afp_OptionButton_HideNoBuyout:GetChecked();
	afp_SavedSettings["afp_OptionButton_HideUnaffordable"] = afp_OptionButton_HideUnaffordable:GetChecked();
	afp_SavedSettings["afp_OptionButton_StacksOf20"] = afp_OptionButton_StacksOf20:GetChecked();
	afp_SavedSettings["afp_OptionButton_ExactName"] = afp_OptionButton_ExactName:GetChecked();
	afp_SavedSettings["afp_OptionButton_GreyUnbid"] = afp_OptionButton_GreyUnbid:GetChecked();
	afp_Print(AFP_OPTEXT_SAVED);
end

function afp_FlyoutLoad_OnClick()
	if (afp_SavedSettings) then
		if (afp_SavedSettings["afp_OptionButton_PricePerUnit"]) then
			afp_OptionButton_PricePerUnit:SetChecked(afp_SavedSettings["afp_OptionButton_PricePerUnit"]);
		end
		if (afp_SavedSettings["afp_OptionButton_HideNoBuyout"]) then
			afp_OptionButton_HideNoBuyout:SetChecked(afp_SavedSettings["afp_OptionButton_HideNoBuyout"]);
		end
		if (afp_SavedSettings["afp_OptionButton_HideUnaffordable"]) then
			afp_OptionButton_HideUnaffordable:SetChecked(afp_SavedSettings["afp_OptionButton_HideUnaffordable"]);
		end
		if (afp_SavedSettings["afp_OptionButton_StacksOf20"]) then
			afp_OptionButton_StacksOf20:SetChecked(afp_SavedSettings["afp_OptionButton_StacksOf20"]);
		end
		if (afp_SavedSettings["afp_OptionButton_ExactName"]) then
			afp_OptionButton_ExactName:SetChecked(afp_SavedSettings["afp_OptionButton_ExactName"]);
		end
		if (afp_SavedSettings["afp_OptionButton_GreyUnbid"]) then
			afp_OptionButton_GreyUnbid:SetChecked(afp_SavedSettings["afp_OptionButton_GreyUnbid"]);
		end
	end
end

function afp_AuctionFrameBrowse_Update()

	--- Auctioneer Advanced 5.x
	if (AucAdvanced and AucAdvanced.Scan and AucAdvanced.Scan.IsScanning()) then
		return;
	end
	--- Auctioneer + Auctioneer Advanced 4.x
	if ((Auctioneer_isScanningRequested and Auctioneer_isScanningRequested==true) or (Auctioneer and Auctioneer.Scanning and Auctioneer.Scanning.IsScanningRequested and Auctioneer.Scanning.IsScanningRequested==true) ) then
		return;
	end
	-- Trap for, and prevent, filters from doing anything while KCI is scanning.
	if (KC_ItemsAuction and KC_ItemsAuction.scanning) then
		return;
	end

	local numBatchAuctions, totalAuctions = GetNumAuctionItems("list");
	local button, buttonName, iconTexture, itemName, color, itemCount, moneyFrame, buyoutMoneyFrame, buyoutText, buttonHighlight;
	local offset = FauxScrollFrame_GetOffset(BrowseScrollFrame);
	local index;
	local isLastSlotEmpty;
	local name, texture, count, quality, canUse, minBid, minIncrement, buyoutPrice, duration, bidAmount, highBidder, owner;
	BrowseBidButton:Disable();
	BrowseBuyoutButton:Disable();
	-- Update sort arrows
	SortButton_UpdateArrow(BrowseQualitySort, "list", "quality");
	SortButton_UpdateArrow(BrowseLevelSort, "list", "level");
	SortButton_UpdateArrow(BrowseDurationSort, "list", "duration");
	SortButton_UpdateArrow(BrowseHighBidderSort, "list", "seller");
	SortButton_UpdateArrow(BrowseCurrentBidSort, "list", "buyoutthenbid");

	-- Show the no results text if no items found
	if ( numBatchAuctions == 0 ) then
		BrowseNoResultsText:Show();
	else
		BrowseNoResultsText:Hide();
	end

	local baseAve = 0; bestAve = 0; worstAve = 0;
	local baseAveTable = {};
	-- Get the highest non-outlier value (only when Exact Name is turned on)
	if (table.getn(baseAveTable) > 0) then
		table.sort(baseAveTable);
		baseAve = baseAveTable[math.floor(table.getn(baseAveTable)/2)];
		bestAve = baseAveTable[1];
		worstAve = baseAveTable[table.getn(baseAveTable)];
--afp_Print("baseAveTable rows="..table.getn(baseAveTable)..", baseAve="..baseAve..", bestAve="..bestAve..", worstAve="..worstAve);
	end
	if (not baseAve) then baseAve = 0; end

	for i=1, NUM_BROWSE_TO_DISPLAY do
		if (afp_OptionButton_HideNoBuyout:GetChecked() or afp_OptionButton_HideUnaffordable:GetChecked() or  afp_OptionButton_GreyUnbid:GetChecked()) then
			local skipItem;
			for n=1,NUM_AUCTION_ITEMS_PER_PAGE do
				name,_,count,quality,_,_,_,_,_,buyoutPrice,_,_,owner =  GetAuctionItemInfo("list", offset + i); -- name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner
				skipItem = 0;
				if ((buyoutPrice == 0) and (afp_OptionButton_HideNoBuyout:GetChecked())) then
					skipItem = 1;
				end
				if ((GetMoney() < buyoutPrice) and (afp_OptionButton_HideUnaffordable:GetChecked())) then
					skipItem = 1;
				end
				if afp_OptionButton_StacksOf20:GetChecked() then
					local showstack = 0;
					if (count == 20 and afp_OptionButton_StacksOf20:GetChecked()) then
						showstack = 1;
					end
					if (showstack == 0) then
						skipItem = 1;
					end
				end
				if (BrowseName and name and BrowseName:GetText() ~= "" and string.lower(name) ~= string.lower(BrowseName:GetText()) and afp_OptionButton_ExactName:GetChecked()) then
					skipItem = 1;
				end
				if (skipItem == 1) then
					offset = offset + 1;
				else
					afp_BrowseList[i] = offset;
				end
			end
		else
			for n=1,NUM_BROWSE_TO_DISPLAY do
				afp_BrowseList[n] = offset;
			end
		end
		index = offset + i + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page);
		button = getglobal("BrowseButton"..i);
		-- Show or hide auction buttons
		if ( index > (numBatchAuctions + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page)) ) then
			button:Hide();
			--button:SetVertexColor(0,0,0);
			-- If the last button is empty then set isLastSlotEmpty var
			if ( i == NUM_BROWSE_TO_DISPLAY ) then
				isLastSlotEmpty = 1;
			end
		else -- EMERALD: BlackOut (if skipItem==1 then BlackOut)
			button:Show();
			buttonName = "BrowseButton"..i;
			name, texture, count, quality, canUse, level, _, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner =  GetAuctionItemInfo("list", offset + i);
			if ( not name ) then	--Bug  145328
				button:Hide();
				-- If the last button is empty then set isLastSlotEmpty var
				isLastSlotEmpty = (i == NUM_BROWSE_TO_DISPLAY);
			end
			duration = GetAuctionItemTimeLeft("list", offset + i);
			-- Resize button if there isn't a scrollbar
			buttonHighlight = getglobal("BrowseButton"..i.."Highlight");
			if ( numBatchAuctions <= NUM_BROWSE_TO_DISPLAY ) then
				button:SetWidth(625);
				buttonHighlight:SetWidth(589);
				BrowseCurrentBidSort:SetWidth(207);
			elseif ( numBatchAuctions == NUM_BROWSE_TO_DISPLAY and totalAuctions <= NUM_BROWSE_TO_DISPLAY ) then
				button:SetWidth(625);
				buttonHighlight:SetWidth(589);
				BrowseCurrentBidSort:SetWidth(207);
			else
				button:SetWidth(600);
				buttonHighlight:SetWidth(562);
				BrowseCurrentBidSort:SetWidth(184);
			end
			-- Set name and quality color
			color = ITEM_QUALITY_COLORS[quality];
			itemName = getglobal(buttonName.."Name");
			local newName;
			local thisPrice = 0;
			local thisCount = 0;
			if (name) then
			newName = GetHex(color.r,color.g,color.b)..name..FONT_COLOR_CODE_CLOSE;
			itemName:SetText(newName);
			end	-- ends: if (name) then
			-- Set level
			if ( level > UnitLevel("player") ) then
				getglobal(buttonName.."Level"):SetText(RED_FONT_COLOR_CODE..level..FONT_COLOR_CODE_CLOSE);
			else
				getglobal(buttonName.."Level"):SetText(level);
			end
			-- Set closing time
			getglobal(buttonName.."ClosingTimeText"):SetText(AuctionFrame_GetTimeLeftText(duration));
			getglobal(buttonName.."ClosingTime").tooltip = AuctionFrame_GetTimeLeftTooltipText(duration);
			-- Set item texture, count, and usability
			iconTexture = getglobal(buttonName.."ItemIconTexture");
			iconTexture:SetTexture(texture);
			if ( not canUse ) then
				iconTexture:SetVertexColor(1.0, 0.1, 0.1);
			else
				iconTexture:SetVertexColor(1.0, 1.0, 1.0);
			end
			itemCount = getglobal(buttonName.."ItemCount");
			if ( count > 1 ) then
				itemCount:SetText(count);
				itemCount:Show();
			else
				itemCount:Hide();
			end
			-- Set high bid
			moneyFrame = getglobal(buttonName.."MoneyFrame");
			yourBidText = getglobal(buttonName.."YourBidText");
-- bee
			--buyoutMoneyFrame = getglobal(buttonName.."BuyoutMoneyFrame");
			buyoutFrame = getglobal(buttonName.."BuyoutFrame");
			buyoutMoneyFrame  = getglobal(buyoutFrame:GetName().."Money");
-- bee end

			--buyoutText = getglobal(buttonName.."BuyoutText");
			-- If not bidAmount set the bid amount to the min bid
			if ( bidAmount > 0 ) then
				if (afp_OptionButton_PricePerUnit:GetChecked()) then
					MoneyFrame_Update(moneyFrame:GetName(), afp_Round(bidAmount/count));
				else
					MoneyFrame_Update(moneyFrame:GetName(), bidAmount);
				end
				if (afp_OptionButton_GreyUnbid:GetChecked()) then -- myShowBid functionality
					moneyFrame:SetAlpha(1.0);
				else
					moneyFrame:SetAlpha(1.0);
				end
                getMoney = string.format("%.0f", bidAmount);
			else
				if (afp_OptionButton_PricePerUnit:GetChecked()) then
					MoneyFrame_Update(moneyFrame:GetName(), afp_Round(minBid/count));
				else
					MoneyFrame_Update(moneyFrame:GetName(), minBid);
				end
				if (afp_OptionButton_GreyUnbid:GetChecked()) then -- myShowBid functionality
					moneyFrame:SetAlpha(0.4);
				else
					moneyFrame:SetAlpha(1.0);
				end
				getMoney = string.format("%.0f", minBid);
			end

			if (afp_OptionButton_PricePerUnit:GetChecked()) then
				-- PricePerUnit notification added to itemname
				newName = GetHex(1,1,0).."[PPU] "..FONT_COLOR_CODE_CLOSE..newName;
				itemName:SetText(newName);
			end
			if ( highBidder ) then
				yourBidText:Show();
			else
				yourBidText:Hide();
			end

			if ( buyoutPrice > 0 ) then
				moneyFrame:SetPoint("RIGHT", buttonName, "RIGHT", 10, 10);
				if (afp_OptionButton_PricePerUnit:GetChecked()) then
					MoneyFrame_Update(buyoutMoneyFrame:GetName(), afp_Round(buyoutPrice/count));
				else
					MoneyFrame_Update(buyoutMoneyFrame:GetName(), buyoutPrice);
				end
				buyoutMoneyFrame:Show();
				--buyoutText:Show();
                getMoney = string.format("%.0f", buyoutPrice);
			else
				moneyFrame:SetPoint("RIGHT", buttonName, "RIGHT", 10, 3);
				buyoutMoneyFrame:Hide();
				--buyoutText:Hide();
			end

			getglobal(buttonName.."HighBidder"):SetText(owner);

			-- Set highlight
			if ( GetSelectedAuctionItem("list") and (offset + i) == GetSelectedAuctionItem("list") ) then
				button:LockHighlight();

				if ( buyoutPrice > 0 and buyoutPrice >= minBid and GetMoney() >= buyoutPrice ) then
					BrowseBuyoutButton:Enable();
					AuctionFrame.buyoutPrice = buyoutPrice;
				else
					AuctionFrame.buyoutPrice = nil;
				end
				-- Set bid
				if ( bidAmount > 0 ) then
					bidAmount = bidAmount + minIncrement ;
					MoneyInputFrame_SetCopper(BrowseBidPrice, bidAmount);
				else
					MoneyInputFrame_SetCopper(BrowseBidPrice, minBid);
				end

				if ( not highBidder and GetMoney() >= MoneyInputFrame_GetCopper(BrowseBidPrice) ) then
					BrowseBidButton:Enable();
				end
			else
				button:UnlockHighlight();
			end

		end
	end

	-- Update scrollFrame
	-- If more than one page of auctions show the next and prev arrows when the scrollframe is scrolled all the way down
	if ( totalAuctions > NUM_AUCTION_ITEMS_PER_PAGE ) then
		if ( isLastSlotEmpty ) then
			BrowsePrevPageButton:Show();
			BrowseNextPageButton:Show();
			BrowseSearchCountText:Show();
			local itemsMin = AuctionFrameBrowse.page * NUM_AUCTION_ITEMS_PER_PAGE + 1;
			local itemsMax = itemsMin + numBatchAuctions - 1;
			BrowseSearchCountText:SetText(format(NUMBER_OF_RESULTS_TEMPLATE, itemsMin, itemsMax, totalAuctions ));
			if ( AuctionFrameBrowse.page == 0 ) then
				BrowsePrevPageButton.isEnabled = nil;
			else
				BrowsePrevPageButton.isEnabled = 1;
			end
			if ( AuctionFrameBrowse.page == (ceil(totalAuctions/NUM_AUCTION_ITEMS_PER_PAGE) - 1) ) then
				BrowseNextPageButton.isEnabled = nil;
			else
				BrowseNextPageButton.isEnabled = 1;
			end
		else
			BrowsePrevPageButton:Hide();
			BrowseNextPageButton:Hide();
			BrowseSearchCountText:Hide();
		end

		-- Artifically inflate the number of results so the scrollbar scrolls one extra row
		numBatchAuctions = numBatchAuctions + 1;
	else
		BrowsePrevPageButton:Hide();
		BrowseNextPageButton:Hide();
		BrowseSearchCountText:Hide();
	end
	FauxScrollFrame_Update(BrowseScrollFrame, numBatchAuctions, NUM_BROWSE_TO_DISPLAY, AUCTIONS_BUTTON_HEIGHT);
end

function afp_BrowseButton_OnClick(button)
	if ( not button ) then
		return
	end
	--afp_Print("OnClick");
	--if ( IsControlKeyDown() ) then -- Dressing Room (THIS DOESN'T WORK, and I don't know why)
		--DressUpItemLink(GetAuctionItemLink("list", button:GetID() + afp_BrowseList[button:GetID()]));
		--afp_Print("DressUpItemLink");
	--elseif ( IsShiftKeyDown() ) then -- Text link
		--if ( ChatFrameEditBox:IsVisible() ) then
			--ChatFrameEditBox:Insert(GetAuctionItemLink("list", button:GetID() + afp_BrowseList[button:GetID()]));
			--afp_Print("ChatFrameEditBox");
		--end
	--else
		SetSelectedAuctionItem("list", button:GetID() + afp_BrowseList[button:GetID()]);
		afp_AuctionFrameBrowse_Update();
		--afp_Print("Else");
	--end
end

function afp_AuctionFrameItem_OnEnter(self, type, index)
	if (self:GetParent():GetID()) then -- EMERALD: Test
		index = self:GetParent():GetID();
	end

	--- 2.4 workaround for Blizzard messing up button properties when browsing the list
	--- check if it's still needed after next patch
	if ( type == "list" ) then
		if (afp_BrowseList and afp_BrowseList[self:GetParent():GetID()]) then
			index = index + afp_BrowseList[self:GetParent():GetID()];
			local button = getglobal("BrowseButton"..self:GetParent():GetID());
			if button then
				local _, _, count, _, _, _, _, _, _, buyoutPrice, bidAmount, _, _ =  GetAuctionItemInfo(type, index);
				button.itemCount = count;
				button.bidAmount = bidAmount;
				button.buyoutPrice = buyoutPrice;
				setglobal(button:GetName(), button);
			end
		end
	elseif ( type == "bidder" ) then
		local button = getglobal("BidButton"..self:GetParent():GetID());
		if button then
			setglobal(button:GetName(), button);
		end
	elseif ( type == "owner" ) then
		local button = getglobal(""..self:GetParent():GetID());
		if button then
			setglobal(button:GetName(), button);
		end
	end
	--- end workaround : Check again if button.itemCount is properly scoped on next Patch
	--- and remove this block of code

  afp_OriginalAuctionFrameItem_OnEnter(self, type, index);
end

function afp_FlyoutButton_OnClick()
	if (afp_FlyoutButton and afp_FlyoutButton:IsVisible()) then
		if (afp_FlyoutFrame and afp_FlyoutFrame:IsVisible()) then
			afp_FlyoutFrame:Hide();
			afp_FlyoutClear:Hide();
			afp_FlyoutSave:Hide();
			afp_FlyoutButtonTexture:SetTexture("Interface\\AddOns\\RayUI\\media\\arrow-right-active")
			--afp_Print("afDEBUG: Hiding Flyout");
		elseif (afp_FlyoutFrame) then
			--CHANGE SIZE BASED ON NUMBER OF VISIBLE LINES (height=lines*19)
			afp_FlyoutFrame:SetHeight(AFP_LINES*19); -- Currently: 11 Lines
            if (MailTo_AuctionableFrame and MailTo_AuctionableFrame:IsVisible()) then
                afp_FlyoutFrame:SetParent(MailTo_AuctionableFrame);
                afp_FlyoutFrame:SetPoint("TOPLEFT","MailTo_AuctionableFrame","TOPRIGHT",-25,-13);
            else
                afp_FlyoutFrame:SetParent(AuctionFrameBrowse);
                afp_FlyoutFrame:SetPoint("TOPLEFT","AuctionFrame","TOPRIGHT", 2, -8);
            end
			--afp_FlyoutFrame:SetPoint("TOPLEFT","AuctionFrameBrowse","TOPRIGHT",70,40);
			afp_FlyoutFrame:Show();
			afp_FlyoutClear:SetParent(afp_FlyoutFrame);
			afp_FlyoutClear:SetPoint("BOTTOMLEFT","afp_FlyoutFrame","BOTTOMLEFT",5, 27);
			afp_FlyoutClear:Show();
			afp_FlyoutSave:SetParent(afp_FlyoutFrame);
			afp_FlyoutSave:SetPoint("BOTTOMRIGHT","afp_FlyoutFrame","BOTTOMRIGHT",-5,5);
			afp_FlyoutSave:Show();
			afp_FlyoutLoad:SetParent(afp_FlyoutFrame);
			afp_FlyoutLoad:ClearAllPoints()
			afp_FlyoutLoad:SetPoint("BOTTOMRIGHT","afp_FlyoutFrame","BOTTOMRIGHT",-100,5);
			afp_FlyoutLoad:Show();
			afp_FlyoutButtonTexture:SetTexture("Interface\\AddOns\\RayUI\\media\\arrow-left-active")
			--afp_Print("afDEBUG: Showing Flyout");
		else
			--afp_Print("afDEBUG: ERROR: NO STATE!");
		end
	end
end

--[[ COMMON FUNCTIONS ]]

function afp_SlashHandler(msg)
	if (msg=="show" or msg=="hide") then msg = ""; end
	if (not msg or msg=="") then
		--Base command
		if (afp_FlyoutButton and afp_FlyoutButton:IsVisible()) then
			afp_FlyoutButton_OnClick();
		else
			afp_Print("The Flyout cannot be shown if the Auction window is not on the Browse tab.");
		end
	end
end

function afp_Print(message) -- Send Message to Chat Frame
	if message then
		message = "|cffffff33"..message.."|r";
	else
		message = "";
	end
	DEFAULT_CHAT_FRAME:AddMessage("|cff33cc33[AuctionFilterPlus]|r "..message);
end

function afp_PrintError(message) -- Send Error to Chat Frame
	DEFAULT_CHAT_FRAME:AddMessage("[AuctionFilterPlus] ERROR: "..message, 1.0, 0, 0);
end

function afp_Round(x)
	if (x - math.floor(x) > 0.5) then
		x = x + 0.5;
	end
	return math.floor(x);
end

--courtesy watchdog:
function GetHex(r,g,b)

	if g then
		return string.format("|cFF%02X%02X%02X", (255*r), (255*g), (255*b));
	elseif r then
		return string.format("|cFF%02X%02X%02X", (255*r.r), (255*r.g), (255*r.b));
	else
		return "";
	end

end
