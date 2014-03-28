---------------------------- 
--        Deathrun        -- 
-- Created by Skeyler.com -- 
---------------------------- 

SS.MapList = {} 

function SS:AddMap(name, save) 
	SS.MapList[name] = {name=name} 
	if save then SS:Save() end 
end 

-- These will all get saved once the maps are loaded
-- SS:AddMap("akai_sup3r_f1n4l") -- This map needs some fixes 
SS:AddMap("daethrun_ale-tech_v3") 
SS:AddMap("deathrun_amazon_b4") 
SS:AddMap("deathrun_ambiance") 
SS:AddMap("deathrun_arduous_final_fixed") 
SS:AddMap("deathrun_atomic_warfare") 
SS:AddMap("deathrun_aztecan_escape_b1") 
SS:AddMap("deathrun_aztecan_finalb3")
SS:AddMap("deathrun_aztecan_escape_v5") 
SS:AddMap("deathrun_blood_final") 
SS:AddMap("deathrun_castlerun_fixed") 
SS:AddMap("deathrun_cavern_b3") 
SS:AddMap("deathrun_cb_egypt_v1") 
SS:AddMap("deathrun_control_d_fixed") 
SS:AddMap("deathrun_extremeway_gm4") 
SS:AddMap("deathrun_iceworld_vfix2") 
SS:AddMap("deathrun_italyrats_final_gm2") 
SS:AddMap("deathrun_marioworld_final") 
SS:AddMap("deathrun_poker_final5") 
SS:AddMap("deathrun_pool_gm1") 
SS:AddMap("deathrun_ramesses_revenge_v3") 
SS:AddMap("deathrun_simpsons_final") 
SS:AddMap("deathrun_starwars_b1_gm") 
SS:AddMap("deathrun_steam_works_gm1") 
SS:AddMap("dr_minecraft") 