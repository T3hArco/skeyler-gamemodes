ITEM.ID = "miku"							--Should be a unique string that identifies the item
ITEM.Name = "Hatsune Miku"						--The name the item should display
 
ITEM.Price = 200000
 
ITEM.Model = "models/mrgiggles/skeyler/playermodels/miku.mdl"			--Model used by the item

ITEM.Type = "model"								--Also works for stuff like "mask" and such. Used for item compatibility

ITEM.Colorable = true							--Used if the model is colorable via setcolor (or in a models case, setplayercolor)
ITEM.Tintable = false							--Used if the model is colorable, but a translation is needed to $selfillumtint 

ITEM.CamPos = Vector(50, 30, 64)						-- Used the modify the position of the camera on DModelPanels 
ITEM.LookAt = Vector(0, 0, 64) 							-- Used to change the angle at which the camera views the model 
ITEM.Fov = 20 

ITEM.Slot = SS.STORE.SLOT.MODEL								-- What inventory slot this item shoud be placed in.

ITEM.Functions = {} 								--anything that can be called but not a gmod hook but more of a "store hook" goes here

ITEM.Functions["Equip"] = function ()
												--e.g miku hair attach with the models Equip
end

ITEM.Functions["Unequip"] = function ()
												--e.g miku hair attach with the models Equip
end

ITEM.Hooks = {}

function ITEM.Hooks.Think(data, ply)
	if CLIENT then
		if ply.IsPlayer && ply:IsPlayer() && ply:GetSkin() > 0 then
			if ply:Health() > 66 then 
				ply:SetSkin(1)
			elseif ply:Health() <= 66 and ply:Health() > 33 then 
				ply:SetSkin(2)
			elseif ply:Health() <= 33 and ply:Health() > 0 then 
				ply:SetSkin(3)
			else
				ply:SetSkin(4)
			end
		end
		
		local showhair = true
		
		if ply == LocalPlayer() and GetViewEntity():GetClass() == 'player' and !LocalPlayer():ShouldDrawLocalPlayer() then
			showhair = false
		end
		
		local hairmodel = "models/mrgiggles/skeyler/misc/miku_hair.mdl"
		
		if (data) then
			for i = 1, SS.STORE.SLOT.MAXIMUM do
				local info = data[i]
				
				if (info and info.item) then
					local item = SS.STORE.Items[info.item]
					
					if (item) then
						if (item.Type == "mask" or item.Type == "headcoverfull") then
							showhair = false
						else
							if (item.Type == "headcoverhalf") then
								hairmodel = "models/mrgiggles/skeyler/misc/miku_hair_short.mdl"
							elseif (item.Type == "headcoverpart") then
								hairmodel = "models/mrgiggles/skeyler/misc/miku_hair02.mdl"
							end
						end
					end
				end
			end
		end
	
		if(showhair) then
			ply.hairtoshow = hairmodel
		else
			ply.hairtoshow = nil
		end
	end
end

function ITEM.Hooks.PostDrawOpaqueRenderables(data, ply)
	if CLIENT && ply && ply:IsValid() && ply.hairtoshow then 
		if ply == LocalPlayer() and GetViewEntity():GetClass() == 'player' and !LocalPlayer():ShouldDrawLocalPlayer() and !LocalPlayer():GetObserverTarget() then return end
		if(ply.currenthair) then
			if(ply.currenthair:GetModel() != ply.hairtoshow) then
				ply.currenthair:SetModel(ply.hairtoshow)
			end
		else
			ply.currenthair = ClientsideModel(ply.hairtoshow)
			ply.currenthair:SetNoDraw(true)
		end
		
		local hairpos = Vector(0,0,0)
		local hairang = Angle(0,0,0)
		
		local p = nil
		if(ply.IsPlayer && ply:IsPlayer() && !ply:Alive() && IsValid(ply:GetRagdollEntity())) then
			p = ply:GetRagdollEntity()
		else
			p = ply
		end
		
		local index = p:LookupBone("ValveBiped.Bip01_Head1")
		
		if (index and index > -1) then
			local boneMatrix = p:GetBoneMatrix(index)
			local Pos, Ang = boneMatrix:GetTranslation(), boneMatrix:GetAngles()
			
			local model = ply.currenthair
			
			local up, right, forward = Ang:Up(), Ang:Right(), Ang:Forward()
			Pos = Pos + up*hairpos.z + right*hairpos.y + forward*hairpos.x -- NOTE: y and x could be wrong way round
			
			model:SetBodygroup(1,p:GetBodygroup(1))
			
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
end