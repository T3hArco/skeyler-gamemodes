------------------------------------------------
--	Network messages
------------------------------------------------

local function lobby_ReceiveUnsit(byte)
	local player = LocalPlayer()
	
	if (player.sitting) then
		player.sitting = nil
		player.sitView = nil
		
		player:SetNoDraw(false)
		
		gamemode.Call("PlayerUnSit", player)
	end
end

net.Receive("chairs_unsit", lobby_ReceiveUnsit)

local function lobby_ReceiveSit(byte)
	local sitView = net.ReadVector()
	local player = LocalPlayer()
	
	player.sitting = true
	player.sitView = sitView != Vector() and sitView or nil
	player:SetNoDraw(true)
	
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

local chairView = {}

hook.Add("CalcView", "SS.Lobby.Chair", function(player, position, angles, fov, nearz, farz)
	if (player:IsSitting()) then
		chairView.origin = player:GetPos() +player:GetUp() *50
		chairView.angles = (player.sitView and vgui.CursorVisible() and (player.sitView -player:EyePos()):Angle()) or angles
		chairView.fov = fov
		chairView.nearz = nearz
		chairView.farz = farz
		
		return chairView
	end
end)

function GM:HandlePlayerDriving(pl)
	if pl:InVehicle() and pl:IsSitting() then
		local org = pl:GetVehicle():GetRight()
		local aim = pl:GetAimVector()
		local v1 = Vector( org.x, org.y, 0 ):GetNormal()
		local v2 = Vector( aim.x, aim.y, 0 ):GetNormal()
		local yaw = angleBetween( v1, v2 ) - 1.6
		
		local org = pl:GetVehicle():GetUp()
		v1 = Vector( org.y, org.z, 0 ):GetNormal()
		v2 = Vector( aim.y, aim.z, 0 ):GetNormal()
		local pitch = angleBetween( v1, v2 ) - 1.6
		
		yaw = math.Clamp( yaw*66, -66, 66 )
		pitch = math.Clamp( pitch*22.6, -34, 25 )
		
		pl:SetPoseParameter( "head_yaw", yaw )
		pl:SetPoseParameter( "head_pitch", pitch )
	end
end