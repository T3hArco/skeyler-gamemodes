----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
--	Models By Jaanus
----------------------------------------

local require = require
local pairs = pairs
local PrintTable = PrintTable

local _G = _G

module( "unit" )

if( not _G.sh_unit ) then return end

for k, v in pairs( _G.sh_unit ) do
	if not _M[k] then
		_M[k] = v
	end
end

_G.sh_unit = nil
_G = nil