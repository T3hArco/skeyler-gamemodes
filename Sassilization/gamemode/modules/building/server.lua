----------------------------------------
--	Sassilization
--  Server Building Module
--	http://sassilization.com
--	By Spacetech & Sassafrass
----------------------------------------

local require = require
local pairs = pairs
local _G = _G

module( "building" )

if( not _G.sh_building ) then return end

for k, v in pairs( _G.sh_building ) do
	if not _M[k] then
		_M[k] = v
	end
end

_G.sh_building = nil
_G = nil