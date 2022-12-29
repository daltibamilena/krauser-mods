function teleport(worldX, worldY)
    local inventory = getPlayer():getInventory()
    if inventory:contains("SheetPaper2") then
        local player = getSpecificPlayer(0)
        player:setX(worldX)
        player:setY(worldY)
        player:setLx(worldX)
        player:setLy(worldY)
        getTicket(inventory)
    end
end

function elevator(worldZ)
    local player = getSpecificPlayer(0)
    player:setZ(worldZ)
    player:setLz(worldZ)
end

function getTicket(inventory)
    local item = inventory:getItems()
    for i = 0, item:size() - 1 do
        local it = item:get(i);
        if it:getName() == "Bilhete" then
            inventory:Remove(it)
            break;
        end
    end
end

function payTicket(value)
    for i = 1, value do
        local item = InventoryItemFactory.CreateItem("Base.SheetPaper2")
        item:setName('Bilhete')
        getPlayer():getInventory():Remove("Money")
        getPlayer():getInventory():AddItem(item);
    end
end

local function TeleportMenu(_player, _context, _worldObjects, _object)
    local context = _context;
    local worldobjects = _worldObjects;
    for _, obj in ipairs(worldobjects) do
        if obj:getTextureName() == "pearl_objects_01_0" or obj:getTextureName() == "pearl_objects_01_1" then
            local TeleportContext = context:addOption("Ir para:", worldobjects);
            local subMenu = ISContextMenu:getNew(context);
            context:addSubMenu(TeleportContext, subMenu);
            subMenu:addOption("Hospital", worldobjects, function() teleport(937, 801) end);
            subMenu:addOption("Escola", worldobjects, function() teleport(808, 1098) end);
            subMenu:addOption("Prefeitura", worldobjects, function() teleport(692, 801) end);
            subMenu:addOption("Igreja", worldobjects, function() teleport(902, 973) end);
        end

        if obj:getTextureName() == "pearl_objects_01_2" or obj:getTextureName() == "pearl_objects_01_3" then
            local TicketContext = context:addOption("Bilhete", worldobjects);
            local subMenu = ISContextMenu:getNew(context);
            context:addSubMenu(TicketContext, subMenu);
            subMenu:addOption("Comprar 1", worldobjects, function() payTicket(1) end);
            subMenu:addOption("Comprar 5", worldobjects, function() payTicket(5) end);
            subMenu:addOption("Comprar 10", worldobjects, function() payTicket(10) end);
        end

        if obj:getTextureName() == "fixtures_escalators_01_48" or obj:getTextureName() == "fixtures_escalators_01_49" or
            obj:getTextureName() == "fixtures_escalators_01_50" or obj:getTextureName() == "fixtures_escalators_01_51" then
            local ElevatorContext = context:addOption("Usar elevador:", worldobjects);
            local subMenu = ISContextMenu:getNew(context);
            context:addSubMenu(ElevatorContext, subMenu);
            subMenu:addOption("Terreo", worldobjects, function() elevator(0) end);
            subMenu:addOption("Andar 1", worldobjects, function() elevator(1) end);
            subMenu:addOption("Andar 2", worldobjects, function() elevator(2) end);
            subMenu:addOption("Andar 3", worldobjects, function() elevator(3) end);
        end
    end

end

Events.OnFillWorldObjectContextMenu.Add(TeleportMenu);
