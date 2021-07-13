-- 
-- Enhanced Fuel Usage Script for FS17
-- by Blacky_BPG
-- 
-- Version: 1.9.0.0      | 13.07.2021 - initial FS19 release
-- 

BPG_fuelUsage = {}

function BPG_fuelUsage.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(Motorized, specializations)
end

function BPG_fuelUsage.registerEventListeners(vehicleType)
	local specFunctions = {"onUpdate"}
	
	for _, specFunction in ipairs(specFunctions) do
		SpecializationUtil.registerEventListener(vehicleType, specFunction, BPG_fuelUsage)
	end
end

function BPG_fuelUsage:onUpdate(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
	local spec = self.spec_BPG_fuelUsage
	local specM = self.spec_motorized
	if self.isServer and self:getIsMotorStarted() then
		local dtFactor = (dt / 1000 / 60 / 60) * g_currentMission.missionInfo.timeScale
		local dtBase = (dt / 1000 / 60 / 60)
		if specM ~= nil and specM.lastFuelUsage ~= nil and specM.lastFuelUsage > 0 then
			local loadFactor = (specM:getMotorLoadPercentage() * (1 / (self:getMotor():getMaxRpm() - self:getMotor():getMinRpm()) * (self:getMotor():getLastMotorRpm() - self:getMotor():getMinRpm())))
			local loadFactor =  1 + (loadFactor * loadFactor)
			local usageDieselBase = specM.lastFuelUsage * dtBase
			local usageDefBase = specM.lastDefUsage * dtBase
			local usageDiesel = ((specM.lastFuelUsage * loadFactor) * dtFactor) - usageDieselBase
			local usageDef = ((specM.lastDefUsage * loadFactor) * dtFactor) - usageDefBase
			local unitDef = -1
			local unitDiesel = -1
			if self.spec_fillUnit ~= nil then
				for fUIndex, fillUnit in ipairs(self.spec_fillUnit.fillUnits) do
					if fillUnit.fillType == FillType.DIESEL then
						unitDiesel = fUIndex
					end
					if fillUnit.fillType == FillType.DEF then
						unitDef = fUIndex
					end
				end
			end
			if usageDef > 0 then
				self:addFillUnitFillLevel(self:getOwnerFarmId(), unitDef, -usageDef, FillType.DEF, ToolType.UNDEFINED)
			end
			if usageDiesel > 0 then
				self:addFillUnitFillLevel(self:getOwnerFarmId(), unitDiesel, -usageDiesel, FillType.DIESEL, ToolType.UNDEFINED)
			end
			local newFuelUsage = (usageDiesel + usageDieselBase) / g_currentMission.missionInfo.timeScale
			local newDefUsage = (usageDef + usageDefBase) / g_currentMission.missionInfo.timeScale
			specM.lastFuelUsage = newFuelUsage/dt * 1000 * 60 * 60
			specM.lastDefUsage = newDefUsage/dt * 1000 * 60 * 60
			specM.fuelUsageBuffer:add(newFuelUsage/dt * 1000 * 60 * 60)
		end
	end
end
