function FindByPartial(PlayerName)
	local t = string.lower(PlayerName)
	local found = 0
	local name

	for k, v in pairs(player.GetAll()) do
		if (string.len(v:Nick()) >= string.len(t)) then
			if string.find(string.lower(v:Nick()), t) then
				found = found + 1
				name = v
			end
		end
	end

	if (found == 0) then
		return "Player not found."
	elseif (found > 1) then
		return "Too many people's name contain that pattern."
	else
		return name
	end
end

function ArgConcat(args)
	local reason
	local b = false

	for k, v in pairs(args) do
		if (k >= 2 and type(args[k]) != "number") then
			if !b then
				reason = args[k]
				b = true
			else
				reason = reason.." "..args[k]
			end
		end
	end

	return reason
end

function PLAYER_META:IsFakenamed()
	return self:GetNWBool("ss_bfakename")
end

function PLAYER_META:GetFakename()
	return self:GetNWString("ss_fakename")
end

function PLAYER_META:GetFakeRank()
	return self:GetNWInt("ss_fakerank")
end

function PLAYER_META:GetFakeRankName() 
	return SS.Ranks[self:GetFakeRank()].name 
end 

function PLAYER_META:GetFakeRankColor() 
	return SS.Ranks[self:GetFakeRank()].color 
end

function PLAYER_META:Nick()
	if self:IsFakenamed() then
		return self:GetFakename()
	else
		return self:Name()
	end
end

SS.Fakenamers = {}
function PLAYER_META:CheckFake() -- Can improve these but I'll just leave it for now.
	if SS.Fakenamers[self:SteamID()] and SS.Fakenamers[self:SteamID()].b then
		local t = SS.Fakenamers[self:SteamID()]
		self:SetFake(t.name, t.id)
	end
end

function PLAYER_META:SetFake(name, id)
	if (self:IsFakenamed() and (name == nil or name == self:Name())) then
		self:SetNWInt("ss_fakerank", -1)
		self:SetNWString("ss_fakename", nil)
		self:SetNWBool("ss_bfakename", false)
		self:ChatPrint("[FAKENAME]: You are now back to normal.\n")

		SS.Fakenamers[self:SteamID()] = {name = nil, id = -1, b = false}
	elseif name and id then
		self:SetNWInt("ss_fakerank", id)
		self:SetNWString("ss_fakename", name)
		self:SetNWBool("ss_bfakename", true)
		self:ChatPrint("[FAKENAME]: "..self:Name().." is now "..self:GetFakename()..". Fakerank: "..self:GetFakeRankName()..".\n")

		SS.Fakenamers[self:SteamID()] = {name = name, id = id, b = true}
	end
end

SS.Muted = {}
function PLAYER_META:IsSSMuted()
	return SS.Muted[self:SteamID()]
end

function PLAYER_META:SetSSMuted(b)
	SS.Muted[self:SteamID()] = b
end