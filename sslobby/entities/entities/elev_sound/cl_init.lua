include("shared.lua")

local elev_sounds = {}
local loop_sounds = {}
elevChime = Sound( "elevator_chime.mp3" )

usermessage.Hook( "elev_chime", function(um)
	local ent = Entity( um:ReadShort() )
	if (IsValid( ent ) and ent.chimeSnd) then
		ent.chimeSnd:Stop()
		ent.chimeSnd:Play()
	end
end )

function ENT:Initialize()
	self.chimeSnd = CreateSound( self, elevChime )
end

function ENT:Draw() end

usermessage.Hook( "elev_sound", function( um )
	local count = um:ReadShort()
	for i=1, count do
		local eid = um:ReadShort()
		local act = um:ReadShort()
		local ent = Entity( eid )
		if IsValid( ent ) then
			if act == 1 then
				loop_sounds[ eid ] = loop_sounds[ eid ] or {}
				local sound = "plats/elevator_large_start1.wav"
				elev_sounds[sound] = elev_sounds[sound] or Sound( sound )
				local snd = CreateSound( ent, elev_sounds[sound] )
				table.insert( loop_sounds[ eid ], snd )
				snd:ChangeVolume( .2, 0)
				snd:Play()
				
				local sound = "plats/elevator_move_loop1.wav"
				elev_sounds[sound] = elev_sounds[sound] or Sound( sound )
				local snd = CreateSound( ent, elev_sounds[sound] )
				table.insert( loop_sounds[ eid ], snd )
				snd:ChangeVolume( .35, 0)
				snd:Play()
				
			elseif act == 2 then
				if loop_sounds[ eid ] then
					for _, snd in pairs( loop_sounds[ eid ] ) do
						snd:Stop()
						snd = nil
					end
					loop_sounds[ eid ] = nil
				end
				local sound = "plats/elevator_stop2.wav"
				elev_sounds[sound] = elev_sounds[sound] or Sound( sound )
				local snd = CreateSound( ent, elev_sounds[sound] )
				snd:ChangeVolume(.4, 0)
				snd:Play()
			end
		end
	end
end )