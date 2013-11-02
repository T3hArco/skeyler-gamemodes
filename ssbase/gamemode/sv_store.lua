SS.STORE.CSModels = {}
SS.STORE.modelids = {}

util.AddNetworkString("SS_ItemEquip")
util.AddNetworkString("SS_NewCSModel")
util.AddNetworkString("SS_ItemUnequip")
util.AddNetworkString("SS_RemoveCSModel")
util.AddNetworkString("SS_ItemSetColor")
util.AddNetworkString("SS_SetModelIDs")
util.AddNetworkString("SS_SetModelID")
util.AddNetworkString("SS_CSModels")

net.Receive("SS_ItemEquip",function(len,p)
	local id = net.ReadString()
	SS.Store:Equip(p,id)
end)

function SS.STORE:Equip(p,id)
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
end

function SS.STORE:AddBMModel(player,item)
	if(!SS.STORE.BMModels[player]) then
		SS.STORE.BMModels[player] = {}
	end
	
	local bm = ents.Create("store_bonemerge")
	bm:SetPos(player:GetBonePosition(player:LookupBone(item.Bone or "ValveBiped.Bip01_Head1")))
	bm.Scale = item.Model[SS.STORE.modelids[player]].scale
	bm:Spawn()
	bm:SetParent(player)
	bm:AddEffects(EF_BONEMERGE)
	
	SS.STORE.BMModels[player][item.ID] = bm
end

function SS.STORE:AddCSModel(player,item)
	if(!SS.STORE.CSModels[player]) then
		SS.STORE.CSModels[player] = {}
	end
	
	table.insert(SS.STORE.CSModels[player],item.ID)
	
	net.Start("SS_NewCSModel")
	net.WriteEntity(player)
	net.WriteString(item.ID)
	net.Broadcast()
end

net.Receive("SS_ItemUnequip",function(len,p)
	local id = net.ReadString()
	SS.Store:Unequip(p,id)
end)

function SS.STORE:Unequip(p,id)
	local i = self.Items[id]
	if(i.Bone) then
		self:RemoveCSModel(p,i)
	elseif(i.Model) then
		p:SetModel("models/player/breen.mdl") --this should be changed
		p:SetPlayerColor(Color(255,255,255,255))
	end
	if(i.Functions["Unequip"]) then
		i.Functions["Unequip"](p)
	end
end

function SS.STORE:RemoveBMModel(player,item)
	if(!SS.STORE.BMModels[player] || !SS.STORE.BMModels[player][item.ID]) then
		return
	end
	
	model = SS.STORE.BMModels[player][item.ID]
	model:Remove()
end

function SS.STORE:RemoveCSModel(player,item)
	if(!SS.STORE.CSModels[player] || !table.HasValue(SS.STORE.CSModels[player],item.ID)) then
		return
	end
	
	local rem = nil
	for k,v in pairs(SS.STORE.CSModels[player]) do
		if(v == item.ID) then
			rem = k
		end
	end
	
	if(rem) then
		table.remove(SS.STORE.CSModels[player],rem)
	
		net.Start("SS_RemoveCSModel")
		net.WriteEntity(player)
		net.WriteString(item.ID)
		net.Broadcast()
	end
end

net.Receive("SS_ItemSetColor",function(len,p)
	local id = net.ReadString()
	local c = net.ReadVector()
	SS.Store:SetColor(p,id,c)
end)

function SS.STORE:SetColor(p,id,col)
	p.CustomColor[id] = Color(col.x,col.y,col.z)
end

hook.Add("OnPlayerDeath","SS_STORE_UnequipNonModels",function(ply)
	for k,v in pairs(ply.Equipped) do
		local i = SS.STORE.Items[v.ID]
		if(i.Category != 2) then --non models
			SS.STORE:Unequip(ply,v.ID)
		end
	end
end)

hook.Add("PlayerInitialSpawn","SS_STORE_Spawn",function(ply)
	net.Start("SS_CSModels")
	net.WriteTable(SS.STORE.CSModels)
	net.Send(ply)
	
	net.Start("SS_SetModelIDs")
	net.WriteTable(SS.STORE.modelids)
	net.Send(ply)
end)

concommand.Add("equiptest",function(p,cmd,arg)
	arg = arg[1]
	SS.STORE:Equip(p,arg)
end)