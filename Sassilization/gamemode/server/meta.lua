----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
--	Models By Jaanus
----------------------------------------

function GM.PlayerMeta:CalcPot()
	
	local pot, allies = self:GetNWInt( "_gold" ), 1
	for _, pl in pairs( alliances[self] ) do
		if pl ~= self and table.HasValue( alliances[pl], self ) then
			pot = pot + pl:GetNWInt("_gold")
			allies = allies + 1
		end
	end
	return math.Round( pot/allies * 0.5 )
	
end

function GM.PlayerMeta:IsPrivileged()
	if self:IsAdmin() or self:IsSuperAdmin() then
		--return true
	end
	if game.SinglePlayer() then
		return true
	end
	for _, id in pairs(PrivilegedPlayers) do
		if string.find( self:SteamID(),id ) then
			return true
		end
	end
	return false
end

function GM.PlayerMeta:Reject()
	MsgN("Player: "..self:GetName().." has tried to illegally join the server")
	self:PrintMessage(2,"Your ticket to join has expired.")
	timer.Simple( 1, function()
		self:ConCommand("connect "..LOBBYIP..":"..LOBBYPORT..";password testingrofl")
	end )
	timer.Simple( 2, function()
		game.ConsoleCommand("kickid "..self:UserID().."\n")
	end )
	return "invalid"
end

function GM.PlayerMeta:ValidateTicket()

	if game.SinglePlayer() then GAMEMODE:StartGame() return true end
	if not TICKETS then return self:Reject() end
	local validated
	for _, ticket in pairs( TICKETS ) do
		if string.find( ticket.ip, string.sub(self:IPAddress(), 0, string.find(self:IPAddress(),":")-1 ) ) and not ticket.used then
			MsgN("Player: "..self:GetName().." has successfully joined, his/her ticket is now used")
			ticket.used = true
			validated = true
			self.valid = true
			break
		end
	end
	if not validated and not self:IsSuperAdmin() and self ~= sass then return self:Reject() end
	for _, ticket in pairs( TICKETS ) do
		if not ticket.used then
			return false
		end
	end
	GAMEMODE:StartGame()
	return true

end
