----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

--This code is old and now useless //Hateful
/*
hook.Add( "modules.OnModuleLoaded", "alliance.OnModuleLoaded", function( moduleName )
	
	if( moduleName == "empire" ) then
		
		local EMPIRE = empire.methods --mt.__index
		
		AccessorFunc( EMPIRE, "m_alAlliance", "Alliance" )
		
		function EMPIRE:Allied( empire2 )
			
			Allied( self, empire2 )
			
		end
		hook.Remove( "modules.OnModuleLoaded", "alliance.OnModuleLoaded" )
		
		EMPIRE = nil
		
	end
	
end )


module( "sh_alliance" )

ALLIANCES = {}

mt = {}
methods = {}
mt.__index = methods


function methods:AllianceID()
	
	return self.m_iID
	
end

function Allied( empire1, empire2 )
	
	if( not (empire1 and empire2) ) then return end
	
	local alliance1 = empire1:GetAlliance()
	local alliance2 = empire2:GetAlliance()
	
	if( not (alliance1 and alliance2) ) then return end
	if( alliance1 == alliance2 ) then
		
		return true
		
	end
	
end
*/