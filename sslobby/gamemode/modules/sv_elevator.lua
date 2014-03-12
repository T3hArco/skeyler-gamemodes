SS.Lobby.Elevator = {}

local object = {}
object.__index = object

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Elevator.New()
	local elevator = {}
	
	elevator.stored = {}
	
	setmetatable(elevator, object)

	return elevator
end

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Elevator.Call(id)
	
end

---------------------------------------------------------
--
---------------------------------------------------------

function object:SetTop(elevator)
	self.top = elevator
end

---------------------------------------------------------
--
---------------------------------------------------------

function object:SetFloor(elevator)
	self.floor = elevator
end

---------------------------------------------------------
--
---------------------------------------------------------

function object:SetCurrent(elevator)
	self.current = elevator
end

---------------------------------------------------------
--
---------------------------------------------------------

function object:GetCurrent()
	return self.current
end

---------------------------------------------------------
--
---------------------------------------------------------

function object:SetMoving(bool)
	self.moving = bool
end

---------------------------------------------------------
--
---------------------------------------------------------

function object:IsMoving()
	return self.moving
end

---------------------------------------------------------
--
---------------------------------------------------------

function object:AddElevator(elevator)
	table.insert(self.stored, elevator)
end

---------------------------------------------------------
--
---------------------------------------------------------

function object:CloseDoors()
	local elevators = self.stored
	
	for i = 1, #elevators do
		local elevator = elevators[i]
		
		elevator:CloseDoors()
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

hook.Add("InitPostEntity", "ss.lobby.elevator", function()
	timer.Simple(0.5, function()
		local elevators = ents.FindByClass("info_elev")
		
		local compare = 64
		local lowestElevators = {}
		
		for k, elevator in pairs(elevators) do
			local position = elevator:GetPos()
			
			if (position.z <= compare) then
				compare = position.z
				
				table.insert(lowestElevators, elevator)
			end
		end
		
		for i = 1, #lowestElevators do
			local elevator = lowestElevators[i]
			local controller = SS.Lobby.Elevator.New()
			controller:SetFloor(elevator)
			controller:SetCurrent(elevator)
			controller:SetMoving(false)
			controller:AddElevator(elevator)
			
			elevator.controller = controller
		end
		
		local compare = 216
		local highestElevators = {}
		
		for k, elevator in pairs(elevators) do
			local position = elevator:GetPos()
			
			if (position.z >= compare) then
				compare = position.z
				
				table.insert(highestElevators, elevator)
			end
		end
		
		for i = 1, #highestElevators do
			local elevator = highestElevators[i]
			local position = elevator:GetPos()
			
			for i2 = 1, #lowestElevators do
				local lowerElevator = lowestElevators[i2]
				local lowerPosition = lowerElevator:GetPos()
				
				if (position.x == lowerPosition.x and position.y == lowerPosition.y) then
					elevator.controller = lowerElevator.controller
					
					lowerElevator.controller:SetTop(elevator)
					lowerElevator.controller:AddElevator(elevator)
				end
			end
		end
		
		for k, elevator in pairs(elevators) do
			if (!table.HasValue(lowestElevators, elevator) and !table.HasValue(highestElevators, elevator)) then
				local position = elevator:GetPos()
				
				for i = 1, #lowestElevators do
					local lowerElevator = lowestElevators[i]
					local lowerPosition = lowerElevator:GetPos()
					
					if (position.x == lowerPosition.x and position.y == lowerPosition.y) then
						elevator.controller = lowerElevator.controller
						elevator.controller:AddElevator(elevator)
					end
				end
			end
		end
		
		local indicators = ents.FindByClass("elev_indicator")
		
		for k, indicator in pairs(indicators) do
			local elevatorID = indicator:GetElevatorID()
			
			for k, elevator in pairs(elevators) do
				local id = elevator:GetID()
				
				if (elevatorID == id) then
					indicator:SetElevator(elevator)
					elevator:SetIndicator(indicator)
				end
			end
		end
	end)
end)