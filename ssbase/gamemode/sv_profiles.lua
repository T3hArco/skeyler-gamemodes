---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
--------------------------- 

local selects = {"exp", "id", "steamId64", "lastLoginIp", "playtime", "lastLoginTimestamp", "steamId", "rank", "name", "money", "store", "equipped", "avatarUrl"} 
local update_filter = {"id", "steamId", "rank", "avatarUrl"}

SS.Profiles = {} 

-- Check if the player has a valid avatar url stored in the database, if not fetch it.
function PLAYER_META:CheckAvatar() 
	if self.profile and (!self.profile.avatarUrl or string.Trim(self.profile.avatarUrl) == "" or string.sub(self.profile.avatarURL, string.len(self.profile.avatarURL)-9, string.len(self.profile.avatarURL)) == "_full.jpg") then 
		http.Fetch("http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=9D7A9B8269C1C1B1B7B21E659904DDEF&steamids="..self.profile.steamId64,
				function(body) 
					if self and self:IsValid() then 
						body = util.JSONToTable(body) 
						DB_Query("UPDATE users SET avatarUrl='"..body.response.players[1].avatarfull.."' WHERE steamId='"..string.sub(self:SteamID(), 7).."'") 
						self:ChatPrint("AVATAR DEBUG: "..body.response.players[1].avatarfull)
					end 
				end, 
				function(error) 
					Error("[AVATAR FETCH FAILED] ".. error) 
				end
		) 
	end 
end 

function PLAYER_META:CreateProfile() 
	if(self:IsBot()) then return end 
	local ip = string.Replace(game.IsDedicated() and self:IPAddress() or "127.0.0.1", ".", "")  
	local query = "INSERT INTO users (steamid64, steamid, name, registerIp, lastLoginIP, registerTimestamp, lastLoginTimestamp) VALUES ('"..self:SteamID64().."','"..string.sub(self:SteamID(), 7).."','"..DB:escape(self:Name()).."','"..ip.."','"..ip.."','"..tostring(os.time()).."','"..tostring(os.time()).."')"
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
		self:SetStoreItems(self.profile.store)
		self:SetEquipped(self.profile.equipped)
		
		self:NetworkOwnedItem()
		
		if !self:HasMoney(0) then 
			self:SetMoney(0) 
			self:ChatPrint("Oops!  You have negative money, we set that to 0 for you.  Please tell a developer how this happened!")  
		end 
		self:ChatPrint("Your profile has been loaded") 
	elseif res and !res[1] then 
		self:ChatPrint("No profile detected, creating one for you.") 
		self:CreateProfile() 
		return 
	else 
		self.profile = {} 
		self.profile.lastLoginIp = self:IPAddress() 
		self.profile.lastLoginTimestamp = os.time() 
		self:SetRank(DB_DEVS and 100 or 0)
		self:SetMoney(100) 
		self:SetExp(1)
		self:SetStoreItems("")
		self:SetEquipped("")
		self:ChatPrint("We had problems loading your profile and have created a temporary one for you.") 
	end 

	self.profile.playtime = self.profile.playtime or 0 -- Make sure it isn't nil
	self.playtimeStart = os.time()
	self.profile.lastLoginIp = self:IPAddress() 
	self.profile.lastLoginTimestamp = os.time() 

	SS.Profiles[self:SteamID()] = self.profile

	self:CheckAvatar()

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
	
	hook.Run("PlayerSetModel", self)
	
	self:SetNetworkedBool("ss_profileloaded", true) 
end 

/* Sync Profile with database */
function PLAYER_META:ProfileSave() 
	if(self:IsBot()) then return end
	local profile = SS.Profiles[self:SteamID()]
	profile.money = self.money 
	profile.exp = self.exp 
	profile.playtime = profile.playtime+(os.time()-self.playtimeStart)
	profile.store = util.TableToJSON(self.storeItems)
	profile.equipped = util.TableToJSON(self.storeEquipped)
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

--------------------------------------------------
--
--------------------------------------------------

function PLAYER_META:SetStoreItems(data)
	if (!data or data == "" or data == "[]") then
		self.storeItems = {}
	else
		self.storeItems = util.JSONToTable(data)
	end
end

--------------------------------------------------
--
--------------------------------------------------

function PLAYER_META:SetEquipped(data)
	if (!data or data == "" or data == "[]") then
		self.storeEquipped = {}
		
		for i = 1, SS.STORE.SLOT.MAXIMUM do
			self.storeEquipped[i] = {}
		end
	else
		self.storeEquipped = util.JSONToTable(data) 
	end
end