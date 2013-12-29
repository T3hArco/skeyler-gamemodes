---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
---------------------------

GM.Name 		= "Bunny Hop"
GM.Author 		= "xAaron113x"
GM.Email 		= "xaaron113x@gmail.com"
GM.Website 		= "aaron113.pw"
GM.TeamBased 	= false 

DeriveGamemode("ssbase")
DEFINE_BASECLASS("gamemode_ssbase") --for self.BaseClass

GM.VIPBonusHP = false 
GM.HUDShowVel = true 
GM.HUDShowTimer = true 

SS.Alldoors = {
	"bhop_archives",
	"bhop_monster_jam",
	"bhop_exzha"
}

SS.NoHeightReset = {
	"bhop_muchfast",
	"bhop_exquisite"
}

SS.Heightdoors = {
	"bhop_gnite"
}

TEAM_BHOP = 1  
team.SetUp(TEAM_BHOP, "Hoppers", Color(87, 198, 255), false) 

function GM:EntityKeyValue(ent, key, value) 
	if(ent:GetClass() == "func_door") then
		if(table.HasValue(SS.Alldoors,game.GetMap())) then
			ent.IsP = true
		end
		if(string.find(string.lower(key),"movedir")) then
			if(value == "90 0 0") then
				ent.IsP = true
			end
		end
		if(string.find(string.lower(key),"noise1")) then
			ent.BHS = value
		end
		if(string.find(string.lower(key),"speed")) then
			if(tonumber(value) > 100) then
				ent.IsP = true
			end
			ent.BHSp = tonumber(value)
		end
	end
	if(ent:GetClass() == "func_button") then
		if(table.HasValue(SS.Alldoors,game.GetMap())) then
			ent.IsP = true
		end
		if(string.find(string.lower(key),"movedir")) then
			if(value == "90 0 0") then
				ent.IsP = true
			end
		end
		if(key == "spawnflags") then ent.SpawnFlags = value end
		if(string.find(string.lower(key),"sounds")) then
			ent.BHS = value
		end
		if(string.find(string.lower(key),"speed")) then
			if(tonumber(value) > 100) then
				ent.IsP = true
			end
			ent.BHSp = tonumber(value)
		end
	end
	if(self.BaseClass.EntityKeyValue) then
		self.BaseClass:EntityKeyValue(ent,key,value)
	end
end 

function GM:Move(pl, movedata)
	if(!pl or !pl:IsValid()) then return end
	if pl:IsOnGround() or !pl:Alive() or pl:WaterLevel() > 0 then return end
	
	local aim = movedata:GetMoveAngles()
	local forward, right = aim:Forward(), aim:Right()
	local fmove = movedata:GetForwardSpeed()
	local smove = movedata:GetSideSpeed()
	
	if pl:KeyDown( IN_MOVERIGHT ) then
		smove = (smove * 10) + 500
	elseif pl:KeyDown( IN_MOVELEFT ) then
		smove = (smove * 10) - 500
	end --this is just to ensure that lj is fine
	
	forward.z, right.z = 0,0
	forward:Normalize()
	right:Normalize()

	local wishvel = forward * fmove + right * smove
	wishvel.z = 0

	local wishspeed = wishvel:Length()

	if(wishspeed > movedata:GetMaxSpeed()) then
		wishvel = wishvel * (movedata:GetMaxSpeed()/wishspeed)
		wishspeed = movedata:GetMaxSpeed()
	end

	local wishspd = wishspeed
	wishspd = math.Clamp(wishspd, 0, 30)

	local wishdir = wishvel:GetNormal()
	local current = movedata:GetVelocity():Dot(wishdir)

	local addspeed = wishspd - current

	if(addspeed <= 0) then return end

	local accelspeed = (120) * wishspeed * FrameTime()

	if(accelspeed > addspeed) then
		accelspeed = addspeed
	end

	local vel = movedata:GetVelocity()
	vel = vel + (wishdir * accelspeed)
	movedata:SetVelocity(vel)
	
	if(self.BaseClass && self.BaseClass.Move) then
		return self.BaseClass:Move(pl, movedata)
	else
		return false
	end
end

function GM:IsInArea(ent,vec,vec2)
	local vec3 = ent:GetPos()
	if((vec3.x > vec.x && vec3.x < vec2.x) && (vec3.y > vec.y && vec3.y < vec2.y) && (vec3.z > vec.z && vec3.z < vec2.z)) then
		return true
	else
		return false
	end
end

function GM:OnPlayerHitGround(ply)
	
	if(!table.HasValue(SS.NoHeightReset,game.GetMap())) then
		-- this is my simple implementation of the jump boost, possible conditioning in future: jump height should only increase IF the player pressed jump key, any hitgrounds after the jump key should call this until finished jumping. (complex to do and unneccessary but would make certain kz maps easier in a way (and close to where they are on css))
		ply:SetJumpPower(268.4)
	end
	timer.Simple(0.3,function () ply:SetJumpPower(280) end)
	
	
	local leveldata = {}
	if CLIENT then
		leveldata = self.Levels[ply:GetNetworkedInt("ssbhop_level", 0)]
	else
		leveldata = ply.LevelData
	end
	
	--mpbhop stuff
	local ent = ply:GetGroundEntity()
	if(tonumber(ent:GetNWInt("Platform",0)) == 0) then return end
    if (ent:GetClass() == "func_door" || ent:GetClass() == "func_button") && !table.HasValue(SS.Alldoors,game.GetMap()) && ent.BHSp && ent.BHSp > 100 then
		if(game.GetMap() == "bhop_cartoony" or game.GetMap() == "bhop_dan") then
			ply:SetVelocity( Vector( 0, 0, ent.BHSp*2.4 ) ) --these maps have the weakest func_door boosters known to man. they also have made me make over 6 commits
		else
			ply:SetVelocity( Vector( 0, 0, ent.BHSp*1.9 ) )
		end
	elseif ent:GetClass() == "func_door" || ent:GetClass() == "func_button" then
		if(leveldata and leveldata.id != 1) then
			timer.Simple( leveldata.staytime, function()
				-- setting owner stops collision between two entities
				ent:SetOwner(ply)
				if(CLIENT)then
					ent:SetColor(Color(255,255,255,125)) --clientsided setcolor (SHOULD BE AUTORUN SHARED)
				end
			end)
			timer.Simple( leveldata.respawntime, function()  ent:SetOwner(nil) end)
			timer.Simple( leveldata.respawntime, function()  if(CLIENT)then ent:SetColor(Color (255,255,255,255)) end end)
		else
			ply.cblock = ent
			if(timer.Exists("BlockTimer")) then
				timer.Destroy("BlockTimer")
			end
			timer.Create("BlockTimer",0.5,1,function()
				if(ply && ply:IsValid() && ply.cblock && ply.cblock:IsValid() && ply:GetGroundEntity() == ply.cblock) then
					ply.cblock:SetOwner(ply)
					if(CLIENT)then
						ply.cblock:SetColor(Color(255,255,255,125)) --clientsided setcolor (SHOULD BE AUTORUN SHARED)
					end
					timer.Simple( 0.5, function()  ent:SetOwner(nil) end)
					timer.Simple( 0.5, function()  if(CLIENT)then ent:SetColor(Color (255,255,255,255)) end end)
				end
			end)
		end
	end
	
	if(self.BaseClass && self.BaseClass.OnPlayerHitGround) then
		self.BaseClass:OnPlayerHitGround(ply)
	end
end

/* Spawn Velocity Cap */
function GM:SetupMove(ply, Data) 
	if !ply.InSpawn then return end 
	local vel = Data:GetVelocity() 
	vel.x = math.min(vel.x, 270) 
	vel.y = math.min(vel.y, 270) 
	vel.z = math.min(vel.z, 270) 

	Data:SetVelocity(vel) 
	ply:SetLocalVelocity(vel)

	return Data
end 

if(file.Exists("bhop/gamemode/mapfixes/"..game.GetMap()..".lua","LUA")) then
	HOOKS = {}
	include("bhop/gamemode/mapfixes/"..game.GetMap()..".lua")
	for k,v in pairs(HOOKS) do
		hook.Add(k,k.."_"..game.GetMap(),v)
	end
end
