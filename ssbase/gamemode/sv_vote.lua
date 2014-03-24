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

util.AddNetworkString("ss_startvote") 
util.AddNetworkString("ss_endvote") 
util.AddNetworkString("ss_vote") 

module("vote") 

local isVoting = false  
local currentvote = false 
local results = false 

function Start(ply, name, time, callback, ...) 
	local options = {...} 

	if isVoting then 
		timer.Simple(5, function() Start(name, time, callback, unpack(options)) end) 
		return 
	end 

	if !name then 
		Error("No name specified for the vote?") 
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
	currentvote.callback = callback 
	currentvote.options = options 
	currentvote.votes = {} 

	results = {} 

	SendVote()

	timer.Create("SS_Vote", tonumber(time), 1, function() 
		EndVote() 
	end ) 

	return currentvote 
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

	winner = 1
	for k,v in pairs(results) do -- default to first wins if equal
		if v > results[winner] then 
			winner = k 
		end 
	end 

	currentvote.callback(currentvote.options[winner]) 
	currentvote = false 
	results = false 
	isVoting = false 
end 

net.Receive("ss_vote", function(l, ply)  
	if isVoting then 
		local num = net.ReadInt(4) 
		if num >= 1 and num <= #currentvote.options then 
			results[num] = results[num] and results[num]+1 or 1

			if currentvote.votes[ply:SteamID()] then 
				results[currentvote.votes[ply:SteamID()]] = results[currentvote.votes[ply:SteamID()]]-1 
			end 

			currentvote.votes[ply:SteamID()] = num 
		end 
	end 
end )

hook.Add("PlayerInitialSpawn", "SendSSVote", function(ply) 
	SendVote(ply) -- send vote to new players
end )