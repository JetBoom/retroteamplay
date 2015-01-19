GM.MapList = {}
GM.EliminationIncrement = {}

if SERVER then
	function GM:AddMap(name, cleanname, garbage, garbage2, minplayers)
		table.insert(GM.MapList, {name, cleanname, nil, nil, minplayers})
	end
end

if CLIENT then
	function GM:AddMap(name, cleanname, description, author, minplayers)
		table.insert(GM.MapList, {name, cleanname, description, author, minplayers})
	end
end

function GM:GetMapTable(name)
	for i, tab in pairs(GM.MapList) do
		if tab[1] == name then return tab end
	end
end

GM:AddMap("noxctf_4towers", 				"4-Towers")
GM:AddMap("gm_build_fortwars_ctf_4towers3", "4-Towers V3")
GM:AddMap("gm_build_noxctf_battlefield", 	"Battlefield")
GM:AddMap("gm_build_noxctf_bigdesert2", 	"Big Desert V2")
GM:AddMap("noxctfnb_bigdesert", 			"Big Desert")
--GM:AddMap("noxnb_blizzard", 				"Blizzard")
GM:AddMap("noxtp_blockfort", 				"Block Fort")
GM:AddMap("noxnb_bloodgulch", 				"Bloodgulch")
GM:AddMap("noxtp_broadside_v2", 			"Broadside")
GM:AddMap("noxctfnb_broadside_v2", 			"Broadside V2")
GM:AddMap("noxctfnb_chamber", 				"Chamber")
GM:AddMap("noxtp_elementalwarb", 			"Elemental War")
GM:AddMap("noxtp_eternity_v1", 				"Eternity")
GM:AddMap("noxnb_forestfortress", 			"Forest Fortress")
GM:AddMap("noxnb_fortis", 					"Fortis")
GM:AddMap("noxctfnb_fortsofmadness", 		"Forts of Madness")
GM:AddMap("noxtp_hi2u3", 					"Hi2u3")
GM:AddMap("noxnb_infinity_f", 				"Infinity")
GM:AddMap("gm_build_noxctf_lavawars_v4", 	"Lava Wars")
GM:AddMap("gm_build_noxctf_mountain", 		"Mountain")
GM:AddMap("noxctf_oldie", 					"Oldie")
GM:AddMap("gm_build_noxctf_oldremix", 		"Old Remix")
GM:AddMap("nox_openfield", 					"Open Field")
GM:AddMap("noxctfnb_parkv3", 				"Park")
GM:AddMap("noxtp_rollercoaster", 			"Rollercoaster")
GM:AddMap("noxnb_streamline", 				"Streamline")
--GM:AddMap("nox_tech", 					"Tech")
GM:AddMap("noxtp_hi2u3", 					"Temple")
GM:AddMap("gm_nobuild_noxctf_temple_v2", 	"Temple V2")
GM:AddMap("noxctf_toy_fort_elite", 			"Toy Fort Elite")
GM:AddMap("nox_urban2c", 					"Urban")
GM:AddMap("nox_urban_classic", 				"Urban Classic")
GM:AddMap("noxctf_valleycorners_v3", 		"Valley Corners V3")


function GetNonExistantMaps()
	for i, maptab in pairs(GM.MapList) do
		if not file.Exists("../maps/"..maptab[1]..".bsp") then
			print(maptab[1])
		end
	end
end

collectgarbage("collect")
