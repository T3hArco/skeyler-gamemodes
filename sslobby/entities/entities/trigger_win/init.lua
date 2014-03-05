ENT.Base = "base_brush"
ENT.Type = "brush"

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Initialize()
	self.count = 0
	self.players = {}
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:KeyValue(key, value)
	self[key] = tonumber(value)
	
	print(self,key,value)
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Reset()
	self.count = 0
	self.players = {}
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:StartTouch(entity)
print(entity)
	--[[
	if !IsValid(ent) then return end
	if !ent:IsPlayer() then return end
	
	table.insert( self.players, ent )
	local team = team.GetPlayingPlayers( ent:Team() )
	if team then
		local win = true
		for _, pl in pairs( team ) do
			if !table.HasValue( self.players, pl ) then
				win = false
				break
			end
		end
		if win then GAMEMODE.Arcade.EndMinigame( #team == 1 and ent or ent:Team() ) end
	end
	]]
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:EndTouch(entity)
	
--[[	if !IsValid( ent ) then return end
	if !ent:IsPlayer() then return end
	
	for _, pl in pairs( self.players ) do
		if !(IsValid(pl) and pl:IsPlayer()) then
			table.remove( self.players, _ )
		elseif pl == ent then
			table.remove( self.players, _ )
		end
	end
	
	if table.Count( self.players ) == 0 then self:Reset() end
	]]
end