---------------------------
--        Deathrun       -- 
-- Created by xAaron113x --
---------------------------

GM.Name 		= "Deathrun"
GM.Author 		= "xAaron113x"
GM.Email 		= "xaaron113x@gmail.com"
GM.Website 		= "aaron113.pw"
GM.TeamBased 	= true 

DeriveGamemode("ssbase")
DEFINE_BASECLASS("gamemode_ssbase") --for self.BaseClass

PLAYER_META = FindMetaTable("Player")

TEAM_DEAD = 4
TEAM_RUNNER = 3  
TEAM_DEATH = 2 

function GM:CreateTeams() 
	team.SetUp(TEAM_DEAD, "Dead", Color(177, 86, 255), false) 
	team.SetUp(TEAM_RUNNER, "Runners", Color(69, 192, 255), false) 
	team.SetUp(TEAM_DEATH, "Deaths", Color(255, 85, 85), false) 

	team.SetSpawnPoint(TEAM_RUNNER, "info_player_counterterrorist")
	team.SetSpawnPoint(TEAM_DEATH, "info_player_terrorist")
	team.SetSpawnPoint(TEAM_DEAD, "info_player_counterterrorist") 
end 

SS.NoHeightReset = {
	"bhop_muchfast",
	"bhop_exquisite"
}

function GM:OnPlayerHitGround(ply)
	if(!table.HasValue(SS.NoHeightReset,game.GetMap())) then
		-- this is my simple implementation of the jump boost, possible conditioning in future: jump height should only increase IF the player pressed jump key, any hitgrounds after the jump key should call this until finished jumping. (complex to do and unneccessary but would make certain kz maps easier in a way (and close to where they are on css))
		ply:SetJumpPower(268.4)
	end
	timer.Simple(0.3,function () ply:SetJumpPower(280) end) 
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
	movedata:SetVelocity(vel)
	
	if(self.BaseClass && self.BaseClass.Move) then
		return self.BaseClass:Move(pl, movedata)
	else
		return false
	end
end
