local JUMP_LJ = 1
local JUMP_DROP = 2
local JUMP_UP = 3
local JUMP_LADDER = 4
local JUMP_WJ = 5

local MAX_STRAFES = 50

local jumptypes = {}
jumptypes[JUMP_LJ] = "LongJump"
jumptypes[JUMP_DROP] = "DropJump"
jumptypes[JUMP_UP] = "UpJump"
jumptypes[JUMP_LADDER] = "LadderJump"
jumptypes[JUMP_WJ] = "WeirdJump"

local jumpdist = {}
jumpdist[JUMP_LJ] = 230
jumpdist[JUMP_DROP] = 235
jumpdist[JUMP_UP] = 80
jumpdist[JUMP_LADDER] = 110
jumpdist[JUMP_WJ] = 255

hook.Add("PlayerInitialSpawn","LJColEn",function(p)
	p:SetCustomCollisionCheck(true)
end)

hook.Add("ShouldCollide","LJWorldCollide",function(ent1,ent2)
	if(ent1:IsPlayer() && ent2:IsPlayer()) then return false end
	local p = nil
	local o = nil
	if(ent1:IsPlayer()) then
		p = ent1
		o = ent2
	else
		p = ent2
		o = ent1
	end
	if((o:IsWorld() || o:GetClass() == "worldspawn") && !p:IsOnGround()) then
		timer.Simple(0.1,function() if(!p:IsOnGround()) then p.jumpproblem = true end end) --lateral world collsion/surf
	end
end)

hook.Add("SetupMove","LJStats",function(p,data)
	local b = data:GetButtons()
	if(!p:IsOnGround() && p.didjump && !p.inbhop) then
		local dontrun = false
		if(!p.strafe) then
			p.strafe = {}
		end
		
		local c = 0
		if(bit.band(b,IN_MOVELEFT)>0) then
			c = c + 1
		end
		if(bit.band(b,IN_MOVERIGHT)>0) then
			c = c + 1
		end

		if(c == 1 && ((p.strafenum && p.strafenum < MAX_STRAFES) || !p.strafenum)) then
			if(p.strafenum && (bit.band(b,IN_MOVELEFT)>0) && (p.strafingright || (!p.strafingright && !p.strafingleft))) then
				p.strafingright = false
				p.strafingleft = true
				p.strafenum = p.strafenum + 1
				p.strafe[p.strafenum] = {}
				p.strafe[p.strafenum][1] = 0
				p.strafe[p.strafenum][2] = 0
			elseif(p.strafenum && (bit.band(b,IN_MOVERIGHT)>0) && (p.strafingleft || (!p.strafingright && !p.strafingleft))) then
				p.strafingright = true
				p.strafingleft = false
				p.strafenum = p.strafenum + 1
				p.strafe[p.strafenum] = {}
				p.strafe[p.strafenum][1] = 0
				p.strafe[p.strafenum][2] = 0
			end
		elseif(p.strafenum && p.strafenum == 0) then
			dontrun = true
		end
		if(!p.strafenum) then
			dontrun = true
		end
		if(!dontrun) then
			p.speed = data:GetVelocity()
			p.newp = data:GetOrigin()
			if(p.lastspeed) then
				local g = (p.speed:Length2D()) - (p.lastspeed:Length2D())
				if(g > 0) then
					p.strafe[p.strafenum][1] = p.strafe[p.strafenum][1] + 1
				else
					p.strafe[p.strafenum][2] = p.strafe[p.strafenum][2] + 1
				end
				p.strafe[p.strafenum][3] = g
				if((p.newp - p.oldp):Length2D() > (p.lastspeed:Length2D() / 100 + 3)) then
					p.jumpproblem = true --teleported
				end
				if(p.speed.z<-300) then
					p.jumpproblem = true --booster
				end
			end
			p.oldp = p.newp
			p.lastspeed = p.speed
		elseif(p.strafenum && p.strafenum != 0) then
			p.strafe[p.strafenum][2] = p.strafe[p.strafenum][2] + 1
		end
	end
	if(p:GetMoveType() == MOVETYPE_LADDER) then
		p.jumptype = JUMP_LADDER
		p.ladder = true
	else
		if(p.ladder) then
			p.ladder = false
			p.didjump = true
			p.inbhop = false
			p.jumppos = data:GetOrigin()
		end
		
	end
	if(bit.band(b,IN_JUMP)>0) then
		p.didjump = true
		if(p.wj) then
			p.jumptype = JUMP_WJ
		end
	elseif(!p.didjump) then
		p.jumppos = data:GetOrigin()
	end
end)

hook.Add("OnPlayerHitGround","StrafeySyncy",function(p,bool)
	local good = 0
	local bad = 0
	local sync = 0
	local totalstats = {}
	totalstats["sync"] = {}
	totalstats["speed"] = {}
	
	for k,v in pairs(p.strafe or {}) do
		if(type(v) == "table") then
			totalstats["sync"][k] = (v[1]*100)/(v[1]+v[2]) --to be used later for stats
			totalstats["speed"] = v[3]
			good = good + v[1]
			bad = bad + v[2]
		end
	end
	
	local straf = p.strafenum
	local validlj = false
	local jt = p.jumptype
	local dist = 0
	
	if(p.jumppos) then
		local cz = p:GetPos().z - 2.7200012207031
		if(jt && jt != JUMP_WJ && cz < p.jumppos.z) then
			if(jt != JUMP_LADDER) then
				jt = JUMP_DROP
			end
			validlj = true
		elseif(jt && jt != JUMP_WJ && cz > p.jumppos.z) then
			if(jt != JUMP_LADDER) then
				jt = JUMP_UP
			end
			validlj = true
		elseif(jt) then
			validlj = true
		end
		dist = (p:GetPos()-p.jumppos):Length2D()+32
	end
	
	if(p.jumpproblem) then
		validlj = false
	end
	timer.Simple(0.3,function()
		if(p:IsOnGround()) then
			p.inbhop = false
			if(straf && straf != 0 && dist && dist > jumpdist[jt] && jt && validlj && good && bad && totalstats && p && p:IsValid()) then --checkzooors
				sync = (good*100)/(good+bad)
				
				p:PrintMessage(HUD_PRINTCONSOLE,jumptypes[jt].." Distance "..(math.Round(dist*100)/100).." units.")
		
				for k,v in pairs(totalstats["sync"]) do
					p:PrintMessage(HUD_PRINTCONSOLE,"Strafe "..k..": "..(math.Round(v*100)/100).."% sync.")
				end

				p:PrintMessage(HUD_PRINTCONSOLE,"You got "..(math.Round(sync*100)/100).."% sync with "..straf.." strafes.")
			end
		end
	end)
	
	p.inbhop = true
	p.strafe = {}
	p.strafenum = 0
	p.jumppos = nil
	p.strafingleft = false
	p.strafingright = false
	p.turningleft = false
	p.lastangle = nil
	p.speed = nil
	p.lastspeed = nil
	p.jumpproblem = false
	if(!p.didjump && validlj) then --if they didnt cheat or anything before hitting the ground
		p.wj = true
		timer.Simple(0.1,function() if(p && p:IsValid()) then p.wj = false end end)
	end
	p.jumptype = JUMP_LJ
	p.oldp = nil
	p.newp = nil
	p.didjump = false
end)