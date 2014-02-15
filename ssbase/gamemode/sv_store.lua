local MAXIMUM_SLOTS = SS.STORE.SLOT.MAXIMUM

util.AddNetworkString("SS_ItemEquip")
util.AddNetworkString("SS_ItemUnequip")
util.AddNetworkString("SS_ItemSetColor")

function SS.STORE:Equip(player, id)
--[[
	local i = self.Items[id] 
	if !i then return end 
	if(i.Bone) then
		if(i.BoneMerge) then
			self:AddBMModel(p,i)
		else
			self:AddCSModel(p,i)
		end
	elseif(i.Model) then
		p:SetModel(i.Model)
		SS.STORE.modelids[p] = id
		net.Start("SS_SetModelID")
		net.WriteEntity(p)
		net.WriteString(id)
		net.Broadcast()
		if(i.Colorable) then
			p:SetPlayerColor(p.CustomColor[id])
		end
	end
	if(i.Functions["Equip"]) then
		i.Functions["Equip"](p) --incase we ever need to do something special :P
	end
	if(!SS.STORE.Equipped[p]) then
		SS.STORE.Equipped[p] = {}
	end
	table.insert(SS.STORE.Equipped[p],id)
	net.Start("SS_EquipTable")
	net.WriteEntity(p)
	net.WriteTable(SS.STORE.Equipped[p])
	net.Broadcast() -- we arent losing much (I hope)]]
	
	local item = self.Items[id]
	
	if (item) then
		local slot = player.storeEquipped[item.Slot]
		
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
		net.Start("ss.gear.gtgrslot")
			net.WriteString(item.ID)
			net.WriteString(steamID)
			net.WriteBit(false)
		net.Send(player)
		
		-- It's a player model.
		if (item.Model and !item.Bone) then
			player:SetModel(item.Model)
			
			--if (item.Colorable) then
			--	player:SetPlayerColor(player.CustomColor[id])
			--end
		end
		
		if (item.Functions.Equip) then
			item.Functions.Equip(player)
		end
	end
end

function SS.STORE:Unequip(player, id)
	--[[local i = self.Items[id]
	if(i.Bone) then
		self:RemoveCSModel(p,i)
	elseif(i.Model) then
		p:SetModel("models/player/breen.mdl") --this should be changed
		p:SetPlayerColor(Vector(1,1,1)) --between 1 and 0 and stupid vector
	end
	if(i.Functions["Unequip"]) then
		i.Functions["Unequip"](p)
	end
	local rem = nil
	for k,v in pairs(self.Equipped[p]) do
		if v == id then
			rem = k
		end
	end
	if rem then
		table.remove(self.Equipped[p],rem)
		net.Start("SS_EquipTable")
		net.WriteEntity(p)
		net.WriteTable(SS.STORE.Equipped[p])
		net.Broadcast() -- we arent losing much I hope since we arent broadcasting
	end]]
	
	local item = self.Items[id]
	
	if (item) then
		local slot = player.storeEquipped[item.Slot]
		
		if (slot.unique and slot.unique == item.ID) then
			if (item.Functions.Unequip) then
				item.Functions.Unequip(player)
			end
			
			player.storeEquipped[item.Slot].unique = nil
			
			local steamID = player:SteamID()

			-- Make the slot dirty.
			net.Start("ss.gear.gtgrslotd")
				net.WriteString(steamID)
				net.WriteUInt(item.Slot, 8)
			net.Broadcast()
			
			-- We need to force update to the player.
			net.Start("ss.gear.gtgrslot")
				net.WriteString(item.ID)
				net.WriteString(steamID)
				net.WriteBit(true)
			net.Send(player)
		
			-- It's a player model.
			if (item.Model and !item.Bone) then
				local cl_playermodel = player:GetInfo("cl_playermodel")
				local model = player_manager.TranslatePlayerModel(cl_playermodel)
				
				player:SetModel(model)
			end
		end
	end
end




hook.Add("PlayerInitialSpawn","SS_STORE_Spawn",function(ply)
	
	-- < TEMP
	ply:SetStoreItems("")
	-- TEMP >
	
	-- Create the slots.
	ply.storeEquipped = {}
	
	for i = 1, MAXIMUM_SLOTS do
		ply.storeEquipped[i] = {}
	end
end)

concommand.Add("equiptest",function(p,cmd,arg)
	arg = arg[1]
	SS.STORE:Equip(p,arg)
end)

concommand.Add("unequiptest",function(p,cmd,arg)
	arg = arg[1]
	SS.STORE:Unequip(p,arg)
end)




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
		local storeEquipped = target.storeEquipped
		
		net.Start("ss.gear.gtgrfull")
			net.WriteString(steamID)
			
			for i = 1, MAXIMUM_SLOTS do
				net.WriteString(storeEquipped[i].unique or "")
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
		local steamID = target:SteamID()
		local unique = target.storeEquipped[slot].unique
		
		net.Start("ss.gear.gtgrslot")
			net.WriteString(unique or "")
			net.WriteString(steamID)
			net.WriteBit(!unique or unique == "") -- true = remove
		net.Broadcast()
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
		print("you dont own that item")
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
		print("you dont own that item")
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
				
				print("purchased")
			else
				print("cannot afford")
			end
		end
	else
		print("already has item")
	end
end)

---------------------------------------------------------
-- Adds an item to your "owned" list.
---------------------------------------------------------

function PLAYER_META:AddStoreItem(id)
	self.storeItems[id] = {} -- Maybe we want to store stuff in this table?
	
	self:NetworkOwnedItem(id)
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
			net.WriteString(single)
		net.Send(self)
		
	-- Send everything!
	else
		for item, data in pairs(storeItems) do
			net.Start("ss.store.gtitms")
				net.WriteString(item)
			net.Send(self)
		end
	end
end


-- < TEMP
timer.Simple(0.1, function()
Entity(1):GiveMoney(10^10)
Entity(1):NetworkOwnedItem()
end)
-- TEMP >