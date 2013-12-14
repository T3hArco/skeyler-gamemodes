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
jumpdist[JUMP_UP] = 200
jumpdist[JUMP_LADDER] = 110
jumpdist[JUMP_WJ] = 255

hook.Add("PlayerInitialSpawn","LJColEn",function(p)
	p:SetCustomCollisionCheck(true)
end)

hook.Add("SetupMove","LJStats",function(p,data)
	local b = data:GetButtons()
	if(!p:IsOnGround() && p.didjump && !p.inbhop) then
		if(p:Crouching()) then
			p.ducking = true
		end
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
				local cp = p.newp
				local op = p.oldp
				if(p.lastducking && !p:Crouching()) then
					op.z = op.z - 8.5
				elseif(!p.lastducking && p:Crouching()) then
					cp.z = cp.z - 8.5
				end
				if(p:Crouching()) then
					p.lastducking = true
				else
					p.lastducking = false
				end
				if((cp - op):Length2D() > (p.lastspeed:Length2D() / 100 + 3)) then
					p.tproblem = true --teleported
					print('tp')
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
			timer.Simple(0.2,function()
				p.jumpproblem = false
				p.lastent = nil
			end)
		end
		
	end
	if(p:IsOnGround() && !p.lastonground) then
		OnLand(p,data:GetOrigin())
	end
	if(p:IsOnGround()) then
		p.lastonground = true
	else
		p.lastonground = false
	end
	if(bit.band(b,IN_JUMP)>0 && p:IsOnGround()) then
		if(p.wj) then
			p.jumptype = JUMP_WJ
			p.inbhop = false
		end
		timer.Simple(0.2,function()
			p.didjump = true
			p.lastent = nil
		end)
		p.jumppos = data:GetOrigin()
	end
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
	if(p.didjump && o != p.lastent) then --wjs mess this up
		timer.Simple(1,function()
			if(!p:IsOnGround() && !p.inbhop && p.didjump) then
				local t = util.QuickTrace(p:GetPos()+Vector(0,0,2),Vector(0,0,-34),{ply})
				if(!t.Hit) then
					p.jumpproblem = true --definite wall collision
				elseif(t.HitPos) then
					if(p:GetPos().z-t.HitPos.z<=0.2) then
						p.jumpproblem = true --surf
					end --both conditions mean surfing/world collision!
				end
			end
		end)
	end
	p.lastent = o
 end)

function OnLand(p,jpos)
	local good = 0
	local bad = 0
	local sync = 0
	local totalstats = {}
	totalstats["sync"] = {}
	totalstats["speed"] = {}
	
	for k,v in pairs(p.strafe or {}) do
		if(type(v) == "table") then
			totalstats["sync"][k] = (v[1]*100)/(v[1]+v[2]) --to be used later for stats
			totalstats["speed"][k] = v[3]
			good = good + v[1]
			bad = bad + v[2]
		end
	end
	
	local straf = p.strafenum
	local validlj = false
	local jt = p.jumptype
	local dist = 0
	
	if(p.jumppos) then
		
		local cz = jpos.z
		if(cz-p.jumppos.z > -1 && cz-p.jumppos.z < 1) then
			cz = p.jumppos.z
		end
		if(jt && jt != JUMP_WJ && cz < p.jumppos.z) then
			if(jt != JUMP_LADDER) then
				jt = JUMP_DROP
				validlj = true
			else
				validlj = true
				if(p.jumppos.z - cz > 20) then
					validlj = false
				end
			end
		elseif(jt && jt != JUMP_WJ && cz > p.jumppos.z) then
			if(jt != JUMP_LADDER) then
				jt = JUMP_UP
				validlj = true
			else
				validlj = true
				if(p.jumppos.z - cz < -20) then
					validlj = false
				end
			end
		elseif(jt ) then
			if(jt == JUMP_WJ && cz == p.jumppos.z) then
				validlj = true
			elseif(jt != JUMP_WJ) then
				validlj = true
			end
		end
		dist = (jpos-p.jumppos):Length2D()
		if(jt != JUMP_LADDER) then
			dist = dist + 32
		end
	end
	
	local dj = p.didjump
	
	if(p.jumpproblem || p.tproblem) then
		validlj = false
	end
	
	timer.Simple(0.3,function()
		if(p && p:IsValid() && p:IsOnGround()) then
			p.inbhop = false
			--print('tried')
			if((jt == JUMP_WJ || dj) && straf && straf != 0 && dist && dist > jumpdist[jt] && jt && validlj && good && bad && totalstats) then --checkzooors
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
	p.speed = nil
	p.lastspeed = nil
	p.jumpproblem = false
	p.ducking = false
	if(!p.didjump) then --if they didnt cheat or anything before hitting the ground
		p.wj = true
		p.inbhop = false
		timer.Simple(0.3,function() 
			if(p && p:IsValid()) then
				p.wj = false
			end
		end)
	end
	p.jumptype = JUMP_LJ
	p.oldp = nil
	p.newp = nil
	p.tproblem = false
	p.didjump = false
end

hook.Add("PlayerSpawn","LJ123",function(p)
	p.inbhop = false
	p.strafe = {}
	p.strafenum = 0
	p.jumppos = nil
	p.strafingleft = false
	p.strafingright = false
	p.speed = nil
	p.lastspeed = nil
	p.jumpproblem = false
	p.ducking = false
	p.jumptype = JUMP_LJ
	p.oldp = nil
	p.newp = nil
	p.didjump = false
	p.tproblem = false
end)