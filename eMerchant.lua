-- =============================================================================
--
--       Filename:  eMerchant.lua
--
--    Description:  Sells all the gray and predefined items in
--                  your bags and repairs your equiptment.
--
--        Version:  5.2.1
--
--         Author:  Mathias Jost (mail@mathiasjost.com)
--
--		   Edited:	Lars Theviﬂen
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Make the Lua globals local
-- -----------------------------------------------------------------------------
local _G = getfenv(0)

-- Functions
local CanMerchantRepair = _G.CanMerchantRepair
local GetRepairAllCost = _G.GetRepairAllCost
local IsInGuild = _G.IsInGuild
local GetGuildBankWithdrawMoney = _G.GetGuildBankWithdrawMoney
local GetGuildBankMoney = _G.GetGuildBankMoney
local CanGuildBankRepair = _G.CanGuildBankRepair
local RepairAllItems = _G.RepairAllItems
local GetItemInfo = _G.GetItemInfo
local GetContainerNumSlots = _G.GetContainerNumSlots
local GetContainerItemLink = _G.GetContainerItemLink
local PickupContainerItem = _G.PickupContainerItem
local PickupMerchantItem = _G.PickupMerchantItem
local DEFAULT_CHAT_FRAME = _G.DEFAULT_CHAT_FRAME
local min = _G.min
local select = _G.select
local ipairs = _G.ipairs
local strsplit = _G.strsplit

-- Libraries
local string = _G.string

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

		local repairAllCost
		local repairNeeded
		local withdrawLimit

		-- do you need repairing
		repairAllCost, repairNeeded = GetRepairAllCost()

		-- check if you even need to repair your gear
		if repairNeeded then

			-- check if you are in a guild and if you can use the guild bank for repair funds
			if IsInGuild() then
				withdrawLimit = GetGuildBankWithdrawMoney()
				local guildBankMoney = GetGuildBankMoney()
				
				if withdrawLimit == -1 then
					withdrawLimit = guildBankMoney
				else
					withdrawLimit = min(withdrawLimit, guildBankMoney)
				end
			end -- if IsInGuild() then

			-- checks if you can use the guilds funds
			if CanGuildBankRepair() and repairAllCost < withdrawLimit then				
				-- repair using guild funds
				RepairAllItems(1)
				DEFAULT_CHAT_FRAME:AddMessage("[|cFFAAAAAAeMerchant|r] repaired using guild funds.")
			else
				-- repair using own funds
				RepairAllItems()
				DEFAULT_CHAT_FRAME:AddMessage("[|cFFAAAAAAeMerchant|r] repaired using own funds.")
			end -- if CanGuildBankRepair() and repairAllCost < withdrawLimit then	

		end -- if repairNeeded then

	end -- if CanMerchantRepair() == 1 then

	-- cycles through the 5 bags
	for x = 0, 4 do

		-- cycles through the bag itself
		for y = 1, GetContainerNumSlots(x) do

			local itemLink = GetContainerItemLink(x,y)

			-- checks if there is an item
			if ( itemLink ) then

				local name = select(1, GetItemInfo(itemLink))
				local quality = select(3, GetItemInfo(itemLink))

				-- if the quality is gray/poor
				if ( quality == 0 ) then

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
