---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
--------------------------- 

local selects = {"exp", "id", "steamId64", "lastLoginIp", "playtime", "lastLoginTimestamp", "steamId", "rank", "name", "money"} 
local update_filter = {"id", "steamId", "rank"}

SS.Profiles = {} 

function PLAYER_META:CreateProfile() 
	if(self:IsBot()) then return end
	local query = "INSERT INTO users (steamid64, steamid, name, registerIp, registerTimestamp) VALUES ('"..self:SteamID64().."','"..string.sub(self:SteamID(), 7).."','"..DB:escape(self:Name()).."','"..self:IPAddress().."','"..tostring(os.time()).."')"
	DB_Query(query, function() if self and self:IsValid() then self:ProfileLoad() end end)
end 

function PLAYER_META:ProfileLoad() 
	if(self:IsBot()) then return end
	MsgN("[PROFILE] Loading ", self) 
	local steamid = self:SteamID() 
	SS.Profiles[steamid] = {}

	self:ChatPrint("Loading your profile") 

	if DB_DEVS then self:ProfileLoaded() return end 

	timer.Simple(30, function() if self and self:IsValid() and !self:IsProfileLoaded() then self:ChatPrint("Your profile seems to be having problems loading.  Our appologies.") end end) 

	DB_Query("SELECT "..table.concat(selects, ", ").." FROM users WHERE steamid='"..string.sub(steamid, 7).."'", 
		function(data) if self and self:IsValid() then self:ProfileLoaded(data) end end, 
		function() 
			if self and self:IsValid() then 
				self.ProfileFailed = true 
				self:ChatPrint("We failed to load your profile, trying again in 60 seconds.") 
				timer.Simple(60, function() 
					if self and self:IsValid() then 
						self:ProfileLoad() 
					end 
				end ) 
			end 
		end)
end 

function PLAYER_META:ProfileLoaded(res) 
	local steamid = self:SteamID()
	if res and res[1] then 
		if res[2] then Error("Duplicate profile! Contact a developer! ("..steam..")") return end 
		self.profile = res[1] 

		MsgN("[PROFILE] Loaded ", self) 

		self:SetRank(self.profile.rank) 
		self:SetMoney(self.profile.money) 
		self:SetExp(self.profile.exp) 
		self.profile.lastLoginIp = self:IPAddress() 
		self.profile.lastLoginTimestamp = os.time() 
		self.playtimeStart = os.time() 
		SS.Profiles[self:SteamID()] = self.profile
		self:ChatPrint("Your profile has been loaded") 
	elseif res and !res[1] then 
		self:ChatPrint("No profile detected, creating one for you.") 
		self:CreateProfile() 
		return 
	else 
		self.profile = {} 
		self.profile.lastLoginIp = self:IPAddress() 
		self.profile.lastLoginTimestamp = os.time() 
		self.playtimeStart = os.time() 
		self.profile.playtime = 0
		self:SetRank(DB_DEVS and 100 or 0)
		self:SetMoney(100) 
		self:SetExp(1) 
		self:ChatPrint("We had problems loading your profile and have created a temporary one for you.") 
	end 
	timer.Create(self:SteamID().."_ProfileUpdate", 120, 0, function() 
		if self and self:IsValid() then 
			self.profile.lastLoginTimestamp = os.time() 
			self.profile.playtime = self.profile.playtime+(os.time()-self.playtimeStart) 
			self.playtimeStart = os.time()  
			self:ProfileSave() 
		else 
			timer.Destroy(steamid.."_ProfileUpdate") 
		end 
	end )
	self:SetNetworkedBool("ss_profileloaded", true) 
end 

/* Sync Profile with database */
function PLAYER_META:ProfileSave() 
	if(self:IsBot()) then return end
	local profile = SS.Profiles[self:SteamID()]
	profile.money = self.money 
	profile.exp = self.exp 
	profile.playtime = profile.playtime+(os.time()-self.playtimeStart) 
	self.playtimeStart = os.time() 

	local Query = "UPDATE users SET " 
	local first = true 
	for k,v in pairs(profile) do 
		if table.HasValue(update_filter, k) then continue end -- We don't want to automatically update these.
		if first then 
			Query = Query..k.."='"..v.."'" 
			first = false 
		else 
			Query = Query..", "..k.."='"..v.."'" 
		end 
	end 
	Query = Query.." WHERE steamid='"..string.sub(self:SteamID(), 7).."'"
	DB_Query(Query) 
end 

function PLAYER_META:ProfileUpdate(col, val) -- Don't be an idiot with this
	if(self:IsBot()) then return end
	if !SERVER then return end 
	DB_Query("UPDATE users SET "..tostring(col).."='"..tostring(val).."' WHERE steamid='"..string.sub(self:SteamID(), 7).."'" ) 
end 

