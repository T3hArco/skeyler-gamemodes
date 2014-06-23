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
			DB_Query("UPDATE lobby_news SET news='".. text .."'")
			LOBBY_NEWS = text
		else
			DB_Query("UPDATE lobby_news SET rules='".. text .."'")
			LOBBY_RULES = text
		end

		for k,v in pairs(player.GetAll()) do
			net.Start("setNewsRules")
				net.WriteString(LOBBY_NEWS)
				net.WriteString(LOBBY_RULES)
			net.Send(v)
		end
	end
end)