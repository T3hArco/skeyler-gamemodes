----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Gib = GIB_STONE

function ENT:Initialize()
	self:Setup("walltower", nil, true)
	self.ConnectedWalls = {}
    self.ConnectedGates = {}
end

function ENT:SellConnectedWalls()
    if(self.DeletedConnected or not self.ConnectedWalls) then
        return 0
    end
    self.DeletedConnected = true
    
    local Count = 1
    for wall, _ in pairs(self.ConnectedWalls) do
        if( IsValid( wall ) and wall:GetEmpire() == self:GetEmpire() ) then
            Count = Count + wall:SellWall()
        end
    end
	self:EmitSound("sassilization/units/buildingbreak0"..math.random(1, 2)..".wav", 70)
    self:Destroy(building.BUILDING_SELL)
    return Count
end

function ENT:OnBuilt()
end

function ENT:OnThink()
	--self:WallUpdateControl()
	return 2
end

function ENT:UpdateControl()
	self:WallUpdateControl()
end

function ENT:OnControl()
	self:WallUpdateControl()
end

function ENT:Plummet()
    if self.Plummeted then return end
    self.Plummeted = true
    if self:IsValid() then
        self.wallEnt = nil
        self.wallEnt2 = nil
        for wall, _ in pairs(self.ConnectedWalls) do
            if( IsValid( wall ) and wall:GetEmpire() == self:GetEmpire() ) then
                if (self.wallEnt != nil and self.wallEnt != wall) then
                    self.wallEnt2 = wall
                else
                    self.wallEnt = wall
                end
            end
        end

        timer.Simple(0.5, function()
            if !self.wallEnt then return end
            if self.wallEnt:IsValid() then
                local seg = self.wallEnt:GetNearestSegment(self:GetPos())
                if seg then
                    if !seg:IsDestroyed() then
                        seg:Plummet()
                    end
                end
            end
            if !self.wallEnt2 then return end
            if self.wallEnt2:IsValid() then
                local seg2 = self.wallEnt2:GetNearestSegment(self:GetPos())
                if seg2 then
                    if !seg2:IsDestroyed() then
                        seg2:Plummet()
                    end
                end
            end
        end)
        timer.Simple(1, function()
            if self.gate and self.gate:IsValid() then
                self.gate:Destroy( building.BUILDING_DESTROY )
            end
            self:Destroy( building.BUILDING_DESTROY )
        end)
    end
end