---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com -- 
---------------------------- 

local timer = timer 
local Error = Error 
local net = net 
local unpack = unpack 
local table = table 
local hook = hook 
local util = util 
local tonumber = tonumber 
local print = print 
local PrintTable = PrintTable 
local pairs = pairs 
local isnumber = isnumber 
local ChatPrintAll = ChatPrintAll 

util.AddNetworkString("ss_startvote") 
util.AddNetworkString("ss_endvote") 
util.AddNetworkString("ss_vote") 
util.AddNetworkString("ss_revote") 

module("vote") 

local isVoting = false  
local currentvote = false 
local results = false 

function IsVoting() 
	return isVoting 
end 

function Start(ply, name, time, successCallback, failedCallback, ...) 
	local options = {...} 

	if isVoting then 
		timer.Simple(5, function() Start(name, time, callback, unpack(options)) end) 
		return 
	end 

	if !name then 
		Error("No name specified for the vote?") 
		return 
	end 

	if !time or !isnumber(tonumber(time)) then 
		Error("Vote syntax error, time is not a number") 
		return 
	end 

	if !options[1] then 
		Error("No vote options for: ".. name) 
		return 
	end 

	if ply and ply.IsValid and ply:IsValid() then ply = ply:Name() else ply = "Console" end 

	isVoting = true 

	currentvote = {} 
	currentvote.name = name 
	currentvote.time = time 
	currentvote.ply = ply 
	currentvote.successCallback = successCallback 
	currentvote.failedCallback = failedCallback 
	currentvote.options = options 
	currentvote.votes = {} 

	results = {} 

	SendVote()

	timer.Create("SS_Vote", tonumber(time), 1, function() 
		EndVote() 
	end ) 

	return currentvote -- return this for shits 'n giggles
end 

function SendVote(ply)  
	if isVoting and currentvote then -- Make sure it exists derp
		net.Start("ss_startvote") 
			net.WriteString(currentvote.name) 
			net.WriteString(currentvote.ply) 
			net.WriteTable(currentvote.options) 
		if ply then 
			net.Send(ply) 
		else 
			net.Broadcast() 
		end 
	end 
end 

function EndVote() 
	net.Start("ss_endvote") 
	net.Broadcast() 

	winner = 0
	if table.Count(results) > 0 then -- We know there will be at least one winner
		for k,v in pairs(results) do -- default to first wins if equal 
			if v != 0 and (winner == 0 or v > results[winner]) then 
				winner = k 
			end 
		end 
		currentvote.successCallback(currentvote.options[winner]) 
	else -- WE FAILED!  ABORT!  ABORT!
		if currentvote.failedCallback then 
			currentvote.failedCallback() 
		else 
			ChatPrintAll("The vote has failed, no one voted!") 
		end 
	end 

	currentvote = false 
	results = false 
	isVoting = false 
end 

function Revote(ply) 
	if isVoting then 
		if currentvote.votes[ply:SteamID()] then 
			if results[currentvote.votes[ply:SteamID()]] then 
				results[currentvote.votes[ply:SteamID()]] = results[currentvote.votes[ply:SteamID()]]-1 
			end 
			currentvote.votes[ply:SteamID()] = false 
		end 
	end 
end 

net.Receive("ss_vote", function(l, ply)  
	if isVoting then 
		local num = net.ReadInt(4) 
		if !currentvote.votes[ply:SteamID()] and num >= 1 and num <= table.Count(currentvote.options) then 
			results[num] = results[num] and results[num]+1 or 1
			currentvote.votes[ply:SteamID()] = num 
		end 
	end 
end )

hook.Add("PlayerInitialSpawn", "SendSSVote", function(ply) 
	SendVote(ply) -- send vote to new players
end )