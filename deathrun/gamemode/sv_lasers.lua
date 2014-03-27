local function FixLazers()
	for k,v in pairs(ents.FindByClass("env_laser")) do
		local ts = v:GetSaveTable().LaserTarget
		if(ts && ts != "") then
			local t = ents.FindByName(ts)[1]
			if(t) then
				local tp = t:GetParent()
				t:SetParent(nil) --source doesn't enjoy moving things that have parents
				local p = v:GetParent()
				v:SetParent(nil)
				local ep = v:GetPos()
				local tep = t:GetPos()
				local c = ep+(tep-ep)*0.5 --we are calculating the centre and using it to trace
				local tracedata = {}
				tracedata.start = c
				tracedata.endpos = ep
				tracedata.filter = v
				tracedata.mask = MASK_ALL
				local trace = util.TraceLine(tracedata) --trace to wall
				local hp = trace.HitPos
				local np = hp+((tep-hp)*(1/(hp:Distance(tep)))) --move the position slightly away from the wall
				v:SetPos(np)
				if(tp && tp != NULL) then
					t:SetParent(p)
				end
				if(p && p != NULL) then
					v:SetParent(p)
				end
			end
		end
	end
end

hook.Add("InitPostEntity","fixlaz0rs",FixLazers)