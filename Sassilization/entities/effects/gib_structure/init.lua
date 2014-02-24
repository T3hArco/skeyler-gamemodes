Gibs_Wood = {
	"models/gibs/furniture_gibs/FurnitureTable002a_Chunk03.mdl",
	"models/gibs/wood_gib01a.mdl",
	"models/gibs/wood_gib01b.mdl",
	"models/gibs/wood_gib01c.mdl",
	"models/gibs/wood_gib01d.mdl",
	"models/gibs/wood_gib01e.mdl"
}

Gibs_Stone = {
	"models/props_combine/breenbust_chunk05.mdl",
	"models/props_combine/breenbust_chunk06.mdl",
	"models/props_combine/breenbust_chunk07.mdl",
	"models/mrgiggles/sassilization/brick_small.mdl",
	"models/mrgiggles/sassilization/brick_small.mdl",
	"models/mrgiggles/sassilization/brick_small.mdl",
	"models/mrgiggles/sassilization/brick_small.mdl"
}

function EFFECT:Init(data)
	local structure = data:GetEntity()
	local power = data:GetScale()
	local height = data:GetRadius()
	local type = math.Round(tonumber(data:GetMagnitude()))
	local pos

	if IsValid( structure ) and structure ~= NULL then
		pos = structure:LocalToWorld( structure:OBBCenter() )
	end
	if data:GetOrigin() then
		pos = data:GetOrigin()
	end
	
	if not pos then return end
	
	if type == GIB_STONE then
		for i=1, power do
			local effectdata = EffectData()
				effectdata:SetOrigin(pos + Vector(0,0,height) + VectorRand() * 4)
				effectdata:SetScale(math.random(1, #Gibs_Stone))
				effectdata:SetMagnitude( GIB_STONE )
			util.Effect("gib", effectdata)
		end
	elseif type > GIB_STONE then
		for i=1, power do
			local effectdata = EffectData()
				effectdata:SetOrigin(pos + Vector(0,0,height) + VectorRand() * 4)
				effectdata:SetScale(math.random(1, #Gibs_Wood))
				effectdata:SetMagnitude( GIB_WOOD )
			util.Effect("gib", effectdata)
		end
		if type == GIB_ALL then
			for i=1, power do
				local effectdata = EffectData()
					effectdata:SetOrigin(pos + Vector(0,0,height) + VectorRand() * 4)
					effectdata:SetScale(math.random(1, #Gibs_Stone))
					effectdata:SetMagnitude( GIB_STONE )
				util.Effect("gib", effectdata)
			end
		end
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
