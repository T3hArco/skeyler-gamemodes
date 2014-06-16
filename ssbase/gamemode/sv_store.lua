---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com -- 
---------------------------- 

local MAXIMUM_SLOTS = SS.STORE.SLOT.MAXIMUM

util.AddNetworkString("SS_ItemEquip")
util.AddNetworkString("SS_ItemUnequip")
util.AddNetworkString("SS_ItemSetColor")

---------------------------------------------------------
-- Single slot update.
---------------------------------------------------------

local noColor = Vector(255, 255, 255)

function SS.STORE.UpdateSlot(slot, player, target)
	local unique = target.storeEquipped[slot].unique
	local remove = !unique or unique == ""
	local steamID = target:SteamID()
	local item = SS.STORE.Items[unique]

	net.Start("ss.gear.gtgrslot")
		net.WriteString(unique or target.storeEquipped[slot].last or "")
		net.WriteString(steamID)
		net.WriteBit(remove)
		
		if (!remove) then
			local stored = target.storeItems[unique]
			
			local skin = stored[SS.STORE.CUSTOM.SKIN] or 0
			local color = stored[SS.STORE.CUSTOM.COLOR] or noColor
			local bodyGroups = stored[SS.STORE.CUSTOM.BODYGROUP] or {}
			
			net.WriteUInt(skin, 8)
			net.WriteVector(color)
			
			local count = table.Count(bodyGroups) -- ugh
			
			net.WriteUInt(count, 8)
			
			for group, value in pairs(bodyGroups) do
				net.WriteUInt(group, 8)
				net.WriteUInt(value, 8)
			end
		end
	if (IsValid(player)) then net.Send(player) else net.Broadcast() end
end

---------------------------------------------------------
--
---------------------------------------------------------

function SS.STORE:Equip(player, id)
	if (CurTime() -player.spamTime <= 0.35) then return end

	player.spamTime = CurTime()
	
	local item = self.Items[id]
	
	if (item) then
		local slot = player.storeEquipped[item.Slot]
		
		-- Unequip the previos one.
		if (slot.unique and slot.unique != "") then
			local previous = self.Items[slot.unique]
			
			if (previous) then
				if (previous.Functions.Unequip) then
					previous.Functions.Unequip(player)
				end
			end
		end
		
		player.storeEquipped[item.Slot].unique = item.ID

		local steamID = player:SteamID()
		
		-- Make the slot dirty.
		net.Start("ss.gear.gtgrslotd")
			net.WriteString(steamID)
			net.WriteUInt(item.Slot, 8)
		net.Broadcast()

		-- We need to force update to the player.
		SS.STORE.UpdateSlot(item.Slot, player, player)
		
		-- It's a player model.
		if (item.Model and !item.Bone) then
			player:SetModel(item.Model)
		end
		
		-- Apply colors.
		if (item.Colorable) then
			local color = player:GetItemData(item.ID, "color")
			
			-- It's a player model. (We set the color of an item clientside.)
			if (color and item.Model and !item.Bone) then
				player:SetPlayerColor(Vector(color.x /255, color.y /255, color.z /255))
			end
		end
		
		if (item.Functions.Equip) then
			item.Functions.Equip(player)
		end
		
		-- Add the item to the database. (Is it a good idea to do it here?)
		DB_Query("UPDATE users_equipped SET item = " .. sql.SQLStr(item.ID) .. " WHERE steamID = " .. sql.SQLStr(steamID) .. " AND slot = " .. item.Slot, function(data, query)
			if (query:affectedRows() == 0) then
				local users_id = player:GetProfileData("id")
				
				DB_Query("INSERT INTO users_equipped(id, users_id, steamID, item, slot) VALUES(NULL, " .. users_id .. ", " .. sql.SQLStr(steamID) .. ", " .. sql.SQLStr(item.ID) .. ", " .. item.Slot .. ")")
			end
		end)
	end
end

---------------------------------------------------------
-- 
---------------------------------------------------------

function SS.STORE:Unequip(player, id)
	if (CurTime() -player.spamTime <= 0.35) then return end

	player.spamTime = CurTime()
	
	local item = self.Items[id]
	
	if (item) then
		local slot = player.storeEquipped[item.Slot]
		
		if (slot.unique and slot.unique == item.ID) then
			if (item.Functions.Unequip) then
				item.Functions.Unequip(player)
			end
			
			player.storeEquipped[item.Slot].last = player.storeEquipped[item.Slot].unique
			player.storeEquipped[item.Slot].unique = nil
			
			local steamID = player:SteamID()

			-- Make the slot dirty.
			net.Start("ss.gear.gtgrslotd")
				net.WriteString(steamID)
				net.WriteUInt(item.Slot, 8)
			net.Broadcast()
			
			-- We need to force update to the player.
			SS.STORE.UpdateSlot(item.Slot, player, player)
		
			-- It's a player model.
			if (item.Model and !item.Bone) then
				local random = SS.DefaultModels[math.random(1, #SS.DefaultModels)]
			
				player:SetModel(random)
			end
			
			DB_Query("UPDATE users_equipped SET item = NULL WHERE steamID = " .. sql.SQLStr(steamID) .. " AND slot = " .. item.Slot)
		end
	end
end

---------------------------------------------------------
-- Full gear update.
---------------------------------------------------------

util.AddNetworkString("ss.gear.rqgrfull")
util.AddNetworkString("ss.gear.gtgrfull")

net.Receive("ss.gear.rqgrfull", function(bits, player)
	local target = net.ReadString()
	
	target = util.FindPlayer(target)
	
	if (IsValid(target)) then
		local steamID = target:SteamID()
		local equipped = target.storeEquipped

		net.Start("ss.gear.gtgrfull")
			net.WriteString(steamID)
			
			for i = 1, MAXIMUM_SLOTS do
				local unique = equipped[i].unique
				
				net.WriteString(unique or "")
				
				if (unique) then
					local item = SS.STORE.Items[unique]
			
					if (item and item.Bone) then
						local stored = target.storeItems[unique]
						
						local skin = stored[SS.STORE.CUSTOM.SKIN] or 0
						local color = stored[SS.STORE.CUSTOM.COLOR] or noColor
						local bodyGroups = stored[SS.STORE.CUSTOM.BODYGROUP] or {}
	
						net.WriteUInt(skin, 8)
						net.WriteVector(color)
						
						local count = table.Count(bodyGroups) -- ugh
						
						net.WriteUInt(count, 8)
						
						for group, value in pairs(bodyGroups) do
							net.WriteUInt(group, 8)
							net.WriteUInt(value, 8)
						end
					end
				end
			end
		net.Send(player)
	end
end)

---------------------------------------------------------
-- Single slot update.
---------------------------------------------------------

util.AddNetworkString("ss.gear.rqgrslot")
util.AddNetworkString("ss.gear.gtgrslot")
util.AddNetworkString("ss.gear.gtgrslotd")

net.Receive("ss.gear.rqgrslot", function(bits, player)
	local target = net.ReadString()
	
	target = util.FindPlayer(target)
	
	if (IsValid(target)) then
		local slot = net.ReadUInt(8)
		
		SS.STORE.UpdateSlot(slot, player, target)
	end
end)

---------------------------------------------------------
-- Equipping an item.
---------------------------------------------------------

net.Receive("SS_ItemEquip",function(bits, player)
	local id = net.ReadString()
	local hasItem = player:HasStoreItem(id)
	
	if (hasItem) then
		SS.STORE:Equip(player, id)
	else
		SS.Notify(NOTIFY_STORE_NOTOWNED, player)
	end
end)

---------------------------------------------------------
-- Unequipping an item.
---------------------------------------------------------

net.Receive("SS_ItemUnequip",function(bits, player)
	local id = net.ReadString()
	local hasItem = player:HasStoreItem(id)
	
	if (hasItem) then
		SS.STORE:Unequip(player, id)
	else
		SS.Notify(NOTIFY_STORE_NOTOWNED, player)
	end
end)

---------------------------------------------------------
-- Purchasing an item.
---------------------------------------------------------

util.AddNetworkString("ss.store.buy")

net.Receive("ss.store.buy",function(bits, player)
	local id = net.ReadString()
	local hasItem = player:HasStoreItem(id)
	
	if (!hasItem) then
		local item = SS.STORE.Items[id]
		
		if (item) then
			local canAfford = player:CanAffordItem(item.ID)
			
			if (canAfford) then
				player:AddStoreItem(item.ID)
				player:TakeMoney(item.Price)
				
				SS.Notify(NOTIFY_STORE_PURCHASED, player)
			else
				SS.Notify(NOTIFY_STORE_AFFORD, player)
			end
		end
	else
		SS.Notify(NOTIFY_STORE_OWNED, player)
	end
end)

---------------------------------------------------------
-- Item customization.
---------------------------------------------------------

util.AddNetworkString("ss.store.stcstm")

net.Receive("ss.store.stcstm",function(bits, player)
	local id = net.ReadString()
	local hasItem = player:HasStoreItem(id)
	
	if (hasItem) then
		local item = SS.STORE.Items[id]
		local type = net.ReadString()
		local stored = player.storeItems[id]

		if (type == SS.STORE.CUSTOM.COLOR) then
			local color = net.ReadVector()
			
			stored[type] = color
			
			-- Apply colors.
			if (item.Colorable) then
			
				-- It's a player model. (We set the color of an item clientside.)
				if (item.Model and !item.Bone) then
					player:SetPlayerColor(Vector(color.x /255, color.y /255, color.z /255))
				end
			end
		end
		
		if (type == SS.STORE.CUSTOM.BODYGROUP) then
			local group = net.ReadUInt(8)
			local value = net.ReadUInt(8)
			
			stored[type] = stored[type] or {}
			stored[type][group] = value

			if (item.Model and !item.Bone) then
				player:SetBodygroup(group, value)
			end
		end
		
		if (type == SS.STORE.CUSTOM.SKIN) then
			local skin = net.ReadUInt(8)
			
			stored[type] = skin
			
			if (item.Model and !item.Bone) then
				player:SetSkin(skin)
			end
		end
		
		local steamID = player:SteamID()
		
		-- Make the slot dirty.
		net.Start("ss.gear.gtgrslotd")
			net.WriteString(steamID)
			net.WriteUInt(item.Slot, 8)
		net.Broadcast()
		
		-- We need to force update to the player.
		SS.STORE.UpdateSlot(item.Slot, player, player)
	else
		SS.Notify(NOTIFY_STORE_NOTOWNED, player)
	end
end)

---------------------------------------------------------
-- Adds an item to your "owned" list.
---------------------------------------------------------

function PLAYER_META:AddStoreItem(id)
	self.storeItems[id] = {}
	
	self:NetworkOwnedItem(id)
	
	local color 	= sql.SQLStr(string.format("#%02X%02X%02X", 255, 255, 255))
	local steamID 	= sql.SQLStr(self:SteamID())
	local bodygroup = sql.SQLStr(util.TableToJSON({}))
	local users_id 	= self:GetProfileData("id")
	
	-- Add the item to the database. (Is it a good idea to do it here?)
	local query = DB_Query("INSERT INTO users_items(id, users_id, steamID, item, color, skin, bodygroup) VALUES(NULL, " .. users_id .. ", " .. steamID .. ", " .. sql.SQLStr(id) .. ", " .. color .. ", 0, " .. bodygroup ..")", function(data, query)
		self.storeItems[id].__id = query:lastInsert()
	end)
end

---------------------------------------------------------
-- Network the items that a player owns.
---------------------------------------------------------

util.AddNetworkString("ss.store.gtitms")

function PLAYER_META:NetworkOwnedItem(single)
	local storeItems = self.storeItems
	
	-- Single item update. Used when you purchase so we don't have to send everything.
	if (single) then
		net.Start("ss.store.gtitms")
			net.WriteUInt(1, 8)
			net.WriteString(single)
		net.Send(self)
		
	-- Send everything!
	else
		local count = table.Count(storeItems)
		
		net.Start("ss.store.gtitms")
			net.WriteUInt(count, 8)
			
			-- I hope this will fit, otherwise will change it.
			for item, data in pairs(storeItems) do
				net.WriteString(item)
			end
		net.Send(self)
	end
end