---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com -- 
---------------------------- 

ITEM.ID = "elin"							--Should be a unique string that identifies the item
ITEM.Name = "Elin"						--The name the item should display
 
ITEM.Price = 200000
 
ITEM.Model = "models/captainbigbutt/skeyler/playermodels/elin.mdl"			--Model used by the item

ITEM.Type = "model"								--Also works for stuff like "mask" and such. Used for item compatibility

ITEM.Colorable = false							--Used if the model is colorable via setcolor (or in a models case, setplayercolor)
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

ITEM.Hooks["Think"] = function (data,ply)
	if CLIENT then
		ply.hairtoshow = "models/captainbigbutt/skeyler/misc/elin_hair.mdl"
	end
	
	if (SERVER) then
		if (data) then
			local info = data[SS.STORE.SLOT.HEAD]
			
			if (info and info.unique) then
				local item = SS.STORE.Items[info.unique]
				
				if (item) then
					if (item.Type == "mask" or item.Type == "headcoverfull") then
						ply:SetBodygroup(1, 3)
					elseif (item.Type == "headcoverhalf") then
						ply:SetBodygroup(1, 2)
					elseif (item.Type == "headcoverpart") then
						ply:SetBodygroup(1, 1)
					else
						ply:SetBodygroup(1, 0)
					end
				end
			end
		end
	end
end

ITEM.Hooks["PostDrawOpaqueRenderables"] = function (item,ply)
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
		
		if (index > -1) then
			local Pos, Ang = p:GetBonePosition(index)
			
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