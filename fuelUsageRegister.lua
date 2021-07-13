-- 
-- Enhanced Fuel Usage Script for FS19
-- by Blacky_BPG
-- 
-- Version: 1.9.0.0      | 13.07.2021 - initial FS19 release
-- 

fuelUsageRegister = {}
fuelUsageRegister.userDir = getUserProfileAppPath()
fuelUsageRegister.version = "1.9.0.0  -  13.07.2021"

if g_specializationManager:getSpecializationByName("BPG_fuelUsage") == nil then
	g_specializationManager:addSpecialization("BPG_fuelUsage", "BPG_fuelUsage", Utils.getFilename("BPG_fuelUsage.lua",  g_currentModDirectory),true , nil)

	local numVehT = 0
	for typeName, typeEntry in pairs(g_vehicleTypeManager:getVehicleTypes()) do
		if SpecializationUtil.hasSpecialization(Motorized, typeEntry.specializations) then
			g_vehicleTypeManager:addSpecialization(typeName, "BPG_fuelUsage")
			numVehT = numVehT + 1
		end
	end
	print(" ++ loading Enhanced Fuel Usage V "..tostring(fuelUsageRegister.version).." for "..tostring(numVehT).." motorized Vehicles")
end
