SS.Lobby.Chair = {}

local chairs = {}

------------------------------------------------
-- ENTITY
------------------------------------------------

function ENTITY_META:IsChair()
	if (self.chair) then return true end
	if (self:IsVehicle()) then return end
	
	local model = self:GetModel()
	
	for _, chair in pairs(chairs) do
		if (model == chair.model) then
			self.chair = true
			self.slots = table.Copy(chair.slots)
			
			for _, slot in pairs(self.slots) do
				slot.parent = self
				
				if (SERVER) then
					local seatData = list.Get("Vehicles")["Seat_Jeep"]
					
					local seat = ents.Create( "prop_vehicle_prisoner_pod" )
					seat:SetParent( self )
					seat:SetModel(seatData.Model)
					seat:SetKeyValue( "vehiclescript" , "scripts/vehicles/prisoner_pod.txt" )
					seat:SetAngles( self:GetAngles() + (slot.ang or Angle(0,-90,0)) )
					seat:SetPos( self:GetPos() + self:GetRight() * slot.pos.x + self:GetForward() * slot.pos.y + self:GetUp() * slot.pos.z )
					seat:DrawShadow( false )
				
					if (seatData.KeyValues) then
						for k2, v2 in pairs(seatData.KeyValues) do
							seat:SetKeyValue(k2, v2)
						end
					end
					
					seat:Spawn()
					seat:Activate()
					seat:SetNotSolid(true)
					seat:SetNoDraw(true)
					
					if (seatData.Members) then
						table.Merge(seat, seatData.Members)
					end
			
					seat.chair = true
					seat.exits = slot.exits
					
					self:DeleteOnRemove(seat)
					
					slot.seat = seat
				end
			end
			
			return true
		end
	end
	
	return nil
end

--------------------------------------------------
-- PLAYER
--------------------------------------------------

function PLAYER_META:IsSitting()
	return self:InVehicle() or self.sitting
end

------------------------------------------------
-- CHAIRS
------------------------------------------------

chairs = {
	{
		model = "models/props/de_inferno/bench_wood.mdl",
		slots = {
			{
				pos = Vector( 30, -15, 3 ),
				ang = Angle( 0, 180, 0 ),
				exits = {
					Vector( 0, 48, 0 ),
					Vector( 36, 48, 0 ),
					Vector( -36, 48, 0 ),
					Vector( 64, 0, 0 )
				}
			},
			{
				pos = Vector( 0, -15, 3 ),
				ang = Angle( 0, 180, 0 ),
				exits = {
					Vector( 0, 48, 0 ),
					Vector( 36, 48, 0 ),
					Vector( -36, 48, 0 )
				}
			},
			{
				pos = Vector( -30, -15, 3 ),
				ang = Angle( 0, 180, 0 ),
				exits = {
					Vector( 0, 48, 0 ),
					Vector( 36, 48, 0 ),
					Vector( -36, 48, 0 ),
					Vector( -64, 0, 0 )
				}
			}
		}
	},
	{
		model = "models/captainbigbutt/skeyler/furniture/couch.mdl",
		slots = {
			{
				pos = Vector(25, 6, 10),
				exits = {
					Vector( 0, 48, 0 ),
					Vector( 36, 48, 0 ),
					Vector( -36, 48, 0 ),
					Vector( 64, 0, 0 )
				}
			},
			{
				pos = Vector(0, 6, 10),
				exits = {
					Vector( 0, 48, 0 ),
					Vector( 36, 48, 0 ),
					Vector( -36, 48, 0 )
				}
			},
			{
				pos = Vector(-25, 6, 10),
				exits = {
					Vector( 0, 48, 0 ),
					Vector( 36, 48, 0 ),
					Vector( -36, 48, 0 ),
					Vector( -64, 0, 0 )
				}
			}
		}
	},
	{
		model = "models/captainbigbutt/furniture/couch_small.mdl",
		slots = {
			{
				pos = Vector( 0, 15, 3 ),
				exits = {
					Vector( 0, 48, 0 ),
					Vector( 36, 48, 0 ),
					Vector( -36, 48, 0 )
				}
			}
		}
	},
	-- {
	-- 	model = "models/props_c17/FurnitureChair001a.mdl",
	-- 	slots = {
	-- 		{
	-- 			pos = Vector( 0, 5, -21 ),
	-- 			exits = {
	-- 				Vector( 0, -48, 0 ),
	-- 				Vector( 36, -48, 0 ),
	-- 				Vector( -36, -48, 0 )
	-- 			}
	-- 		}
	-- 	}
	-- },
	{
		model = "models/props_c17/chair_stool01a.mdl",
		slots = {
			{
				pos = Vector( 0, 0, 18 ),
				exits = {
					Vector( 0, -48, 0 ),
					Vector( 36, -48, 0 ),
					Vector( -36, -48, 0 )
				}
			}
		}
	},
	{
		model = "models/props/cs_militia/barstool01.mdl",
		slots = {
			{
				pos = Vector( 0, 5, 18 ),
				exits = {
					Vector( 0, -48, 0 ),
					Vector( 36, -48, 0 ),
					Vector( -36, -48, 0 )
				}
			}
		}
	},
	{
		model = "models/casino/bar_stool/bar_stool.mdl",
		slots = {
			{
				pos = Vector( 0, 0, 0 ),
				exits = {
					Vector( 0, -48, 0 ),
					Vector( 36, -48, 0 ),
					Vector( -36, -48, 0 )
				}
			}
		}
	},
	{
		model = "models/props/cs_office/chair_office.mdl",
		slots = {
			{
				pos = Vector( 0, 0, 0 ),
				/*Calc later*/			
			}		
		}
	},
	{
		model = "models/props/de_tides/patio_chair2.mdl",
		slots = {
			{
				pos = Vector( 0, 0, 0 ),
				ang = Angle( 0, 270, 0 ),
				exits = {
					Vector( 35,0, 0),
					Vector( -35,0, 0),
				}
			
			}		
		}
	}
}