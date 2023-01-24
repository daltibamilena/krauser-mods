HasLicencaCheck = function(licenca_type, showText)
    local inventory = getPlayer():getInventory()
    if getPlayer():getAccessLevel() == 'Admin' then return true end
    if checkInventoryForLicences(inventory, licenca_type) then return true end
    if checkBagsForLicences(inventory, licenca_type) then return true end
    if showText then getPlayer():setHaloNote("Voce nao tem a licenca para fazer isto!") end
    return false
end

function checkInventoryForLicences(inventory, licenca_type)
    local items = inventory:getItems()
    if (inventory:contains(licenca_type)) then
        for i = 0, items:size() - 1 do
            local it = items:get(i);
            local currentItem = string.gsub(it:getName(), "%s+", "")
            if it:getType() == licenca_type and string.contains(currentItem, getPlayer():getDisplayName()) then
                return true
            end
        end
    end
    return false
end

function checkBagsForLicences(inventory, licenca_type)
    local bags = inventory:getItemsFromCategory("Container")

    for i = 0, bags:size() - 1 do
        local it = bags:get(i);
        if (it:getItemContainer():contains(licenca_type)) then
            for j = 0, it:getItemContainer():getItems():size() - 1 do
                local bagItem = it:getItemContainer():getItems():get(j)
                local currentItem = string.gsub(bagItem:getName(), "%s+", "")
                if bagItem:getType() == licenca_type and string.contains(currentItem, getPlayer():getDisplayName()) then
                    return true
                end
            end
        end
    end

end

function ISSearchManager:checkShouldDisable()
    if (not HasLicencaCheck("LicencaColetor", true)) then return true; end
    if ISSearchManager.showDebug then return false; end
    local plStats = self.character:getStats();
    if plStats then
        if (plStats:getNumVeryCloseZombies() > 0) then return true; end
        if (plStats:getNumVisibleZombies() >= 3) and (plStats:getNumChasingZombies() >= 3) then return true; end
    end
    if (self.character:isRunning() or self.character:isSprinting() and self.character:isJustMoved()) then
        return true;
    end
    return false;
end

function ISSearchWindow:update()
    if (not HasLicencaCheck('LicencaColetor', true)) then self:removeFromUIManager(); return; end
    if (not self:getIsVisible()) then return; end
    if self.manager.isSearchMode then
        self.toggleSearchMode.title = getText("UI_disable_search_mode");
    else
        self.toggleSearchMode.title = getText("UI_enable_search_mode");
    end
    if ISSearchWindow.showDebug and self.manager.isSearchMode then
        local currentZone = self.manager.currentZone;
        if currentZone and currentZone.name then
            local title = "DEBUG: " .. currentZone.name;
            local itemsLeft = " - ICONS: (" .. currentZone.itemsLeft .. " / " .. currentZone.itemsTotal .. ")";
            self:setTitle(title .. itemsLeft);
        else
            self:setTitle("DEBUG: No Zone Here Or Zone Is Updating");
        end
    else
        self:setTitle(getText("UI_investigate_area_window_title"));
    end
    self:updateSearchFocusCategories();
end

function ISChopTreeAction:isValid()
    return self.tree ~= nil and self.tree:getObjectIndex() >= 0 and
        self.character:CanAttack() and
        self.character:getPrimaryHandItem() ~= nil and
        self.character:getPrimaryHandItem():getScriptItem():getCategories():contains("Axe") and
        HasLicencaCheck('LicencaCarpinteiro1', true)
end

function ISFishingAction:isValid()
    if (not HasLicencaCheck('LicencaCaca', true)) then return false end
    local actionQueue = ISTimedActionQueue.getTimedActionQueue(self.character)
    local lastAction = actionQueue.queue[#actionQueue.queue]
    if lastAction and (lastAction.Type ~= "ISFishingAction") then
        return false
    end

    if self.rod ~= self.character:getPrimaryHandItem() then return false end
    return self.lure == self.character:getSecondaryHandItem() or not self.lure;
end

function ISHarvestPlantAction:isValid()
    self.plant:updateFromIsoObject()
    return self.plant:getObject() and self.plant:canHarvest() and HasLicencaCheck('LicencaAgricultor', true)
end

function ISSeedAction:perform()
    if self.sound and self.sound ~= 0 then
        self.character:getEmitter():stopOrTriggerSound(self.sound)
    end

    for i = 1, self.nbOfSeed do
        local seed = self.seeds[i];
        self.character:getInventory():Remove(seed);
    end

    local sq = self.plant:getSquare()
    local args = { x = sq:getX(), y = sq:getY(), z = sq:getZ(), typeOfSeed = self.typeOfSeed }
    CFarmingSystem.instance:sendCommand(self.character, 'seed', args)

    if (HasLicencaCheck('LicencaAgricultor')) then getPlayer():getXp():AddXP(Perks.Farming, 5) else getPlayer():getXp()
            :AddXP(Perks.Farming, 0)
    end

    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self);
end

VehicleManager = {}
VehicleManager.OnSpawnVehicle = function(playerObj)
    local ui = ISSpawnVehicleUI:new(0, 0, 200, 300, playerObj);
    ui:initialise();
    ui:addToUIManager();
end

local function removeDuplicates(list)
    local result = {}
    local seen = {}
    for _, item in ipairs(list) do
        if not seen[item] then
            seen[item] = true
            table.insert(result, item)
        end
    end
    return result
end

function VehicleManager.OnMenuFillWorldObjectContextMenu(_player, _context, _worldobjects, _test)
    local square = nil;
    for i, v in ipairs(_worldobjects) do
        square = v:getSquare();
        break;
    end

    for i = 1, square:getObjects():size() do
        table.insert(_worldobjects, square:getObjects():get(i - 1))
    end
    _worldobjects = removeDuplicates(_worldobjects)
    local playerObj = getSpecificPlayer(_player)
    if (HasLicencaCheck('LicencaConcessionaria')) then
        local vehicleMenu = _context:addOption("Gerenciar Veiculos", nil, nil)
        local vehicleSubMenu = _context:getNew(_context)
        _context:addSubMenu(vehicleMenu, vehicleSubMenu)
        vehicleSubMenu:addOption('Criar Veiculo', playerObj, VehicleManager.OnSpawnVehicle)

        local vehicle = square:getVehicleContainer()
        if vehicle ~= nil then
            vehicleSubMenu:addOption("Remover Veiculo", playerObj, ISVehicleMechanics.onCheatRemove, vehicle);
        end
    end

end

Events.OnFillWorldObjectContextMenu.Add(VehicleManager.OnMenuFillWorldObjectContextMenu);
