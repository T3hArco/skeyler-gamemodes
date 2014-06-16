---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com -- 
---------------------------- 

local selects = {"exp", "id", "steamId64", "lastLoginIp", "playtime", "lastLoginTimestamp", "steamId", "rank", "name", "money", "avatarUrl", "fakename"} 
local update_filter = {"id", "steamId", "rank", "avatarUrl"}

SS.Profiles = {} 

-- Check if the player has a valid avatar url stored in the database, if not fetch it.
function PLAYER_META:CheckAvatar() 
	if self.profile and (!self.profile.avatarUrl or string.Trim(self.profile.avatarUrl) == "" or string.match(self.profile.avatarUrl, "_full.jpg")) then 
		http.Fetch("http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=9D7A9B8269C1C1B1B7B21E659904DDEF&steamids="..self.profile.steamId64,
				function(body) 
					if self and self:IsValid() then 
						body = util.JSONToTable(body) 
						DB_Query("UPDATE users SET avatarUrl='"..body.response.players[1].avatar.."' WHERE steamId='"..string.sub(self:SteamID(), 7).."'") 
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
	local ip = string.Replace(self:IPAddress() != "loopback" and self:IPAddress() or "127.0.0.1", ".", "")  
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
	local ip = string.Replace(self:IPAddress() != "loopback" and self:IPAddress() or "127.0.0.1", ".", "")
	
	self.storeItems = {}
	self.storeEquipped = {}
	
	for i = 1, SS.STORE.SLOT.MAXIMUM do
		self.storeEquipped[i] = {}
	end
	
	if res and res[1] then 
		if res[2] then Error("Duplicate profile! Contact a developer! ("..steamid..")") return end 
		self.profile = res[1] 

		MsgN("[PROFILE] Loaded ", self) 
		
		self:SetRank(self.profile.rank) 
		self:SetMoney(self.profile.money) 
		self:SetExp(self.profile.exp)
		
		-- Find all the owned items in the database.
		DB_Query("SELECT * FROM users_items WHERE steamID = " .. sql.SQLStr(steamid), function(data)
			if (data) then
				for i = 1, #data do
					local item = data[i]
					local color = color_white
					
					if (item.color) then
						color = string.gsub(item.color, "#", "")
						color = Vector(tonumber("0x" .. string.sub(color, 1, 2)), tonumber("0x" .. string.sub(color, 3, 4)), tonumber("0x" .. string.sub(color, 5, 6)))
					end
					
					self.storeItems[item.item] = {
						__id = item.id,
						
						[SS.STORE.CUSTOM.SKIN] = item.skin != NULL and item.skin or 0,
						[SS.STORE.CUSTOM.COLOR] = color,
						[SS.STORE.CUSTOM.BODYGROUP] = item.bodygroup != NULL and util.JSONToTable(item.bodygroup) or {}
					}
				end
			end
			
			-- Let the player know what they own.
			self:NetworkOwnedItem()
		end)
		
		-- Find all the equipped items in the database.
		DB_Query("SELECT * FROM users_equipped WHERE steamID = " .. sql.SQLStr(steamid), function(data)
			if (data) then
				for i = 1, #data do
					local info = data[i]

					if (info.item) then
						local item = SS.STORE.Items[info.item]
						
						if (item) then
							self.storeEquipped[item.Slot] = {unique = item.ID, __id = info.id}
						else
							ErrorNoHalt("[STORE] Failed to load equipped item '" .. info.item .. "' (does not exist?) (" .. tostring(self:SteamID()) .. ")\n")
						end
					end
				end
			end
		end)
		
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
		self.profile.lastLoginIp = ip 
		self.profile.lastLoginTimestamp = os.time() 
		self:SetRank(DB_DEVS and 100 or 0)
		self:SetMoney(100) 
		self:SetExp(1)
		
		self:ChatPrint("We had problems loading your profile and have created a temporary one for you.") 
	end 

	self.profile.playtime = self.profile.playtime or 0 -- Make sure it isn't nil
	self.playtimeStart = os.time()
	self.profile.lastLoginIp = ip 
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

-- Sync Profile with database.
function PLAYER_META:ProfileSave() 
	if(self:IsBot()) then return end
	
	local steamID = self:SteamID()
	
	local profile = SS.Profiles[steamID]
	profile.money = self.money 
	profile.exp = self.exp 
	profile.playtime = profile.playtime+(os.time()-self.playtimeStart)
	profile.fakename = util.TableToJSON(self.fakename)
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
	
	Query = Query.." WHERE steamid='"..string.sub(steamID, 7).."';"
	
	DB_Query(Query)
	
	local query = "UPDATE `users_items` SET"
	local where = ""
	
	for unique, data in pairs(self.storeItems) do
		local skin = data[SS.STORE.CUSTOM.SKIN] or 0
		local color = data[SS.STORE.CUSTOM.COLOR] or color_white
		local bodygroup = sql.SQLStr(util.TableToJSON(data[SS.STORE.CUSTOM.BODYGROUP] or {}))
		
		query = query .. " `color` = CASE WHEN `id` = '" .. data.__id .. "' THEN " .. sql.SQLStr(string.format("#%02X%02X%02X", color.r, color.g, color.b)) .. " ELSE `color` END,"
		query = query .. " `skin` = CASE WHEN `id` = '" .. data.__id .. "' THEN " .. skin .. " ELSE `skin` END,"
		query = query .. " `bodygroup` = CASE WHEN `id` = '" .. data.__id .. "' THEN " .. bodygroup .. " ELSE `bodygroup` END,"
		
		where = where .. data.__id .. ", "
	end
	
	query, where = string.sub(query, 0, string.len(query) -1), string.sub(where, 0, string.len(where) -2)
	query = query .. " WHERE id IN (" .. where .. ") AND steamID = " .. sql.SQLStr(steamID)
	
	DB_Query(query)
end 

function PLAYER_META:ProfileUpdate(col, val) -- Don't be an idiot with this
	if(self:IsBot()) then return end
	if !SERVER then return end 
	DB_Query("UPDATE users SET "..tostring(col).."='"..tostring(val).."' WHERE steamid='"..string.sub(self:SteamID(), 7).."'" ) 
end

function PLAYER_META:GetProfileData(field)
	return self.profile[field]
end