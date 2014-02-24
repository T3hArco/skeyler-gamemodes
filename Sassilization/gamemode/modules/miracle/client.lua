--------------------------------------------
-- "sa_lowcreed"
--
-- A sound that plays when you're low on creed.
--------------------------------------------

net.Receive("sa_lowcreed", function(bits)
	surface.PlaySound("sassilization/warnmessage.wav")
end)