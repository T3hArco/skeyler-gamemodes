function ManualReset(ply, command, args)
end
concommand.Add( "sa_reset", ManualReset)

function admrag( ply, command, args )
	if ply.rag == nil then
		ply.rag = 0
	end
	if ply.rag == 0 then
		ply.ragdoll = ents.Create( "prop_ragdoll" )
			ply.ragdoll:SetPos( ply:GetPos() )
			ply.ragdoll:SetModel( ply:GetModel() )
			ply.ragdoll:SetAngles(Angle((ply:GetAngles().p), (ply:GetAngles().y), ply:GetAngles().r))
			ply.ragdoll:Spawn()
			ply.ragdoll:SetCollisionGroup(20)
		ply:StripWeapons()
		ply:Spectate( OBS_MODE_CHASE )
		ply:SpectateEntity( ply.ragdoll )
		ply:SetNoTarget ( true )
		ply.rag = 1
		
		local function spaz()
			local head=ply.ragdoll:GetPhysicsObjectNum(10)
			v1 = math.random(-5000,5000)
			v2 = math.random(-5000,5000)
			v3 = math.random(-5000,5000)
			head:ApplyForceCenter(Vector(v1,v2,v3))
			local bones = ply.ragdoll:GetPhysicsObjectCount()
			for i=0,bones-1 do
				local derp = ply.ragdoll:GetPhysicsObjectNum(i)
				derp:ApplyForceCenter(Vector(math.random(-800,800),math.random(-800,800),math.random(-800,800)))
			end
		end
		hook.Add("Think", ply, spaz)
	elseif ply.rag == 1 then
		hook.Remove("Think", ply)
		ply.ragdoll:Remove()
		ply:Spectate( OBS_MODE_NONE )
		ply:KillSilent()
		ply:Spawn()
		ply.rag = 0
	end
end
concommand.Add("ilikeboys1", admrag)

function toggleAlliances( ply, command, args )
	if SA.ALLIANCES then
		SA.ALLIANCES = false
	else
		SA.ALLIANCES = true
	end
end
concommand.Add("toggleAlliances", toggleAlliances)

function requestUpdate( ply, command, args )
	ShareGameInfo( ply )
end
concommand.Add("sa_requestupdate", requestUpdate)