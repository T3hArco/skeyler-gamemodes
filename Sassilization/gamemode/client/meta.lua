

local META = FindMetaTable( "Player" )
if( !META ) then return end

function META:GetPlayerChatColor()
	local Empire = self:GetEmpire()
	if(Empire) then
		if(Empire:HasColor()) then
			return Empire:GetColor()
		end
	end
	return team.GetColor(self:Team())
end