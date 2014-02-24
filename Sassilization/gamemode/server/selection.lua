----------------------------------------
--	Sassilization
--  Shared Unit Module
--	http://sassilization.com
--	By Spacetech & Sassafrass
----------------------------------------

concommand.Add("sa_select", function(ply, cmd, args)
	
	local Empire = ply:GetEmpire()
	if( not Empire ) then return end
	
	for _, uid in pairs( args ) do
		
		local u = Unit:Unit( tonumber(uid) )
		if( Unit:ValidUnit( u ) ) then
			u:Select( true )
		end
		
	end
	
end)

concommand.Add("sa_deselect_units", function(pl, cmd, args)
	
	local Empire = pl:GetEmpire()
	if( not Empire ) then return end
	
	if( Empire:NumSelectedUnits() > 0 ) then
		Empire:DeselectAllUnits()
	end
	
end )
	
