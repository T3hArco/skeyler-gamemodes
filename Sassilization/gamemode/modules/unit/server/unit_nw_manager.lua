----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

assert( unit )

local nw_manager = {}
unit.NW_Manager = nw_manager

nw_manager.NWEnts = {}
nw_manager.NWEntCount = 0

function nw_manager:RegisterUnit( Unit )
	
	for _, NWEnt in ipairs( self.NWEnts ) do
		
		if( NWEnt.UnitCount < 4 ) then
			NWEnt:AddUnit( Unit )
			return
		end
		
	end
	
	self:CreateNWEnt():AddUnit( Unit )
	
end

function nw_manager:CreateNWEnt()
	
	Msg( "NWManager: Creating new NW Ent\n" )
	local NWEnt = ents.Create( "unit_nw_entity" )
	NWEnt:Spawn()
	NWEnt:Activate()
	
	self.NWEnts[ self.NWEntCount + 1 ] = NWEnt
	self.NWEntCount = self.NWEntCount + 1
	
	return NWEnt
	
end
