local Prefix = GM.FolderName .. "/gamemode/modules/unit/units"

Unit = {}

SA.UNITS = {}
SA.UNITDATA = {}

local UNITS = SA.UNITS
	UNITS.units = {}
	UNITS.metatables = {}

local UNITDATA = SA.UNITDATA

function Unit:Unit( uid )
	
	return UNITS.units[tonumber( uid )]
	
end

function Unit:ValidUnit( u )
    if( u and self:IsUnit( u ) and u:IsValid() ) then
        return true
    end
end

function Unit:IsUnit(u)
	return tobool( u.unit_index )
end


function Unit:CanSpawn(Empire, Name, IgnoreCost)
	if( not Empire ) then return false end

	local Unit = self:GetData(Name)

	if (not Unit) then
	    return false
	end

	if (Unit.NoSpawn) then
	    return false
	end

	if(not IgnoreCost) then
	    if(Unit.Gold and Unit.Gold > Empire:GetGold()) then
	        return false
	    end
	    
	    if(Unit.Food and Unit.Food > Empire:GetFood()) then
	        return false
	    end
	    
	    if(Unit.Iron and Unit.Iron > Empire:GetIron()) then
	        return false
	    end
	    
	    if(Empire:GetSupplied() + Unit.Supply > Empire:GetSupply()) then
	        return false
	    end
	end
	
	if (Unit.Require) then
		for k, v in pairs(Unit.Require) do
			if (not building.HasBuilding(Empire, k, v)) then
				return false
			end
		end
	end
	
	return true
end

function Unit:ListUnits()
    return UNITDATA --removed table.Copy //Sassafrass
end

function Unit:GetData(unit)
	return UNITDATA[unit] --removed table.Copy //Sassafrass
end

local function GetUnits()
	local folders = {}

	if (SERVER) then
		local __, folderss = file.Find("gamemodes/" .. Prefix .. "/*", "MOD") -- We haven't included any files yet so we search from root directory instead of the lua directory.

		for _, folder in pairs(folderss) do
			if(	folder ~= "."			and
				folder ~= ".."			and
				folder ~= ".svn"		and
				folder ~= "base"		and	
				not folder:find(".lua")	) then
				
				table.insert(folders, folder)
			end
		end
	elseif (CLIENT) then
		local __, folderss = file.Find(Prefix .. "/*", "LUA")

		for _, folder in pairs(folderss) do
			if(	folder ~= "."			and
				folder ~= ".."			and
				folder ~= ".svn"		and
				folder ~= "base"		and	
				not folder:find(".lua")	) then
				
				table.insert(folders, folder)
			end
		end
	end
	
	return folders
end

local function LoadUnit(name)
	
	UNIT = table.Copy( UNITS.metatables["base"].__index )
	UNIT.Class = name
	UNIT.BaseClass = UNITS.metatables["base"].__index
	
	Msg("\t\tLoading Unit: "..name.."\n")

	local searchPath = "MOD"
	local prename = "gamemodes/" .. Prefix .. "/" .. name
	
	if (CLIENT) then
		prename = Prefix .. "/" .. name
		searchPath = "LUA"
	end

	Msg("\t\t\tLoading shared.lua\n")
	
	include("units/" .. name .. "/shared.lua")
	
	-- We haven't included any files yet so we search from root directory instead of the lua directory.
	if (SERVER) then
		if (file.Exists(prename .. "/cl_init.lua", searchPath)) then
			AddCSLuaFile("units/"..name.."/cl_init.lua")
		end
		
		if (file.Exists(prename.."/shared.lua", searchPath)) then
			AddCSLuaFile("units/"..name.."/shared.lua")
		end
		
		if (file.Exists(prename.."/init.lua", searchPath)) then
			Msg("\t\t\tLoading init.lua\n")
			include("units/"..name.."/init.lua")
		else
			Error( "Failed to load init.lua\n" )
		end
	elseif (CLIENT) then
		Msg("\t\t\tLoading cl_init.lua\n")
	
		include("units/" .. name .. "/cl_init.lua")
	end
	
	UNITS.metatables[name] = { __index = UNIT, __tostring = UNIT.__tostring }
	UNITDATA[name] = UNIT

	Msg("\t\tLoaded Successfully ["..Unit:GetData(name).Name.."]\n")

	UNIT = nil
end

function GM:LoadUnits()
	UNIT = {}
	UNIT.Class = "base"
	
	Msg("\t\tLoading Base Unit\n")
	Msg("\t\t\tLoading shared.lua\n")
	
	include("units/base/shared.lua")
	
	if(SERVER) then
		AddCSLuaFile("units/base/shared.lua")
		AddCSLuaFile("units/base/cl_init.lua")
		
		Msg("\t\t\tLoading init.lua\n")
		
		include("units/base/init.lua")
	elseif(CLIENT) then
		Msg("\t\t\tLoading cl_init.lua\n")
		
		include("units/base/cl_init.lua")
	end
	
	Msg("\t\tLoaded Successfully\n")
	
	UNITS.metatables["base"] = { __index = UNIT, __tostring = UNIT.__tostring }
	UNIT = nil

	for _, folder in pairs(GetUnits()) do
		LoadUnit(folder)
	end
end

GM:LoadUnits()

hook.Add("InitPostEntity", "SA.UnitInit", function()
	for k, v in pairs(Unit:ListUnits()) do

		SA.UNITDATA[k].SightRangeSqr = (v.SightRange)^2
		SA.UNITDATA[k].RangeSqr = (v.Range)^2

		if( CLIENT ) then
			SA.UNITDATA[k].PreviewSelectedSize = v.Size * 2.25
			SA.UNITDATA[k].SelectedSize = v.Size * 1.75
		end

	end
end)