require "ETWModData";

local SBvars = SandboxVars.EvolvingTraitsWorld;

local notification = function() return EvolvingTraitsWorld.settings.EnableNotifications end
local debug = function() return EvolvingTraitsWorld.settings.GatherDebug end

local function coldTraits()
	local player = getPlayer();
	local coldStrength = player:getBodyDamage():getColdStrength() / 100;
	local modData = player:getModData().EvolvingTraitsWorld.ColdSystem;
	if coldStrength > 0 and modData.CurrentlySick == false then modData.CurrentlySick = true end
	if modData.CurrentlySick == true then
		modData.CurrentColdCounterContribution = modData.CurrentColdCounterContribution + coldStrength / 60;
		if debug() then print("ETW Logger: CurrentColdCounterContribution = "..modData.CurrentColdCounterContribution) end
		if coldStrength == 0 then
			modData.CurrentColdCounterContribution = math.min(10, modData.CurrentColdCounterContribution);
			if debug() then print("ETW Logger: Healthy now, CurrentColdCounterContribution = "..modData.CurrentColdCounterContribution) end
			modData.CurrentlySick = false;
			if modData.CurrentColdCounterContribution == 10 then
				modData.ColdsWeathered = modData.ColdsWeathered + 1
			end
			modData.CurrentColdCounterContribution = 0;
			if player:HasTrait("ProneToIllness") and modData.ColdsWeathered >= SBvars.ColdIllnessSystemColdsWeathered / 2 then
				player:getTraits():remove("ProneToIllness");
				if notification() == true then thenHaloTextHelper.addTextWithArrow(player, getText("UI_trait_pronetoillness"), false, HaloTextHelper.getColorGreen()) end
			elseif not player:HasTrait("Resilient") and modData.ColdsWeathered >= SBvars.ColdIllnessSystemColdsWeathered then
				player:getTraits():add("Resilient");
				if notification() == true then HaloTextHelper.addTextWithArrow(player, getText("UI_trait_resilient"), true, HaloTextHelper.getColorGreen()) end
				Events.EveryOneMinute.Remove(coldTraits);
			end
		end
	end
end

local function foodSicknessTraits()
	local player = getPlayer();
	local foodSicknessStrength = player:getBodyDamage():getFoodSicknessLevel() / 100;
	if debug() then print("ETW Logger: foodSicknessStrength="..foodSicknessStrength) end
	local modData = player:getModData().EvolvingTraitsWorld;
	modData.FoodSicknessWeathered = modData.FoodSicknessWeathered + foodSicknessStrength;
	if player:HasTrait("WeakStomach") and modData.FoodSicknessWeathered >= SBvars.FoodSicknessSystemCounter / 2 then
		player:getTraits():remove("WeakStomach");
		if notification() == true then HaloTextHelper.addTextWithArrow(player, getText("UI_trait_WeakStomach"), false, HaloTextHelper.getColorGreen()) end
	elseif not player:HasTrait("IronGut") and modData.FoodSicknessWeathered >= SBvars.FoodSicknessSystemCounter then
		player:getTraits():add("IronGut");
		if notification() == true then HaloTextHelper.addTextWithArrow(player, getText("UI_trait_IronGut"), true, HaloTextHelper.getColorGreen()) end
		Events.EveryOneMinute.Remove(foodSicknessTraits);
	end
end

local function weightSystem()
	local player = getPlayer();
	local startingTraits = player:getModData().EvolvingTraitsWorld.StartingTraits;
	local modData = player:getModData().EvolvingTraitsWorld.SleepSystem;
	local weight = player:getNutrition():getWeight();
	local stress = player:getStats():getStress();
	local unhappiness = player:getBodyDamage():getUnhappynessLevel();
	if debug() then print("ETW Logger: stress: "..stress.." unhappiness:"..unhappiness) end -- stress is 0-1, unhappiness is 0-100
	if weight >= 100 or weight <= 65 then
		if not player:HasTrait("SlowHealer") and startingTraits.FastHealer ~= true then
			player:getTraits():add("SlowHealer");
			if notification() == true then HaloTextHelper.addTextWithArrow(player, getText("UI_trait_SlowHealer"), true, HaloTextHelper.getColorRed()) end
		end
		if not player:HasTrait("Thinskinned") and startingTraits.ThickSkinned ~= true then
			player:getTraits():add("Thinskinned");
			if notification() == true then HaloTextHelper.addTextWithArrow(player, getText("UI_trait_ThinSkinned"), true, HaloTextHelper.getColorRed()) end
		end
	end
	if (weight > 85 and weight < 100) or (weight > 65 and weight < 75) then
		if not player:HasTrait("HeartyAppitite") and startingTraits.LightEater ~= true then
			player:getTraits():add("HeartyAppitite");
			if notification() == true then HaloTextHelper.addTextWithArrow(player, getText("UI_trait_heartyappetite"), true, HaloTextHelper.getColorRed()) end
		end
		if not player:HasTrait("HighThirst") and startingTraits.LowThirst ~= true then
			player:getTraits():add("HighThirst");
			if notification() == true then HaloTextHelper.addTextWithArrow(player, getText("UI_trait_HighThirst"), true, HaloTextHelper.getColorRed()) end
		end
		if player:HasTrait("Thinskinned") and startingTraits.ThinSkinned ~= true then
			player:getTraits():remove("Thinskinned");
			if notification() == true then HaloTextHelper.addTextWithArrow(player, getText("UI_trait_ThinSkinned"), false, HaloTextHelper.getColorGreen()) end
		end
		if player:HasTrait("SlowHealer") and startingTraits.SlowHealer ~= true then
			player:getTraits():remove("SlowHealer");
			if notification() == true then HaloTextHelper.addTextWithArrow(player, getText("UI_trait_SlowHealer"), false, HaloTextHelper.getColorGreen()) end
		end
		if player:HasTrait("ThickSkinned") and startingTraits.ThickSkinned ~= true then
			player:getTraits():remove("ThickSkinned");
			if notification() == true then HaloTextHelper.addTextWithArrow(player, getText("UI_trait_thickskinned"), false, HaloTextHelper.getColorRed()) end
		end
		if player:HasTrait("FastHealer") and startingTraits.FastHealer ~= true then
			player:getTraits():remove("FastHealer");
			if notification() == true then HaloTextHelper.addTextWithArrow(player, getText("UI_trait_FastHealer"), false, HaloTextHelper.getColorRed()) end
		end
		if player:HasTrait("LightEater") and startingTraits.LightEater ~= true then
			player:getTraits():remove("LightEater");
			if notification() == true then HaloTextHelper.addTextWithArrow(player, getText("UI_trait_lighteater"), false, HaloTextHelper.getColorRed()) end
		end
		if player:HasTrait("LowThirst") and startingTraits.LowThirst ~= true then
			player:getTraits():remove("LowThirst");
			if notification() == true then HaloTextHelper.addTextWithArrow(player, getText("UI_trait_LowThirst"), false, HaloTextHelper.getColorRed()) end
		end
	end
	if weight >= 75 and weight <= 85 then
		if player:HasTrait("HeartyAppitite") and startingTraits.HeartyAppetite ~= true then
			player:getTraits():remove("HeartyAppitite");
			if notification() == true then HaloTextHelper.addTextWithArrow(player, getText("UI_trait_heartyappetite"), false, HaloTextHelper.getColorGreen()) end
		end
		if player:HasTrait("HighThirst") and startingTraits.HighThirst ~= true then
			player:getTraits():remove("HighThirst");
			if notification() == true then HaloTextHelper.addTextWithArrow(player, getText("UI_trait_HighThirst"), false, HaloTextHelper.getColorGreen()) end
		end
		if (stress <= 0.75 and unhappiness <= 75) and ((SBvars.SleepSystem == true and modData.SleepHealthinessBar > 0) or SBvars.SleepSystem == false) then
			if not player:HasTrait("LightEater") and startingTraits.HeartyAppetite ~= true then
				player:getTraits():add("LightEater");
				if notification() == true then HaloTextHelper.addTextWithArrow(player, getText("UI_trait_lighteater"), true, HaloTextHelper.getColorGreen()) end
			end
			if not player:HasTrait("LowThirst") and startingTraits.HighThirst ~= true then
				player:getTraits():add("LowThirst");
				if notification() == true then HaloTextHelper.addTextWithArrow(player, getText("UI_trait_LowThirst"), true, HaloTextHelper.getColorGreen()) end
			end
			local passiveLevels = player:getPerkLevel(Perks.Strength) + player:getPerkLevel(Perks.Fitness);
			if passiveLevels >= SBvars.WeightSystemSkill then
				if not player:HasTrait("ThickSkinned") and startingTraits.ThinSkinned ~= true then
					player:getTraits():add("ThickSkinned");
					if notification() == true then HaloTextHelper.addTextWithArrow(player, getText("UI_trait_thickskinned"), true, HaloTextHelper.getColorGreen()) end
				end
				if not player:HasTrait("FastHealer") and startingTraits.SlowHealer ~= true then
					player:getTraits():add("FastHealer");
					if notification() == true then HaloTextHelper.addTextWithArrow(player, getText("UI_trait_FastHealer"), true, HaloTextHelper.getColorGreen()) end
				end
			end
		else
			if player:HasTrait("LightEater") and startingTraits.LightEater ~= true then
				player:getTraits():remove("LightEater");
				if notification() == true then HaloTextHelper.addTextWithArrow(player, getText("UI_trait_lighteater"), false, HaloTextHelper.getColorRed()) end
			end
			if player:HasTrait("LowThirst") and startingTraits.LowThirst ~= true then
				player:getTraits():remove("LowThirst");
				if notification() == true then HaloTextHelper.addTextWithArrow(player, getText("UI_trait_LowThirst"), false, HaloTextHelper.getColorRed()) end
			end
		end
	end
end

local function asthmaticTrait()
	local player = getPlayer();
	local modData = player:getModData().EvolvingTraitsWorld;
	local running = player:isRunning();
	local sprinting = player:isSprinting();
	local smoker = player:HasTrait("Smoker");
	local asthmatic = player:HasTrait("Asthmatic");
	local outside = player:isOutside();
	local endurance = player:getStats():getEndurance(); -- 0-1
	local temperature = getClimateManager():getAirTemperatureForCharacter(player);
	local temperatureMultiplier = math.max(0, 1.01 ^ (- 7.6 * temperature) + 0.53)
	local lowerBoundary = -2 * SBvars.AsthmaticCounter;
	local upperBoundary = 2 * SBvars.AsthmaticCounter;
	if running or sprinting and temperature <= 10 then
		local counterIncrease = temperatureMultiplier * (outside and 1.2 or 1) * (smoker and 1.5 or 0.8) * (asthmatic and 1.5 or 0.8) * (sprinting and 1.5 or 1);
		modData.AsthmaticCounter = modData.AsthmaticCounter + counterIncrease;
		if debug() then print("ETW Logger: counterIncrease: "..counterIncrease) end
		if debug() then print("ETW Logger: modData.AsthmaticCounter: "..modData.AsthmaticCounter) end
		if modData.AsthmaticCounter >= SBvars.AsthmaticCounter and not player:HasTrait("Asthmatic") then
			player:getTraits():add("Asthmatic");
			if notification() == true then HaloTextHelper.addTextWithArrow(player, getText("UI_trait_Asthmatic"), true, HaloTextHelper.getColorRed()) end
		elseif modData.AsthmaticCounter <= SBvars.AsthmaticCounter and player:HasTrait("Asthmatic") then
			player:getTraits():remove("Asthmatic");
			if notification() == true then HaloTextHelper.addTextWithArrow(player, getText("UI_trait_Asthmatic"), false, HaloTextHelper.getColorGreen()) end
		end
	end
	if not running and not sprinting and temperature >= 0 then
		local counterDecrease = (1 + player:getPerkLevel(Perks.Fitness) * 0.1) * (smoker and 0.5 or 1) * (asthmatic and 0.5 or 1) * endurance;
		modData.AsthmaticCounter = modData.AsthmaticCounter - counterDecrease;
		if debug() then print("ETW Logger: modData.AsthmaticCounter: "..modData.AsthmaticCounter) end
	end
end

local function initializeEvents(playerIndex, player)
	Events.EveryOneMinute.Remove(coldTraits);
	if SBvars.ColdIllnessSystem == true and not player:HasTrait("Resilient") then Events.EveryOneMinute.Add(coldTraits) end
	Events.EveryOneMinute.Remove(foodSicknessTraits)
	if SBvars.FoodSicknessSystem == true and not player:HasTrait("IronGut") then Events.EveryOneMinute.Add(foodSicknessTraits) end
	Events.EveryTenMinutes.Remove(weightSystem);
	if SBvars.WeightSystem == true then Events.EveryTenMinutes.Add(weightSystem) end
	Events.EveryOneMinute.Remove(asthmaticTrait);
	if SBvars.Asthmatic == true and player:getModData().EvolvingTraitsWorld.StartingTraits.Asthmatic == false then Events.EveryOneMinute.Add(asthmaticTrait) end
end

Events.OnCreatePlayer.Remove(initializeEvents);
Events.OnCreatePlayer.Add(initializeEvents);