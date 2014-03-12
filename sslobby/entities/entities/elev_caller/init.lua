AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

AccessorFunc(ENT, "m_bInside", "Inside")

------------------------------------------------
--
------------------------------------------------

function ENT:Initialize()
	self:PhysicsInit(SOLID_NONE)
	self:SetSolid(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetCollisionBounds(self.mins, self.maxs)
	self:DrawShadow(false)

	-- Button that is inside the elevator.
	local angles = self:GetAngles()
	
	self:SetInside(angles.y == 180)
end

------------------------------------------------
--
------------------------------------------------

function ENT:KeyValue(key, value)
	if (key == "elevator") then
		self:SetElevatorID(value)
	end
end

------------------------------------------------
--
------------------------------------------------

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

------------------------------------------------
--
------------------------------------------------

util.AddNetworkString("ss.lbelcall")

local findMin, findMax = Vector(-74, -52, 0), Vector(74, 52, 118)

net.Receive("ss.lbelcall", function(bits, player)
	local button = net.ReadEntity()
	
	if (IsValid(button)) then
		button:SetPressed(true)
		
		local id = button:GetElevatorID()
		local elevators = ents.FindByClass("info_elev")
		
		for k, elevator in pairs(elevators) do
			local elevatorID = elevator:GetID()
			
			if (elevatorID == id) then
				local inside = button:GetInside()
				local controller = elevator.controller
				
				if (inside) then
					if (!controller:IsMoving()) then
						local current = controller:GetCurrent()
						
						controller:SetMoving(true)
						controller:CloseDoors()
						
						elevator:EmitSound("plats/elevator_large_start1.wav")
						
						local position = current:GetPos()

						timer.Simple(2.2, function()
							SS.Lobby.Sound.New(current:EntIndex(), current, "plats/elevator_move_loop1.wav")
						end)
						
						timer.Simple(5.5, function()
							local players = ents.FindInBox(position +findMin, position +findMax)
							
							for k, player in pairs(players) do
								if (player:IsPlayer()) then
									local position = elevator:GetPos()
									local playerPosition = player:GetPos()
									local position = Vector(playerPosition.x, playerPosition.y, position.z)
									
									player:SetPos(position)
								end
							end
							
							button:SetPressed(false)
							
							controller:SetMoving(false)
							controller:SetCurrent(elevator)
							
							elevator:OpenDoors()
							elevator:EmitSound("plats/elevator_stop2.wav")
							
							SS.Lobby.Sound.Remove(current:EntIndex())
						end)
					else
						-- add to memory
					end
				else
					if (controller:IsMoving()) then
						-- add to memory
					else
						local current = controller:GetCurrent()
						
						if (current == elevator) then
							elevator:OpenDoors()
							
							button:SetPressed(false)
						else
							controller:CloseDoors()
							controller:SetMoving(true)
							
							elevator:EmitSound("plats/elevator_large_start1.wav")
							
							timer.Simple(2.5, function()
								button:SetPressed(false)
								
								controller:SetMoving(false)
								controller:SetCurrent(elevator)
								
								elevator:OpenDoors()
								elevator:EmitSound("plats/elevator_stop2.wav")
							end)
						end
					end
				end
			end
		end
	end
end)