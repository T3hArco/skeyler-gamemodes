--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.OpenSound = Sound("buttons/lever4.wav")
ENT.CloseSound = Sound("buttons/lever6.wav")

ENT.AutomaticFrameAdvance = true

util.AddNetworkString( "PlayGateAnim" )
util.AddNetworkString( "SendConnectedPieces" )

function ENT:Initialize()
	self.Open = false
	self.Opened = false
	self.Closed = false
	self.TouchTable = {}
	self:Setup("gate", false, true)
	self.Connected = {}
	timer.Create(tostring(self), 0.5, 0, function()
		if self.type then
			timer.Destroy(tostring(self))
		end
		self.Allies = nil
		--If a unit collides with the gate while it's still open, they won't be able to move through it until they move back/forward first.
		for i, v in ipairs(ents.FindInSphere(self:GetPos(), 30)) do
			if(v:IsUnit() and (v:GetEmpire() == self:GetEmpire() or Allied(self:GetEmpire(), v:GetEmpire()))) then
				self.Allies = true
			end
		end
		if self.Allies then
			self:OpenGate()
		else
			self:CloseGate()
		end
	end)
end

function ENT:AddConnected(givenEnt)
	table.insert(self.Connected, givenEnt)
	timer.Simple(0.1, function()
		for k,v in pairs(player.GetAll()) do
			net.Start("SendConnectedPieces")
				net.WriteEntity(self)
				net.WriteTable(self.Connected)
			net.Send(v)	
		end
	end)
end

function ENT:SellConnected()
	for k,v in pairs(self.Connected) do
		v:Destroy(building.BUILDING_SELL)
	end
	self:Destroy(building.BUILDING_SELL)
end

function ENT:ChangeSettings(type, model, bool)
	self.type = type
	if model then
		self:SetModel(model)
	end
	self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    local Phys = self:GetPhysicsObject()
    if(Phys:IsValid()) then
        Phys:EnableMotion(false)
        Phys:EnableCollisions(true)
    end
end

	-- local vec1, vec2 = Vector( -6, -20, 0 ), Vector( 6, 20, 30 )
	-- self:PhysicsInitBox( vec1, vec2 )
	-- self:SetCollisionBounds( vec1, vec2 )
	-- self:SetSolid( SOLID_BBOX )
	-- self:SetMoveCollide( MOVECOLLIDE_FLY_SLIDE )
	-- self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

function ENT:OnThink()
	self:WallUpdateControl()

	return 2
end

function ENT:OpenGate()
	if self.type then return end
	if(self.Opened) then
		return
	end

	self.Opened = true
	self.Closed = false
	
	self:SetNotSolid(true)
	self:SetTrigger(true)
	
	self:EmitSound(self.OpenSound)

	if( IsValid( self ) ) then
		for k,v in pairs(player.GetAll()) do  
			net.Start("PlayGateAnim")  
		        net.WriteEntity(self)  
		        net.WriteString("raise")  
		    net.Send(v)  
		end 
	end
end

function ENT:CloseGate()
	if self.type then return end
	if(self.Closed) then
		return
	end
	
	self.Opened = false
	self.Closed = true
	
	self:SetNotSolid(false)
	self:SetTrigger(false)
	
	self:EmitSound(self.CloseSound)

	if( IsValid( self ) ) then
		for k,v in pairs(player.GetAll()) do  
			net.Start("PlayGateAnim")  
		        net.WriteEntity(self)  
		        net.WriteString("lower")  
		    net.Send(v)  
		end 
	end
end

/*
function ENT:StartTouch(Ent)
	if self.type then return end
	if(Ent:IsUnit() and (Ent:GetEmpire() == self:GetEmpire() or Allied(self:GetEmpire(), Ent:GetEmpire()))) then
		self.TouchTable[Ent] = true
		self:OpenGate()
	end
end

function ENT:EndTouch(Ent)
	if self.type then return end
	if(Ent:IsUnit() and Ent:GetEmpire() == self:GetEmpire()) then
		self.TouchTable[Ent] = nil
		if(table.Count(self.TouchTable) == 0) then
			self:CloseGate()
		end
	end
end
*/

function ENT:UpdateControl()
	self:WallUpdateControl()
end

function ENT:OnControl()
	self:WallUpdateControl()
end
