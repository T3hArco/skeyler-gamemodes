------------------------------------------------
--	Network messages
------------------------------------------------

local function lobby_ReceiveUnsit(byte)
	local player = LocalPlayer()
	
	if (player.sitting) then
		player.sitting = nil

		gamemode.Call("PlayerUnSit", player)
	end
end

net.Receive("chairs_unsit", lobby_ReceiveUnsit)

local function lobby_ReceiveSit(byte)
	local sitView = net.ReadVector()
	local player = LocalPlayer()
	
	player.sitting = true

	gamemode.Call("PlayerSitDown", player)
end

net.Receive("chairs_sitdown", lobby_ReceiveSit)

------------------------------------------------
-- FUNCTIONS
------------------------------------------------

function GM:PlayerUnSit(pl) end
function GM:PlayerSitDown(pl) end

------------------------------------------------
-- HOOKS
------------------------------------------------

hook.Add("KeyPress", "SS.Lobby.Chair", function(player, key)
	if (key == IN_USE) then
		local trace = util.QuickTrace(player:EyePos(), player:GetAimVector() *200, MASK_SOLID)

		if (IsValid(trace.Entity) and (trace.Entity:IsChair() or trace.Entity:IsVehicle())) then
			net.Start("lobby_sitchair")
				net.WriteUInt(trace.Entity:EntIndex(), 32)
			net.SendToServer()
		end
	end
end)