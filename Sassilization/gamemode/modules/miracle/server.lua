util.AddNetworkString("sa_lowcreed")
util.AddNetworkString("sa_domiracle")
util.AddNetworkString("sa.GetMiracleCooldown")

miracles = {}

local stored = {}

--------------------------------------------
-- miracles.Get(unique)
--
-- Returns the given miracle.
--------------------------------------------

function miracles.Get(unique)
	return stored[unique]
end

--------------------------------------------
-- miracles.GetList()
--
-- Returns all miracles.
--------------------------------------------

function miracles.GetList()
	return stored
end

--------------------------------------------
-- miracles.Start(unique, player)
--
-- Player casts a miracle.
--------------------------------------------

local GetPlayers = player.GetAll

local function SphereIntersect(center, radius, position, direction)
	position = position +direction *-radius
	
	direction:Normalize()
	
	local a = center -position
	local b = a:Length()
	
	if (b < radius) then
		direction = direction *-1
	end
	
	local c = direction:DotProduct(a:GetNormal()) *b
	local d = radius ^2 -(b ^2 -c ^2)
	
	if (d < 0) then return end
	
	return position +direction *(c -math.sqrt(d))
end

function miracles.Start(unique, player)
	local data = miracles.Get(unique)
	
	if (data) then
		local level = 0
		
		--[[
		local level = ALLOWALL and true or pl.ITEMS[string.lower(SPELLS[key].name)]
		if not (level == true or (tonumber(level) and level > 0)) then
			pl:ChatPrint( "You cannot cast this miracle until you've acquired it." )
			pl:SendLua("playsound( 'sassilization/warnmessage.wav', -1 )")
			return
		end
		]]
	
		local empire = player:GetEmpire()
		local creedCost = data.cost
		
		if (empire:GetCreed() >= creedCost) then
			if (player.miracles[unique].delay <= CurTime()) then
				local position = player:GetShootPos()
				local angle = player:GetAimVector()
				
				local trace = {}
				trace.start = position
				trace.endpos = position +angle *2048
				trace.mask = MASK_SOLID
				trace.filter = GetPlayers()
				
				trace = util.TraceLine(trace)
				
				local hitPos = trace.HitPos
				local filter = player
				
				if (IsValid(trace.Entity)) then
					filter = trace.Entity
					hitPos = trace.Entity:GetPos()
				end
				
				local shrines = {}
				local shrineEntities = ents.FindByClass("building_shrine")
				
				for k, entity in pairs(shrineEntities) do
					if (IsValid(entity) and entity:GetEmpire() == empire and entity:GetPos():Distance(hitPos) <= 650 and entity:IsBuilt() and entity:IsReady()) then
						table.insert(shrines, entity)
					end
				end
				
				if (#shrines > 0) then
					local Shrine, Shield, ShieldShrine, ShieldPos
					
					for k, shrine in pairs(shrines) do
						Shrine = shrine
						
						local start_pos = shrine:GetPos() +Vector(0, 0, 8)
						local end_pos = hitPos
						local cur_pos = start_pos
						local direction = end_pos -start_pos 
						local steps = math.Round(start_pos:Distance(end_pos) *0.1)
						local increment = direction:Length() /steps
						
						direction:Normalize()
						
						for i = 1, steps do
							local arch = math.sin(math.rad(i *180 /steps)) *(steps *2)
							
							local trace = {}
							trace.start = cur_pos
							trace.endpos = start_pos +direction *(i *increment) +Vector(0, 0, arch)
							trace.mask = MASK_SOLID_BRUSHONLY
							
							trace = util.TraceLine(trace)
							
							if (trace.HitWorld and i != steps) then
								Shrine = false
								
								break
							else
								local shield, blockpos, distance
								local entities = ents.FindInSphere(trace.HitPos, 48)
								
								for k, entity in pairs(entities) do
									if (entity:GetClass() == "building_shieldmono" and entity:IsBuilt() and entity:CanProtect() and entity:GetEmpire() != empire and !Allied(empire, entity:GetEmpire())) then
										local center = entity:GetPos() +Vector(0, 0, entity:OBBMaxs().z)
										local hitPos = SphereIntersect(center, 32, trace.HitPos, trace.Normal *-1) --center:Distance( tr.HitPos ) < 32 and center + (tr.HitPos - center):Normalize() * 32 or false
										
										if (hitPos and (!distance or start_pos:Distance(hitPos) < distance)) then
											distance = center:Distance(hitPos)
											shield = entity
											blockpos = hitPos
										end
									end
								end
								
								if (IsValid(shield)) then
									Shrine = false
									shieldShrine = shrine
									ShieldPos = blockpos
									Shield = shield
									
									break
								end
							end
							
							cur_pos = trace.HitPos
						end
						
						if (Shrine) then
							Shield = false
							
							break
						end
					end

					if (Shield) then
						player:EmitSound(data.sound)
						
						empire:SetCreed(empire:GetCreed() -creedCost)

						player.miracles[unique].delay = CurTime() +data.delay
						
						net.Start("sa.GetMiracleCooldown")
							net.WriteString(unique)
							net.WriteUInt(data.delay, 8)
						net.Send(player)
						
						local effect = EffectData()
							effect:SetStart(shieldShrine:GetPos())
							effect:SetEntity(shieldShrine)
							effect:SetAttachment(1)
							effect:SetOrigin(ShieldPos)
							effect:SetScale(6)
						util.Effect("caststrike", effect)
						
						Shield:Protect(ShieldPos)
					else
						if (!Shrine) then
							player:ChatPrint("None of your shrines can reach there.")
							
							net.Start("sa_lowcreed")
							net.Send(player)
						else
							if (unique == "blast" or unique == "plummet") then
								level = 1
							else
								level = 3
							end
						
							if (Shrine and level and hitPos) then
								player:EmitSound(data.sound)
								
								empire:SetCreed(empire:GetCreed() -creedCost)
							
								--level = level == true and 3 or level
								
								local effect = EffectData()
									effect:SetStart(Shrine:GetPos())
									effect:SetEntity(Shrine)
									effect:SetAttachment(1)
									effect:SetOrigin(hitPos)
									effect:SetScale(4 +4 *level /3)
								util.Effect("caststrike", effect)

								data:Execute(player, empire, hitPos, Shrine, level)
								
								player.miracles[unique].delay = CurTime() +data.delay
								
								net.Start("sa.GetMiracleCooldown")
									net.WriteString(unique)
									net.WriteUInt(data.delay, 8)
								net.Send(player)
						
								Msg(player:Nick() .. " casted mircale '" .. unique .. "'\n")
							end
						end
					end
				else
					player:ChatPrint("This is too far from your shrine(s).")
					
					net.Start("sa_lowcreed")
					net.Send(player)
				end
			else
				player:ChatPrint("You can cast this miracle in " .. tostring(math.Round(player.miracles[unique].delay -CurTime())) .. " seconds.")
			
				net.Start("sa_lowcreed")
				net.Send(player)
			end
		else
			player:ChatPrint("You have insufficient creed.")
			
			net.Start("sa_lowcreed")
			net.Send(player)
		end
	end
end

--------------------------------------------
-- miracles.Setup(player)
--
-- Setup the delays for each miracle on the player.
--------------------------------------------

function miracles.Setup(player)
	local stored = miracles.GetList()
	
	player.miracles = {}
	
	for k, v in pairs(stored) do
		player.miracles[k] = {delay = 0}
	end
end

--------------------------------------------
-- "sa_domiracle"
--
-- A player casts a mircale.
--------------------------------------------

net.Receive("sa_domiracle", function(bits, player)
	local unique = net.ReadString()
	
	miracles.Start(unique, player)
end)

--------------------------------------------
-- Load all the miracles.
--------------------------------------------

local files = file.Find(GM.FolderName .. "/gamemode/modules/miracle/miracles/*", "LUA")

Msg("\t# Loading miracles\n")

for k, luaFile in pairs(files) do
	miracle = {}
	
	include("miracles/" .. luaFile)
	
	stored[miracle.unique] = miracle
	
	Msg("\t\tLoaded miracle: " .. miracle.unique .. "\n")
	
	miracle = nil
end

Msg("\t# Loaded miracles\n")