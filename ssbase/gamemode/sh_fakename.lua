---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com -- 
---------------------------- 

function PLAYER_META:CheckFake()
	if self:IsBot() then return	end

	timer.Simple(0.5, function()
		if self and self:IsValid() then
			self.fakename = util.JSONToTable(self.profile.fakename)
			if self.fakename.rank >= 0 then
				self:SetFake(self.fakename.name, self.fakename.rank)
			end
		end
	end)
end

function PLAYER_META:FakenameStatus(opt)
	if self:IsFakenamed() then
		if opt == "nm" then
			return self:GetFakeRankName()
		else
			return self:GetFakeRankColor()
		end
	end
end

function PLAYER_META:IsFakenamed()
	return self:GetNWBool("ss_bfakename")
end

function PLAYER_META:GetFakename()
	return self:GetNWString("ss_fakename")
end

function PLAYER_META:GetFakeRank()
	return self:GetNWInt("ss_fakerank")
end

function PLAYER_META:GetFakeRankName() 
	return SS.Ranks[self:GetFakeRank()].name 
end 

function PLAYER_META:GetFakeRankColor() 
	return SS.Ranks[self:GetFakeRank()].color 
end

function PLAYER_META:SetFake(fakename, fakerank)
	if self and self:IsValid() then
		if self:IsFakenamed() and fakename == nil then
			self:SetNWInt("ss_fakerank", -1)
			self:SetNWString("ss_fakename", nil)
			self:SetNWBool("ss_bfakename", false)
			self:ChatPrint("[FAKENAME]: You are now back to normal.\n")

			self.fakename = {["name"] = nil, ["rank"] = -1}
			self.profile.fakename = util.TableToJSON(self.fakename)
			self:ProfileUpdate("fakename", self.fakename)

		elseif fakename and fakerank then
			self:SetNWInt("ss_fakerank", fakerank)
			self:SetNWString("ss_fakename", fakename)
			self:SetNWBool("ss_bfakename", true)
			SS.PrintToAdmins("[FAKENAME]: "..self:Name().." is now "..self:GetFakename()..". Fakerank: "..self:GetFakeRankName()..".\n")

			self.fakename = {["name"] = fakename, ["rank"] = fakerank}
			self.profile.fakename = util.TableToJSON(self.fakename)
			self:ProfileUpdate("fakename", self.profile.fakename)
		end
	end
end