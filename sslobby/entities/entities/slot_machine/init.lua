AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

resource.AddFile("sound/testslot/jackpot.mp3")
resource.AddFile("sound/testslot/pull_lever.mp3")
resource.AddFile("sound/testslot/spinning_1.mp3")
resource.AddFile("sound/testslot/spinning_3.mp3")
resource.AddFile("sound/testslot/spinning_3.mp3")

util.AddNetworkString("ss_pullslotmc")

function ENT:Initialize()
	self:SetModel("models/sam/slotmachine.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetUseType(SIMPLE_USE)
	
	self:SetTrigger(true)
	self:DrawShadow(false)
	
	self.nextPull = 0
	self.sequence = self:LookupSequence("pull_handle")
end

function ENT:Use(player)
	if (self.nextPull < CurTime()) then
		self:ResetSequence(self.sequence)
		
		local randomLeft = math.random(1, 6)
		local randomMiddle = math.random(1, 6)
		local randomRight = math.random(1, 6)
		
		local winCount = 0
		local winRequired = 0
		local winMultiply = 0
		
		for k, data in pairs(self.winDefines) do
			if (data.slots[1] > 0) then
				winRequired = winRequired +1
				
				if (randomLeft == data.slots[1]) then
					winCount = winCount +1
				end
			end
			
			if (data.slots[2] > 0) then
				winRequired = winRequired +1
				
				if (randomMiddle == data.slots[2]) then
					winCount = winCount +1
				end
			end
			
			if (data.slots[3] > 0) then
				winRequired = winRequired +1
				
				if (randomRight == data.slots[3]) then
					winCount = winCount +1
				end
			end
			
			if (winCount >= winRequired) then
				winMultiply = data.win
			end
		end
		
		net.Start("ss_pullslotmc")
			net.WriteUInt(randomLeft, 4)
			net.WriteUInt(randomMiddle, 4)
			net.WriteUInt(randomRight, 4)
			net.WriteEntity(self)
		net.SendPVS(self:GetPos() +Vector(0, 0, 5)) --net.Broadcast()
		
		self:EmitSound("testslot/pull_lever.mp3")
		self:EmitSound("testslot/spinning_" .. math.random(1, 3) .. ".mp3")
		
		self.nextPull = CurTime() +5
	end
end