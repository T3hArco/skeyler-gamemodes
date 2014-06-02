AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

---------------------------------------------------------
--
---------------------------------------------------------

util.AddNetworkString( "rulesNewsEdit" )
util.AddNetworkString( "setNewsRules" )
util.AddNetworkString( "updateNews" )

function ENT:Initialize()
	if !file.Exists( "SSLobby/news.txt", "DATA" ) then
		file.CreateDir( "SSLobby" )
		file.Write( "SSLobby/news.txt", "News" )
		file.Write( "SSLobby/rules.txt", "Rules" )
	end

	self.width = 64
	self.height = 64

	self:EnableCustomCollisions( true )

	self:PhysicsInit(SOLID_BBOX)
	self:SetSolid(SOLID_BBOX)
	self:PhysicsInitBox(self:GetForward()*5.1 - self:GetRight()*(self.width/2) + self:GetUp()*(self.height/2), -self:GetForward()*5.1 + self:GetRight()*(self.width/2) - self:GetUp()*(self.height/2))
	self:SetCollisionBounds(self:GetForward()*5.1 - self:GetRight()*(self.width/2) + self:GetUp()*(self.height/2), -self:GetForward()*5.1 + self:GetRight()*(self.width/2) - self:GetUp()*(self.height/2))
	self:SetCollisionGroup(11)

	self:SetMoveType(MOVETYPE_NONE)
	self:DrawShadow(false)
	self:SetNotSolid(false)
end

function ENT:Use( ply, cal )
	if ply:IsAdmin() then
		net.Start("rulesNewsEdit")
		net.Send(ply)
	end
end

net.Receive("updateNews", function(len, ply)
	if ply:IsAdmin() then
		local updateType = net.ReadString()
		local text = net.ReadString()
		if updateType == "news" then
			file.Write( "SSLobby/news.txt", text )
		else
			file.Write( "SSLobby/rules.txt", text )
		end

		for k,v in pairs(player.GetAll()) do
			net.Start("setNewsRules")
				net.WriteString(file.Read( "SSLobby/news.txt", "DATA" ))
				net.WriteString(file.Read( "SSLobby/rules.txt", "DATA" ))
			net.Send(v)
		end
	end
end)