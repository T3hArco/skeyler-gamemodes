----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------


--This code is old and now useless //Hateful
/*
local require = require
local AccessorFunc = AccessorFunc
local table = table
local setmetatable = setmetatable
local umsg = umsg
local net = net
local next = next
local pairs = pairs
local util = util
local _G = _G

module( "alliance" )

if( not _G.sh_alliance ) then return end

for k, v in pairs( _G.sh_alliance ) do
	if not _M[k] then
		_M[k] = v
	end
end

_G.sh_alliance = nil
_G = nil

AccessorFunc( methods, "m_tRequests", "Requests" )
AccessorFunc( methods, "m_tMembers", "Members" )
AccessorFunc( methods, "m_empLeader", "Leader" )
AccessorFunc( methods, "m_bSynced", "Synced" )
AccessorFunc( methods, "m_iSize", "Size" )

function Create()
	
	local alliance = {}
	setmetatable( alliance, mt )
	
	alliance:SetSize( 0 )
	
	alliance.m_iID = table.insert( self.ALLIANCES, alliance )
	alliance:SetMembers( {} )
	alliance:SetRequests( {} )
	
	self.ALLIANCES[ alliance.m_iID ] = alliance
	
	return alliance
	
end

function Sync( alliance )
	
	if( not alliance ) then return end
	
	-- UByte
	net.WriteUInt( alliance:AllianceID(), 8 )
	-- UByte
	net.WriteUInt( alliance:GetSize(), 8 )
	--TODO: FINISH THIS
	
end

util.AddNetworkString( "alliance.Create" )
function Form( empire1, empire2 )
	
	if( empire2 ) then
		
		local a1 = empire1:GetAlliance()
		local a2 = empire2:GetAlliance()
		
		if( a1 and a2 ) then
			
			a1:Merge( a2 )
			
		elseif( a1 ) then
			
			a1:Add( empire2 )
			
		elseif( a2 ) then
			
			a2:Add( empire1 )
			
		end
		
	end
	
	local alliance = Create()
	alliance:SetLeader( empire1 )
	alliance:Add( empire2 )
	
	net.Start( "alliance.Create" )
		
		alliance:Sync()
		
	net.Broadcast()
	
end

function methods:SetLeader( empire )
	
	local members = self:GetMembers()
	if( not members[ empire ] ) then
		
		self:Add( empire, true )
		
	end
	
	self.m_empLeader = empire
	
end

function methods:Add( empire, bLeader )
	
	if( not empire ) then return end
	
	local members = self:GetMembers()
	if( members[ empire ] ) then return end
	
	members[ empire ] = empire
	empire:SetAlliance( self )
	self:SetSize( self:GetSize() + 1 )
	
	if( not self:GetSynced() ) then return end
	--TODO: Network this with a usermessage
	
end

util.AddNetworkString( "alliance.Merge" )
function methods:Merge( alliance1, alliance2 )
	
	if( not (alliance1 and alliance2) ) then return end
	
	local alliance = Create()
	alliance:SetLeader( alliance1:GetLeader() )
	
	for _, member in pairs( alliance1:GetMembers() ) do
		
		alliance:Add( member )
		
	end
	
	for _, member in pairs( alliance2:GetMembers() ) do
		
		alliance:Add( member )
		
	end
	
	net.Start( "alliance.Merge" )
		
		-- UBytes
		net.WriteUInt( alliance1:AllianceID(), 8 )
		net.WriteUInt( alliance2:AllianceID(), 8 )
		Sync( alliance )
		
	net.Broadcast()
	
	alliance1:SetSynced( false )
	alliance1:Remove()
	alliance2:SetSynced( false )
	alliance2:Remove()
	alliance:SetSynced( true )
	
end

util.AddNetworkString( "alliance.Resign" )
function methods:Resign( empire )
	
	local members = self:GetMembers()
	if( not members[ empire ] ) then return end
	
	if( empire:GetAlliance() == self ) then
		empire:SetAlliance( nil )
	end
	members[ empire ] = nil
	
	if( self:GetLeader() == empire ) then
		
		--Assign a new leader
		self:SetLeader( next( members ) )
		
	end
	
	self:SetSize( self:GetSize() - 1 )
	
	if( self:GetSize() == 1 ) then
		
		--The alliance has broken
		self:Remove()
		
	end
	
	if( self:GetSynced() ) then
		
		net.Start( "alliance.Resign" )
			
			-- Shorts
			net.WriteUInt( self:AllianceID(), 8 )
			net.WriteUInt( empire:GetID(), 8 )
			
		net.Broadcast()
		
	end
	
end

function methods:Remove()
	
	for _, member in pairs( self:GetMembers() ) do
		
		self:Resign( member )
		
	end
	
	self.ALLIANCES[ self:AllianceID() ] = nil
	
	--TODO: NET
	-- net.Start()
	-- net.Broadcast()
	
end
*/


util.AddNetworkString( "SetAllianceRequest" )
util.AddNetworkString( "SetAlliance" )
util.AddNetworkString( "SetPublicAlliance" )

local allianceCount = 0

concommand.Add("sa_requestalliance", function( ply,command,args )
	if !SA.ALLIANCES then return end
	
	for _,v in pairs(player.GetAll()) do
		if tonumber(args[1]) == tonumber(v:UserID()) then -- Find the player selected in the tab menu
			if v == ply then return end

			for i,d in pairs(ply.Alliance) do -- Check to see if the target is allied with the current sender
				if d == v then
					ply.breakAlliance = true
				end
			end
			if !ply.breakAlliance then
				for i,d in pairs(ply.incRequests) do -- Check to see if the target has sent a request to the current sender
					if d == v then
						ply.acceptRequest = true
						table.remove(ply.incRequests, i)
					end
				end
				if !ply.acceptRequest then
					for i,d in pairs(v.incRequests) do -- Check to see if the sender has an outgoing request to the target
						if d == ply then
							ply.removeRequest = true
							table.remove(v.incRequests, i)
						end
					end
				end
			end

			if ply.acceptRequest then

				if #player.GetAll() < 6 then
					if #ply.Alliance + 1 > #player.GetAll()/2 - 1 then
						for i,d in pairs(ply.Alliance) do
							breakAlly(ply, d)
						end
						table.Empty(ply.Alliance) 
					end

					if #v.Alliance + 1 > #player.GetAll()/2 - 1 then
						for i,d in pairs(v.Alliance) do
							breakAlly(v, d)
						end
						table.Empty(v.Alliance) 
					end
				end

				if #ply.Alliance == 2 then
					for i,d in pairs(ply.Alliance) do
						breakAlly(ply, d)
					end
					table.Empty(ply.Alliance)
				elseif #ply.Alliance == 1 then
					if #v.Alliance == 1 then
						for i,d in pairs(ply.Alliance) do
							breakAlly(ply, d)
						end
						table.Empty(ply.Alliance)
						for i,d in pairs(v.Alliance) do
							setAlly(ply, d, "true")
						end
					elseif #v.Alliance == 0 then
						for i,d in pairs(ply.Alliance) do
							setAlly(v, d, "true")
						end
					end
				elseif #ply.Alliance == 0 then
					if #v.Alliance == 1 then
						for i,d in pairs(v.Alliance) do
							setAlly(ply, d, "true")
						end
					end
				end
				if #v.Alliance == 2 then
					for i,d in pairs(v.Alliance) do
						breakAlly(v, d)
					end
					table.Empty(v.Alliance)
				end

				setAlly(ply, v, "true")

			elseif ply.breakAlliance then

				for i,d in pairs(ply.Alliance) do
					breakAlly(ply, d)
				end
				table.Empty(ply.Alliance)

			elseif ply.removeRequest then

				ply:PrintMessage(HUD_PRINTTALK, "You have cancelled your alliance request to " .. v:Nick() .. ".")
				v:PrintMessage(HUD_PRINTTALK, ply:Nick() .. " has cancelled their alliance request to you.")
				allyRequest(ply, v, "nil", "nil")

			else

				if #player.GetAll() < 6 then
					if #ply.Alliance + 1 > #player.GetAll()/2 - 1 then return end
				end

				table.insert(v.incRequests, ply)
				ply:PrintMessage(HUD_PRINTTALK, "You have sent an alliance request to " .. v:Nick() .. ".")
				v:PrintMessage(HUD_PRINTTALK, ply:Nick() .. " has sent you an alliance request.")
				allyRequest(ply, v, "Incoming", "Outgoing")

			end
			ply.removeRequest = nil
			ply.acceptRequest = nil
			ply.breakAlliance = nil
		end
	end
end)

function breakAlly(ply1, ply2)
	ply1:PrintMessage(HUD_PRINTTALK, "You have broken your alliance with " .. ply2:Nick() .. ".")
	ply2:PrintMessage(HUD_PRINTTALK, ply1:Nick() .. " has broken their alliance with you.")

	setAlly(ply1, ply2, "nil")

	allyRequest(ply1, ply2, "nil", "nil")

	for i,d in pairs(ply2.Alliance) do
		if ply1 == d then
			table.remove(ply2.Alliance, i)
		end
	end

	ply1.allianceCount = nil

	if #ply2.Alliance == 0 then
		allianceCount = allianceCount - 1
		ply2.allianceCount = nil
	end

	timer.Simple(0.5, function()
		setPublicAllies()
	end)
end

function allyRequest(ply1, ply2, incoming, outgoing)
	net.Start("SetAllianceRequest")
		net.WriteEntity(ply2)
		net.WriteString(outgoing)
	net.Send(ply1)

	net.Start("SetAllianceRequest")
		net.WriteEntity(ply1)
		net.WriteString(incoming)
	net.Send(ply2)
end

function setAlly(ply1, ply2, string)
	if string != "nil" then
		table.insert(ply1.Alliance, ply2)
		table.insert(ply2.Alliance, ply1)
		ply1:PrintMessage(HUD_PRINTTALK, "You have allied with " .. ply2:Nick() .. ".")
		ply2:PrintMessage(HUD_PRINTTALK, ply1:Nick() .. " has allied with you.")
	end

	if #ply1.Alliance > 0 then
		ply2.allianceCount = ply1.allianceCount
	elseif #ply2.Alliance > 0 then
		ply1.allianceCount = ply2.allianceCount
	else
		allianceCount = allianceCount + 1

		ply1.allianceCount = allianceCount
		ply2.allianceCount = allianceCount
	end

	net.Start("SetAlliance")
		net.WriteEntity(ply2)
		net.WriteString(string)
	net.Send(ply1)

	net.Start("SetAlliance")
		net.WriteEntity(ply1)
		net.WriteString(string)
	net.Send(ply2)

	timer.Simple(0.5, function()
		setPublicAllies()
	end)
	
	allyRequest(ply1, ply2, "nil", "nil")
end

function setPublicAllies()
	for k,v in pairs(player.GetAll()) do
		for i,d in pairs(player.GetAll()) do
			net.Start("SetPublicAlliance")
				net.WriteEntity(v)
				net.WriteTable(v.Alliance)
				net.WriteInt(v.allianceCount, 8)
			net.Send(d)
		end
	end
end

function Allied(emp1, emp2)
	if emp1:GetPlayer() and emp1:GetPlayer().Alliance then
		for k,v in pairs(emp1:GetPlayer().Alliance) do
			if v:GetEmpire() == emp2 then
				return true
			end
		end
	else
		return false
	end
end