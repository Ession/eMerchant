-- =============================================================================
--
--       Filename:  eMerchant.lua
--
--    Description:  Sells all the gray and predefined items in
--                  your bags and repairs your equiptment.
--
--        Version:  5.2.1a
--
--         Author:  Mathias Jost (mail@mathiasjost.com)
--
--		   Edited:	Lars Theviﬂen
-- =============================================================================


-- -----------------------------------------------------------------------------
-- List of additional items to be sold
-- -----------------------------------------------------------------------------
local itemList = {
	--"8952",  -- Roasted Quail
	--"8766",  -- Morning Glory Dew
	--"8150",  -- Deeprock Salt
	--"8932",  -- Alterac Swiss
	--"33454", -- Salted Venison
	--"35947", -- Sparkling Frostcap
}


-- -----------------------------------------------------------------------------
-- Create addon frame
-- -----------------------------------------------------------------------------
local eMerchant = CreateFrame("Frame")


-- -----------------------------------------------------------------------------
-- Register events
-- -----------------------------------------------------------------------------
eMerchant:RegisterEvent("MERCHANT_SHOW")


-- -----------------------------------------------------------------------------
-- Event handler
-- -----------------------------------------------------------------------------
eMerchant:SetScript("OnEvent", function()

	-- checks if the merchant is able to repair
	if CanMerchantRepair() then

		-- do you need repairing
		repairAllCost, repairNeeded = GetRepairAllCost()
		if (IsInGuild()) then
			withdrawLimit = GetGuildBankWithdrawMoney()
			guildBankMoney = GetGuildBankMoney()
			if (withdrawLimit == -1) then
				withdrawLimit = guildBankMoney
			else
				withdrawLimit = min(withdrawLimit, guildBankMoney)
			end
		end
		if repairNeeded then
			-- checks if you can use the guilds funds
			if CanGuildBankRepair() and repairAllCost < withdrawLimit then				
				-- repair using guild funds
				RepairAllItems(1)
				DEFAULT_CHAT_FRAME:AddMessage("[|cFFAAAAAAeMerchant|r] repaired using guild funds.")
			else
				-- repair using own funds
				RepairAllItems()
				DEFAULT_CHAT_FRAME:AddMessage("[|cFFAAAAAAeMerchant|r] repaired using own funds.")
			end
		end

	end -- if CanMerchantRepair() == 1 then

	for x = 0, 4 do -- cycles through the 5 bags

		for y = 1, GetContainerNumSlots(x) do -- cycles through the  single bags

			local itemLink = GetContainerItemLink(x,y)

			if ( itemLink ) then -- checks if there is an item

				local name = select(1, GetItemInfo(itemLink))
				local quality = select(3, GetItemInfo(itemLink))

				if ( quality == 0 ) then -- if the quality is gray/poor

					PickupContainerItem(x,y)
					PickupMerchantItem() -- sells the item
					DEFAULT_CHAT_FRAME:AddMessage("[|cFFAAAAAAeMerchant|r] Sold " .."|cFFAAAAAA"..name .."|r")

				else

					-- get the itemId
					local justItemId = string.gsub(itemLink,".-\124H([^\124]*)\124h.*", "%1")
					local itemId = select(2, strsplit(":",justItemId))

					-- iterates through the list of items to delete
					for k, value in ipairs(itemList) do

						if value == itemId then

							PickupContainerItem(x,y)
							PickupMerchantItem() -- sells the item
							DEFAULT_CHAT_FRAME:AddMessage("[|cFFAAAAAAeMerchant|r] Sold " .."|cFFAAAAAA"..name .."|r")

						end

					end -- if itemId in pairs(itemList) then

				end

			end

		end

	end

end)
