util.AddNetworkString("182kasdl321")
util.AddNetworkString("GAS2M")

local pm = FindMetaTable("Player")

function pm:G2M(n,s,t)
	net.Start("GAS2M")
	net.WriteString(tostring(n))
	net.WriteString(tostring(s))
	net.WriteString(tostring(t))
	net.Send(self)
end

function pm:G2C(n)
	net.Start("GAS2C")
	net.WriteString(tostring(n))
	net.Send(self)
end

local cache = false --im caching if it should always return

net.Receive("182kasdl321",function(l,ply)
	if cache then return end
	if(table.HasValue(SS.AutoMaps,game.GetMap())) then 
		cache = true
		return
	end
	local text = net.ReadString()
	for k,v in pairs(player.GetAll()) do
		if v:IsAdmin() then
			v:G2M(ply:Nick(),ply:SteamID(),text)
		end
	end
end)