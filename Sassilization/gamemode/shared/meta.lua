----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
--	Models By Jaanus
----------------------------------------

local META = FindMetaTable( "Player" )
if (not META) then return end


META = nil

local META = FindMetaTable( "Entity" )
if (not META) then return end

/*
function META:IsDead()
	local self = self.anim and self.anim or self
	if not self:GetNWBool("dead") then
		return false
	elseif self:GetNWBool("dead") and self:GetNWBool("spawning") then
		return false
	elseif self:GetNWBool("dead") then
		return true
	end
end
*/

META = nil