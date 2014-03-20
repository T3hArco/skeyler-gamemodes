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