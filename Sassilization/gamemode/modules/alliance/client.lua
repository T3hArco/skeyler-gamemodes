----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

--This code is old and now useless //Hateful
/*
local require = require
local pairs = pairs
local _G = _G

module( "alliance" )

if( not _G.sh_alliance ) then return end
for k, v in pairs( _G.sh_alliance ) do
	if not _M[k] then
		_M[k] = v
	end
end

_G.sh_alliance = nil
_G = nil
*/

function SetAllianceRequest(len)
	ent = net.ReadEntity()
	local string = net.ReadString()
	if string != "nil" then
		ent.request = string
	else
		ent.request = nil
	end
end
net.Receive("SetAllianceRequest", SetAllianceRequest)

function SetAlliance(len)
	ent = net.ReadEntity()
	local string = net.ReadString()
	if string != "nil" then
		ent.alliance = string
	else
		ent.alliance = nil
	end
end
net.Receive("SetAlliance", SetAlliance)

function SetPublicAlliance(len)
	ply1 = net.ReadEntity()
	ply1.allies = net.ReadTable()
end
net.Receive("SetPublicAlliance", SetPublicAlliance)

function IsAllied(emp1, emp2)
	if !emp1 or !emp2 then return end
	local player1 = emp1:GetPlayer()
	local player2 = emp2:GetPlayer()
	if player1 and player2 and player1.allies and player2.allies then
		for k,v in pairs(player1.allies) do
			if v == player2 then
				return true
			end
		end
	end
	return false
end