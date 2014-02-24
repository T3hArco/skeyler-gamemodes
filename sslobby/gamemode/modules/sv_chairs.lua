util.AddNetworkString("lobby_sitchair")
util.AddNetworkString("chairs_unsit")
util.AddNetworkString("chairs_sitdown")

------------------------------------------------
-- FUNCTIONS
------------------------------------------------

function GM:PlayerLeaveVehicle(player, vehicle)
	vehicle:SetOwner(NULL)
	
	net.Start("chairs_unsit")
	net.Send(player)
	
	--[[
	local position = vehicle:GetPos() +Vector(0, 0, 50)
	
	if vehicle.exits then
		for _, exit in ipairs( vehicle.exits ) do
			
			local posTemp = vehicle:GetPos() + vehicle:GetForward() * exit.x + vehicle:GetRight() * exit.y + vehicle:GetUp() * exit.z
			local blocked = false;
			
			if !util.IsInWorld( posTemp ) then blocked = true end
			
			for _, ent in pairs(ents.FindInBox(posTemp + Vector(-16, -16, 0), posTemp + Vector(16, 16, 60))) do
				if blocked or (IsValid(ent) and ent:IsPlayer() and ent != pl) then
					blocked = true
					break
				end
			end
			
			if !blocked then
				pos = posTemp;
				break
			end
		end
	end
	]]
	
	player:SetPos(player.lastSeatEnterPos)
	player:SetEyeAngles(player.lastEyeAngles)
	
--	pl:SetPos(position)
--	pl:SetEyeAngles((vehicle:GetPos() - player:EyePos()):Angle())
	
	player.NextSit = CurTime() +0.5
end

function GM:PlayerEnteredVehicle(player, vehicle, role)
end

------------------------------------------------
-- HOOKS
------------------------------------------------

function GM:CanExitVehicle(vehicle, player)
	return false
end

hook.Add("CanPlayerSuicide", "SS.Lobby.Chair", function(player)
	if (player:IsSitting()) then return false end
end)

hook.Add("CanPlayerEnterVehicle", "SS.Lobby.Chair", function(player, vehicle)
	if (player.VehicleEnter) then
		player.VehicleEnter = false
		
		return true
	end
	
	return false
end)

hook.Add("PlayerDeath", "SS.Lobby.Chair", function(player)
	if (IsValid(player) and IsValid(player:GetVehicle())) then
		player:GetVehicle():SetOwner(NullEntity())
	end
end)

hook.Add("KeyPress", "SS.Lobby.Chair", function(player, key)
	if (key == IN_USE and player:IsSitting() and (player.NextSit and CurTime() >= player.NextSit)) then
		player.NextSit = CurTime() +0.5
		
		player:ExitVehicle()
	end
end)

------------------------------------------------
-- COMMANDS
------------------------------------------------

net.Receive("lobby_sitchair", function(bits, player)
	if (IsValid(player)) then
		player.NextSit = player.NextSit or CurTime()
	
		if (player:Alive() and CurTime() >= player.NextSit and !player:IsSitting()) then
			local entity = ents.GetByIndex(net.ReadUInt(32))
		
			if (IsValid(entity)) then
				local trace = {}
				trace.start = player:EyePos()
				trace.endpos = trace.start +player:GetAimVector() *120
				trace.filter = {player}
				
				local function ignore(hitEntity)
					if (hitEntity == entity) then return false end
					if (hitEntity:IsChair()) then return true end
					
					return false
				end
				
				trace = util.RecursiveTraceLine(trace, ignore)
				
				local chair = nil
				
				if (trace.Entity == entity) then
					if (entity:IsVehicle()) then
						chair = entity
					elseif (entity:IsChair()) then
						local compare = 0
						local distance = 1000
						
						for k, v in pairs(entity.slots) do
							local position = entity:GetPos() +entity:GetRight() *v.pos.x +entity:GetForward() *v.pos.y +entity:GetUp() *v.pos.z
							
							compare = position:Distance(trace.HitPos)
							
							if (compare < distance) then
								chair = v.seat
								distance = compare
							end
						end
					end
				end
				
				if (IsValid(chair)) then
					player.NextSit = CurTime() +1
					
					if (!chair:GetPassenger(1):IsPlayer() and !player:InVehicle()) then
						player.lastSeatEnterPos = player:GetPos()
						player.lastEyeAngles = player:EyeAngles()
					
						player.VehicleEnter = true
						
						player:EnterVehicle(chair)
						player:SetEyeAngles(chair:GetForward():Angle())
						--player:AddAFK()
						
						chair:SetOwner(player)
						
						local position = chair:GetPos()
						
						net.Start("chairs_sitdown")
						--net.WriteVector(Vector(position.x, position.y, position.z +64))
						
						local game = chair:GetParent().game
						
						if (game) then
							position = Vector()
							
							if (game.customangle)then
								position = game.customangle
								
								player:SetEyeAngles((position -player:EyePos()):Angle())
							end
							
							if (game.controller and game.controller.content.npc) then
								position = game.controller.content.npc:EyePos()
								
								player:SetEyeAngles((position -player:EyePos()):Angle())
							end
							
							net.WriteVector(Vector(position.x, position.y, position.z ))
							net.Send(player)
							
							game:AddPlayer(player, chair:GetParent())
						else
							net.WriteVector(Vector())
							net.Send(player)
						end
					end
				end
			end
		end
	end
end)