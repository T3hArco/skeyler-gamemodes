--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

AddCSLuaFile("shared.lua")
include("shared.lua")

util.PrecacheSound("sassilization/workshopcomplete.wav")

function ENT:Initialize()
	self:SetLevel(1)
	self:Setup("workshop")
end

function ENT:OnBuilt( Empire )
	--TODO
	self:EmitSound("sassilization/workshopcomplete.wav")

end

function ENT:OnLevel(Level)
	local Empire = self:GetEmpire()
	if(Empire and Level > 1) then
		--TODO
	end
	timer.Simple( 1, function()
		if( IsValid( self ) ) then
			self:ResetSequence( self:LookupSequence("idle") )
		end
	end )
end

function ENT:OnDestroy(Info, Empire, Atacker)
	if(self:GetLevel() > 1) then
	end
	
	GAMEMODE:UpdateTerritories()
end