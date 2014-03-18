function GM:Initialize()
	
	self.waitscreen = math.random( 1, 2 )
	
	resource.AddFile("materials/jaanus/sassilization0"..self.waitscreen..".vtf")
	resource.AddFile("materials/jaanus/sassilization0"..self.waitscreen..".vmt")
	
end

concommand.Add("dev_ent", function(ply, cmd, args)
	local tr = ply:GetEyeTraceNoCursor()
	local e = ents.Create(args[1])
	e:SetPos(tr.HitPos)
	e:SetAngles((ply:GetForward()*-1):Angle())
	e:Spawn()
end)

function GM:InitPostEntity()
	
	local mines = ents.FindByClass("iron_mine")
	local farms = ents.FindByClass("farm")
	if not ( #mines > 0 and #farms > 0 ) then
		allow_setup = true
		Msg( "No resources exist, Allowing players to setup their own.\n" )
	else
		Msg( "There are ".. #mines .." iron mines and "..#farms.." farms.\n" )
	end
	if #ents.FindByClass("allow_setup") > 0 then
		Msg( "Allowing players to setup their own resources by allow_setup override.\n" )
		allow_setup = true
	end
	
	self.SpawnPoints = ents.FindByClass("info_player_start")
	self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass("gmod_player_start") )
end

function GM:Think()

end

function GM:ShowHelp(ply)
end

function GM:ShowTeam(ply)
end

function GM:ShowSpare1(ply)	
end

function GM:ShowSpare2(ply)
end

util.AddNetworkString( "ClearVS" )
function GM:UnlockPlayers()
	
	for _, pl in pairs(player.GetAll()) do
		
		pl:UnLock()
		
	end
	
	net.Quick( "ClearVS" )
	
end

function GM:ShutDown()
	
end