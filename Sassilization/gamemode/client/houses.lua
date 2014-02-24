----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

SA.Houses = {}

net.Receive( "house.Create", function( len )
	local count = net.ReadUInt(8)
	
	for i = 1, count do
		local pos = net.ReadVector()
		local ang = net.ReadAngle()
		local eid = net.ReadUInt(8)
		local empID = net.ReadUInt(8)
		local mdlNum = net.ReadUInt(8)
		local Empire = empire.GetByID( empID )
		
		if( not Empire ) then continue end
		
		HOUSE = "models/mrgiggles/sassilization/House"..mdlNum..".mdl"
		
		util.Effect( "house", EffectData(), true, false )
		
		local mdl = HOUSE
		
		HOUSE = nil
		
		-- local mdl = ClientsideModel( "models/jaanus/citybuilding0"..mdlNum..".mdl", RENDERGROUP_TRANSLUCENT )
		-- mdl:SetModel( "models/jaanus/citybuilding0"..mdlNum..".mdl" )
		-- mdl:PhysicsInit( SOLID_VPHYSICS )
		-- mdl:SetSolid( SOLID_VPHYSICS )
		
		mdl:SetMoveType( MOVETYPE_NONE )
		mdl:SetPos( pos )
		mdl:SetAngles( ang )
		mdl:SetColor( Empire:GetColor() )
		
		local phys = mdl:GetPhysicsObject()
		
		if( phys and IsValid( phys ) ) then
			phys:SetPos( mdl:GetPos() )
			phys:SetAngles( mdl:GetAngles() )
			phys:EnableMotion( false )
		end
		
		-- mdl:Spawn()
		-- mdl:Activate()
		mdl.eid = eid
		mdl.Foundation = building.CreateFoundation( mdl )
		SA.Houses[ eid ] = mdl
	end
end)

net.Receive( "house.Remove", function( len )
	
	local eid = net.ReadUInt(8)
	local event_type = net.ReadUInt(8)
	
	GAMEMODE:RemoveHouse( SA.Houses[ eid ] )
	--TODO: Remove the house or destroy the house or sell the house

end )

function GM:RemoveHouse( house, event_type )

	if( not house ) then return end
	
	house:Remove()
	if( house.Foundation ) then
		house.Foundation:Destroy()
		house.Foundation = nil
	end
	
	SA.Houses[ house.eid ] = nil
	
end