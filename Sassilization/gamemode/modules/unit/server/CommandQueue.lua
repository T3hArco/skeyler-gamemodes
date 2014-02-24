----------------------------------------
--	Sassilization
--  Shared Unit Module
--	http://sassilization.com
--	By Spacetech & Sassafrass
----------------------------------------

assert( SA )

local QUEUE = {}
QUEUE.MaxSize = 10

function SA.NewCommandQueue()
	local objQueue = {__index = QUEUE}
	setmetatable(objQueue, objQueue)
	
	return objQueue
end

--[[
-- Adds a command to the end of the queue
--]]
function QUEUE:Add(vValue)
	if( #self + 1 > self.MaxSize ) then
		return false
	end
	table.insert(self, 1, vValue)
	return true
end

--[[
-- Adds a command to the beginning of the queue
--]]
function QUEUE:Push(vValue)
	if( #self + 1 > self.MaxSize ) then
		return false
	end
	self[#self + 1] = vValue
	return true
end

--[[
-- Removes the command at the front of the queue
--]]
function QUEUE:Pop()
	self[#self] = nil
end

--[[
-- Returns the first command in the queue
--]]
function QUEUE:GetHead()
	return self[#self]
end

function QUEUE:Clear()
	while( self[#self] ) do
		self[#self] = nil
	end
end