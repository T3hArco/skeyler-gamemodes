SS.Lobby.WorldPicker = {}

---------------------------------------------------------
--
---------------------------------------------------------

util.AddNetworkString("sslb.wpstps")

net.Receive("sslb.wpstps", function(bits, player)
	if (player:IsAdmin()) then
		local entity = net.ReadEntity()
		local position = net.ReadVector()
		local angles = net.ReadAngle()
		
		if (IsValid(entity)) then
			entity:SetPos(position)
			entity:SetAngles(angles)
		end
	end
end)