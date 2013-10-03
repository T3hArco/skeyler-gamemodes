---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
--------------------------- 

SS.Ranks = {} 
function SS.AddRank(id, name, color) 
	if SS.Ranks[id] then Error("This is already a rank! (".. tostring(id) ..")\n") return end 

	SS.Ranks[id] = {name=name, color=color} 
end 

SS.AddRank(1000, "Owner", Color(64, 64, 64)) 
SS.AddRank(100, "Admin", Color(255, 72, 72)) 
SS.AddRank(50, "Dev", Color(87, 198, 255)) 
SS.AddRank(5, "VIP", Color(255, 216, 0)) 
SS.AddRank(0, "Regular", Color(255, 255, 255)) 

SS.Profiles = {} 

/* Load the profiles before the player is fully loaded */
function PLAYER_META:ProfilePreLoad() 

end 

/* Setup Profile with PreLoad data */
function PLAYER_META:ProfileLoad() 
	self:SetRank(1000)
	self:SetMoney(18576) 
	-- self:SetLevel(1) 
	self:SetExp(10000) 
	self:ChatPrint("Your profile has been loaded") 
end 

/* Sync Profile with database */
function PLAYER_META:ProfileSave() 
	SS.Profiles[self:SteamID()].money = self.money 
end 

function PLAYER_META:SetMoney(amt) 
	self:SetNetworkedInt("ss_money", amt) 
end 

function PLAYER_META:GetMoney() 
	return self:GetNetworkedInt("ss_money", 0) 
end 

function PLAYER_META:GiveMoney(amt) 
	self:SetMoney(self:GetMoney()+amt) 
end 

function PLAYER_META:GetRank() 
	return self:GetNetworkedInt("ss_rankid", 0)  
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

function PLAYER_META:SetExp(exp, relative) 
  	if relative then exp = exp+self:GetExp() end 
	self:SetNetworkedInt("ss_exp", exp) 
end 

function PLAYER_META:GetExp() 
	return self:GetNetworkedInt("ss_exp", 0) 
end 

function PLAYER_META:GiveExp(exp) 
	self:SetExp(exp, true) 
end 

PLAYER_META.IsAdmin2 = PLAYER_META.IsAdmin
function PLAYER_META:IsAdmin() 
	return self:GetRank() >= 100 
end 

PLAYER_META.IsSuperAdmin2 = PLAYER_META.IsSuperAdmin 
function PLAYER_META:IsSuperAdmin() 
	return self:GetRank() >= 1000 
end 

function PLAYER_META:IsVIP() 
	return self:GetRank() >= 5 
end 

function PLAYER_META:GetMaxHealth() 
	if self:IsVIP() and GAMEMODE.VIPBonusHP then 
		return 200 
	end 
	return 100 
end 