---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
--------------------------- 

SS.Ranks = {} 
function SS.AddRank(id, name, color) 
	if SS.Ranks[id] then Error("This is already a rank! (".. tostring(id) ..")\n") return end 

	SS.Ranks[id] = {name=name, color=color} 
end 

SS.AddRank(100, "Owner", Color(56, 56, 56)) 
SS.AddRank(90, "SuperAdmin", Color(186, 131, 255)) 
SS.AddRank(70, "Developer", Color(122, 215, 255)) 
SS.AddRank(50, "Admin", Color(255, 98, 98)) 
SS.AddRank(10, "Mod", Color(189, 240, 79)) 
SS.AddRank(5, "VIP", Color(255, 231, 98)) 
SS.AddRank(0, "Regular", Color(94, 94, 94)) 

function PLAYER_META:IsProfileLoaded() 
	return self:GetNetworkedBool("ss_profileloaded", false) 
end 

function PLAYER_META:SetMoney(amt) 
	self:SetNetworkedInt("ss_money", amt) 
	self:ProfileUpdate("money", amt) 
end 

function PLAYER_META:GetMoney() 
	return self:GetNetworkedInt("ss_money", 0) 
end 

function PLAYER_META:GiveMoney(amt) 
	self:SetMoney(self:GetMoney()+amt) 
end 

function PLAYER_META:TakeMoney(amt) 
	self:GiveMoney(-amt) 
end 

function PLAYER_META:HasMoney(amt) 
	return self:GetMoney() >= amt 
end 

function PLAYER_META:GetRank() 
	return SS.Ranks[self:GetNetworkedInt("ss_rankid", 0)] and self:GetNetworkedInt("ss_rankid", 0) or 0
end 

function PLAYER_META:SetRank(id) 
	self:SetNetworkedInt("ss_rankid", id) 
end 

function PLAYER_META:GetRankName() 
	return SS.Ranks[self:GetRank()].name 
end 

function PLAYER_META:GetRankColor() 
	return SS.Ranks[self:GetRank()].color 
end 

function PLAYER_META:SetLevel(lvl) 
	self:SetNetworkedInt("ss_level", lvl) 
end 

function PLAYER_META:GetLevel() 
	return self:GetNetworkedInt("ss_exp", 0) 
end 

function PLAYER_META:GetNextLevel() 
	return (0*2*(self:GetLevel()+1)) 
end 

function PLAYER_META:SetExp(exp) 
	self:SetNetworkedInt("ss_exp", exp) 
	self:ProfileUpdate("exp", exp) 
end 

function PLAYER_META:GetExp() 
	return self:GetNetworkedInt("ss_exp", 0) 
end 

function PLAYER_META:GiveExp(exp) 
	self:SetExp(self:GetExp()+exp) 
end 

PLAYER_META.IsAdmin2 = PLAYER_META.IsAdmin
function PLAYER_META:IsAdmin() 
	if !self:IsValid() then return true end 
	return self:GetRank() >= 50 
end 

PLAYER_META.IsSuperAdmin2 = PLAYER_META.IsSuperAdmin 
function PLAYER_META:IsSuperAdmin() 
	if !self:IsValid() then return true end 
	return self:GetRank() >= 90 
end 

function PLAYER_META:IsMod()
	if !self:IsValid() then return true end
	return self:GetRank() >= 10
end

function PLAYER_META:IsVIP() 
	if !self:IsValid() then return true end 
	return self:GetRank() >= 5 
end 

function PLAYER_META:GetMaxHealth() 
	if self:IsVIP() and GAMEMODE.VIPBonusHP then 
		return 200 
	end 
	return 100 
end 