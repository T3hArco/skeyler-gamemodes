ENT.Base = "base_brush"
ENT.Type = "brush"

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Initialize()
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:KeyValue(key, value)
	--self[key] = tonumber(value)
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:StartTouch(entity)
	if (IsValid(entity) and entity.IsPlayer and entity:IsPlayer()) then
		SS.Lobby.Minigame:AddPlayer(entity)
	end
	
	
	--[[if ent:IsPlayer() then
		ent.inminiqueue = true
		ent.queued = ent:IsVIP() and CurTime() - 20 or CurTime()
		umsg.Start("GM.Arcade.Queue",ent)
			umsg.Bool(true)
		umsg.End()
	end]]
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:EndTouch(entity)
	if (IsValid(entity) and entity.IsPlayer and entity:IsPlayer()) then
		SS.Lobby.Minigame:RemovePlayer(entity)
	end
	
	
--[[
	if ent:IsPlayer() then
		ent.inminiqueue = false
		ent.queued = false
		umsg.Start("GM.Arcade.Queue",ent)
			umsg.Bool(false)
		umsg.End()
	end]]
end