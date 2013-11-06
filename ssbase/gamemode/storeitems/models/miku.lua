ITEM.ID = "miku"							--Should be a unique string that identifies the item
ITEM.Name = "Hatsune Miku"						--The name the item should display
 
ITEM.Price = 200000
 
ITEM.Model = "models/mrgiggles/skeyler/playermodels/miku.mdl"			--Model used by the item

ITEM.Type = "model"								--Also works for stuff like "mask" and such. Used for item compatibility

ITEM.Colorable = false							--Used if the model is colorable via setcolor (or in a models case, setplayercolor)
ITEM.Tintable = false							--Used if the model is colorable, but a translation is needed to $selfillumtint 

ITEM.CamPos = Vector(50, 30, 64)						-- Used the modify the position of the camera on DModelPanels 
ITEM.LookAt = Vector(0, 0, 64) 							-- Used to change the angle at which the camera views the model 
ITEM.Fov = 20 

ITEM.Functions = {} 								--anything that can be called but not a gmod hook but more of a "store hook" goes here

ITEM.Functions["Equip"] = function ()
												--e.g miku hair attach with the models Equip
end

ITEM.Functions["Unequip"] = function ()
												--e.g miku hair attach with the models Equip
end

ITEM.Hooks = {}

ITEM.Hooks["Think"] = function (item,ply)
        if CLIENT then
                local showhair = true
                local hairmodel = "models/mrgiggles/skeyler/misc/miku_hair.mdl"
                for k,v in pairs(SS.STORE.Equipped) do
                        if(!SS.STORE.Items[v]) then continue end
                        local i = SS.STORE.Items[v]
                        if(i.Type == "mask") then
                                showhair = false
                        end
                        if(i.Type == "headcoverfull") then
                                hairmodel = "models/mrgiggles/skeyler/misc/miku_hair_short.mdl"
                        end
                end
                if(showhair) then
                        ply.hairtoshow = hairmodel
                else
                        ply.hairtoshow = nil
                end
        end
end
ITEM.Hooks["PostPlayerDraw"] = function (item,ply)
	if CLIENT && ply.hairtoshow then 
		if(ply.currenthair) then
			if(ply.currenthair:GetModel() == ply.hairtoshow) then
				ply.currenthair:Remove()
				ply.currenthair = ClientsideModel(ply.hairtoshow)
			end
		else
			ply.currenthair = ClientsideModel(ply.hairtoshow)
		end
		
		local hairpos = Vector(0,0,0)
		local hairang = Angle(0,0,0)
		
		local Pos, Ang = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Head1"))
		
		local model = ply.currenthair
		
		local up, right, forward = Ang:Up(), Ang:Right(), Ang:Forward()
		Pos = Pos + up*hairpos.z + right*hairpos.y + forward*hairpos.x -- NOTE: y and x could be wrong way round
		
		local NewAng, FinalAng = Ang, Ang
		NewAng:RotateAroundAxis(Ang:Up(), hairang.p) 
		FinalAng.p = NewAng.p 
		NewAng = Ang 
		NewAng:RotateAroundAxis(Ang:Forward(), hairang.y) 
		FinalAng.y = NewAng.y 
		NewAng = Ang 
		NewAng:RotateAroundAxis(Ang:Right(), hairang.r) 
		FinalAng.r = NewAng.r 
		Ang = FinalAng 
		
		model:SetModelScale(t.scale, 0) --remove this line if its not needed
		
		model:SetPos(Pos)
		model:SetAngles(Ang)

		model:SetRenderOrigin(Pos)
		model:SetRenderAngles(Ang)
		model:SetupBones()
		model:DrawModel()
		model:SetRenderOrigin()
		model:SetRenderAngles()
	end
end