-- Adds overlays to items in the addon ArkInventory: https://mods.curse.com/addons/wow/ark-inventory


if IsAddOnLoaded("ArkInventory") then
	
	if ArkInventory.Const.Program.Version < 30821 then	
		ArkInventory.OutputWarning( "The CanIMogIt plugin requires ArkInventory version 3.08.21 r810-alpha or higher to work - your version is too low, please upgrade ArkInventory" )
		return
	end
	
	----------------------------
	-- UpdateIcon functions   --
	----------------------------
	
	
	function ArkInventoryItemButton_CIMIUpdateIcon(self)
		if not self or not self:GetParent() then return end
		local frame = self:GetParent()
		if not frame.ARK_Data then return end
		if not CIMI_CheckOverlayIconEnabled(self) then
			self.CIMIIconTexture:SetShown(false)
			self:SetScript("OnUpdate", nil)
			return
		end
		local itemLink = nil
		local bag = frame.ARK_Data.blizzard_id
		local slot = frame.ARK_Data.slot_id
		
		if ArkInventory.API.LocationIsOffline( loc_id ) or loc_id == ArkInventory.Const.Location.Vault then
			--[[
				Two things of note here:
				1) isOffline should treat the item as if it's on a different character, ignoring soulbound status.
				2) Guild Bank uses a different API call so bag is not a blizzard id
				
				Grabbing the item from the frame directly, since they can't be soulbound anyway.
			]]
			local i = ArkInventory.API.ItemFrameItemTableGet( frame )
			if i and i.h then
				itemLink = i.h
			end
			-- Nil out bag and slot, so it uses the itemlink instead.
			bag = nil
			slot = nil
		end
		CIMI_SetIcon(self, ArkInventoryItemButton_CIMIUpdateIcon, CanIMogIt:GetTooltipText(itemLink, bag, slot))
	end
	
	
	----------------------------
	-- Begin adding to frames --
	----------------------------
	
	
	function CIMI_ArkInventoryAddFrame(frame)
		-- Add to frames
		CIMI_AddToFrame(frame, ArkInventoryItemButton_CIMIUpdateIcon)
	end
	
	hooksecurefunc( ArkInventory.API, "ItemFrameLoaded", CIMI_ArkInventoryAddFrame )
	
	-- add to any preloaded item frames
	
	-- Bags
	for _, frame in ArkInventory.API.ItemFrameLoadedIterate( ArkInventory.Const.Location.Bag ) do
		CIMI_ArkInventoryAddFrame(frame)
	end
	-- Player Bank
	for _, frame in ArkInventory.API.ItemFrameLoadedIterate( ArkInventory.Const.Location.Bank ) do
		CIMI_ArkInventoryAddFrame(frame)
	end
	-- Guild Bank
	for _, frame in ArkInventory.API.ItemFrameLoadedIterate( ArkInventory.Const.Location.Vault ) do
		CIMI_ArkInventoryAddFrame(frame)
	end
	
	
	------------------------
	-- Event functions    --
	------------------------
	
	
	function CIMI_ArkInventoryUpdate()
		-- Bags
		for _, frame in ArkInventory.API.ItemFrameLoadedIterate( ArkInventory.Const.Location.Bag ) do
			ArkInventoryItemButton_CIMIUpdateIcon(frame.CanIMogItOverlay)
		end
		-- Player Bank
		for _, frame in ArkInventory.API.ItemFrameLoadedIterate( ArkInventory.Const.Location.Bank ) do
			C_Timer.After(.1, function() ArkInventoryItemButton_CIMIUpdateIcon(frame.CanIMogItOverlay) end)
		end
		-- Guild Bank
		for _, frame in ArkInventory.API.ItemFrameLoadedIterate( ArkInventory.Const.Location.Vault ) do
			-- The guild bank frame does extra stuff after the CIMI icon shows up,
			-- so need to add a slight delay.
			C_Timer.After(.2, function() ArkInventoryItemButton_CIMIUpdateIcon(frame.CanIMogItOverlay) end)
		end
	end
	
	function CIMI_ArkInventoryUpdateSingle(frame)
		ArkInventoryItemButton_CIMIUpdateIcon(frame.CanIMogItOverlay)
	end
	
	hooksecurefunc( ArkInventory.API, "ItemFrameUpdated", CIMI_ArkInventoryUpdateSingle )
	
	CanIMogIt:RegisterMessage("ResetCache", CIMI_ArkInventoryUpdate)
	
	function CIMI_ArkInventoryEvents(self, event)
		-- Update based on wow events
		if not CIMIEvents[event] then return end
		CIMI_ArkInventoryUpdate()
	end
	hooksecurefunc(CanIMogIt.frame, "ItemOverlayEvents", CIMI_ArkInventoryEvents)
	
end
