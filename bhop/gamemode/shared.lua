---------------------------- 
--        Bunny Hop       -- 
-- Created by Skeyler.com -- 
---------------------------- 

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

SS.Nodoors = {
	"bhop_fury",
	"bhop_hive"
}

SS.AutoMaps = {
	"bhop_brax",
	"bhop_fps_max",
	"bhop_superdooperhard"
}

SS.NoHeightReset = {
	"bhop_muchfast",
	"bhop_exquisite",
	"bhop_brax"
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
		if(table.HasValue(SS.Nodoors,game.GetMap())) then
			ent.IsP = false
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
		if(table.HasValue(SS.Nodoors,game.GetMap())) then
			ent.IsP = false
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
	wishspd = math.Clamp(wishspd, 0, 35)

	local wishdir = wishvel:GetNormal()
	local current = movedata:GetVelocity():Dot(wishdir)

	local addspeed = wishspd - current

	if(addspeed <= 0) then return end

	local accelspeed = (150) * wishspeed * FrameTime()

	if(accelspeed > addspeed) then
		accelspeed = addspeed
	end

	local vel = movedata:GetVelocity()
	vel = vel + (wishdir * accelspeed)
	if(pl.InSpawn) then --cap even more in air
		vel.x = math.min(vel.x, 200) 
		vel.y = math.min(vel.y, 200) 
		vel.z = math.min(vel.z, 200) 
	end
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
	
	--mpbhop stuff
	local ent = ply:GetGroundEntity()
	if(tonumber(ent:GetNWInt("Platform",0)) == 0) then return end
    if (ent:GetClass() == "func_door" || ent:GetClass() == "func_button") && ent.BHSp && ent.BHSp > 100 then
		if(game.GetMap() == "bhop_cartoony" or game.GetMap() == "bhop_dan") then
			ply:SetVelocity( Vector( 0, 0, ent.BHSp*2.4 ) ) --these maps have the weakest func_door boosters known to man. they also have made me make over 6 commits
		else
			ply:SetVelocity( Vector( 0, 0, ent.BHSp*1.9 ) )
		end
	elseif ent:GetClass() == "func_door" || ent:GetClass() == "func_button" then
		timer.Simple( 0.06, function()
			-- setting owner stops collision between two entities
			ent:SetOwner(ply)
			if(CLIENT)then
				ent:SetColor(Color(255,255,255,125)) --clientsided setcolor (SHOULD BE AUTORUN SHARED)
			end
		end)
		timer.Simple( 0.75, function()  ent:SetOwner(nil) end)
		timer.Simple( 0.75, function()  if(CLIENT)then ent:SetColor(Color (255,255,255,255)) end end)
	end
	
	if(self.BaseClass && self.BaseClass.OnPlayerHitGround) then
		self.BaseClass:OnPlayerHitGround(ply)
	end
end

local cache = false --caching
local cacheresult = false

/* Spawn Velocity Cap */
function GM:SetupMove(ply, Data) 
	if(!cache) then
		cache = true
		if(table.HasValue(SS.AutoMaps,game.GetMap())) then
			cacheresult = true
		else
			cacheresult = false
		end
	end
	if(cacheresult) then
		local buttonsetter = Data:GetButtons()
		if(bit.band(buttonsetter,IN_JUMP)>0) then
			if ply:WaterLevel() < 2 && ply:GetMoveType() != MOVETYPE_LADDER && !ply:IsOnGround() then
				buttonsetter = bit.band(buttonsetter, bit.bnot(IN_JUMP))
			end
			Data:SetButtons(buttonsetter)
		end
	end
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
