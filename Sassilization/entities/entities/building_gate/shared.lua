--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

ENT.Type = "anim"
ENT.Base = "building_base"

if CLIENT then  
	function PlayGateAnim(len)  
		local ent = net.ReadEntity()  
		local string = net.ReadString()  
		if string then  
			local Sequence = ent:LookupSequence(string)  
			ent.Model:ResetSequence( Sequence )
		end  
	end  
	net.Receive("PlayGateAnim", PlayGateAnim)  

	function SendConnectedPieces(len)  
		ent = net.ReadEntity()  
		ent.Connected = net.ReadTable()
	end  
	net.Receive("SendConnectedPieces", SendConnectedPieces) 
	
	ENT.Foundation = false
end  