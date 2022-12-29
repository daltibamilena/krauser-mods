DrugCreator = {}

---@return DrugCreator
function DrugCreator:new()
    ---@class DrugCreator
    local public = {}
    local private = {}

    ---@type DrugStorage
    private.drugStorage = ZCore:getContainer():get('imeds.drug.storage.drug_storage')

    ---@param fullType string
    ---@return Drug
    function public:createByFullType(fullType)
        local drug = InventoryItemFactory.CreateItem(fullType)
        local drugData = private.drugStorage:getByFullType(fullType)

        drug:getModData().drug = {
            fullType = drugData:getFullType(),
            dosageForms = drugData:getDosageForms(),
            singleDose = drugData:getSingleDose(),
        }

        return drug
    end

    setmetatable(public, self)
    self.__index = self
    self.__metatable = 'DrugCreator'

    return public
end

return DrugCreator