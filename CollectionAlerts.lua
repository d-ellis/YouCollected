local collectionFrame = CreateFrame("Frame", "YouCollected_CollectionFrame", UIParent, "YouCollected_CollectionFrame")
collectionFrame:ClearAllPoints()
collectionFrame:Hide()
table.insert(UISpecialFrames, "YouCollected_CollectionFrame")

collectionFrame:RegisterForDrag("LeftButton")
collectionFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
collectionFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)
collectionFrame:SetScript("OnMouseDown", function(self, button)
    if button == "RightButton" then
        self:Hide()
    end
end)

---@param atlasName string
---@param xOffset ?integer
---@param yOffset ?integer
local function setBackgroundTextureAtlas(atlasName, xOffset, yOffset)
    collectionFrame.Background:SetAtlas(atlasName, true);
    xOffset = xOffset or 0;
    yOffset = yOffset or 0;
    collectionFrame.Background:SetPoint("CENTER", xOffset, yOffset);
end
---@param name string
---@param icon integer|string
---@param quality Enum.ItemQuality|nil
---@param isTransmog ?boolean
local function showAlert(name, icon, quality, isTransmog)
    local nameText = name;
    local colorData = ColorManager.GetColorDataForItemQuality(quality);
    if colorData then
        nameText = colorData.hex..name.."|r";
    end
    collectionFrame.ItemName:SetText(nameText);

    collectionFrame.Icon:SetTexture(icon);
    local atlasName = ColorManager.GetAtlasDataForLootBorderItemQuality(quality) or ColorManager.GetAtlasDataForLootBorderItemQuality(Enum.ItemQuality.Uncommon);
    collectionFrame.IconBorder:SetAtlas(atlasName);
    collectionFrame.CosmeticBorder:SetShown(isTransmog);

    collectionFrame:Show();
end

-- NewPetAlertSystem:AddAlert(petID)
---@param petID string
local function showPetAlert(petID)
    setBackgroundTextureAtlas("PetToast-background")
    local _,_,_,_,_,_,_,name,icon = C_PetJournal.GetPetInfoByPetID(petID)
    local _,_,_,_,rarity = C_PetJournal.GetPetStats(petID)
    -- Subtracting 1 from rarity as a crude map from pet rarity to item quality (rarity starts at 1, quality starts at 0)
    showAlert(name, icon, rarity - 1)
end
Menu.ModifyMenu("MENU_PET_COLLECTION_PET", function(owner, rootDescription)
    local petID = owner.petID or owner:GetParent().petID;
    if petID then
        rootDescription:CreateDivider();
        rootDescription:CreateButton("Show Collected Alert", showPetAlert, petID)
    end
end)

-- NewMountAlertSystem:AddAlert(mountID)
---@param mountID integer
local function showMountAlert(mountID)
    setBackgroundTextureAtlas("MountToast-Background")
    local _, spellId = C_MountJournal.GetMountInfoByID(mountID);
    local data = C_Spell.GetSpellInfo(spellId)
    -- Assuming here that mounts are always Epic quality as I can't find a counterexample
    showAlert(data.name, data.iconID, Enum.ItemQuality.Epic)
end
Menu.ModifyMenu("MENU_MOUNT_COLLECTION_MOUNT", function(owner, rootDescription)
    local mountID = owner.mountID or owner:GetParent().mountID
    if mountID then
        rootDescription:CreateDivider();
        rootDescription:CreateButton("Show Collected Alert", showMountAlert, mountID)
    end
end)

-- NewToyAlertSystem:AddAlert(toyID)
---@param toyID integer
local function showToyAlert(toyID)
    setBackgroundTextureAtlas("LootToast-MoreAwesome")
    local _,name,icon,_,_,quality = C_ToyBox.GetToyInfo(toyID);
    showAlert(name, icon, quality)
end
Menu.ModifyMenu("MENU_TOYBOX_FAVORITE", function(owner, rootDescription)
    local itemID = owner.itemID or owner:GetParent().itemID
    if itemID then
        rootDescription:CreateDivider();
        rootDescription:CreateButton("Show Collected Alert", showToyAlert, itemID)
    end
end)

-- NewCosmeticAlertFrameSystem:AddAlert(itemModifiedAppearanceID)
---@param sourceInfo AppearanceSourceInfo
local function showTransmogItemAlert(sourceInfo)
    setBackgroundTextureAtlas("CosmeticToast-Background")
    local icon = C_TransmogCollection.GetSourceIcon(sourceInfo.sourceID);
    showAlert(sourceInfo.name, icon, sourceInfo.quality, true);
end
Menu.ModifyMenu("MENU_WARDROBE_ITEMS_MODEL_FILTER", function(owner, rootDescription)
    local sourceInfo = owner:GetSourceInfoForTracking();
    if sourceInfo then
        rootDescription:CreateDivider();
        rootDescription:CreateButton("Show Collected Alert", showTransmogItemAlert, sourceInfo)
    end
end)

---@param setInfo TransmogSetInfo
local function showTransmogSetAlert(setInfo)
    setBackgroundTextureAtlas("CosmeticToast-Background");
    local icon = WardrobeSetsDataProviderMixin:GetIconForSet(setInfo.setID);
    showAlert(setInfo.name, icon, nil, true)
end
Menu.ModifyMenu("MENU_WARDROBE_SETS_SET", function(owner, rootDescription)
    local selectedSetID = WardrobeCollectionFrame.SetsCollectionFrame:GetDefaultSetIDForBaseSet(owner.setID);
    local setInfo = C_TransmogSets.GetSetInfo(selectedSetID);
    if (setInfo.collected) then
        local multipleVariants = #C_TransmogSets.GetVariantSets(owner.setID) > 0;
        local buttonName;
        if multipleVariants then
            buttonName = format("Show Collected Alert (%s)", setInfo.description);
        else
            buttonName = "Show Collected Alert";
        end
        rootDescription:CreateDivider();
        rootDescription:CreateButton(buttonName, showTransmogSetAlert, setInfo);
    end
end)
function PrintTableContents(table)
    for key,value in pairs(table) do print(key,value) end
end

-- NewWarbandSceneAlertSystem:AddAlert(warbandSceneID);
---@param sceneInfo WarbandSceneEntry
local function showCampsiteAlert(sceneInfo)
    setBackgroundTextureAtlas("loottoast-camp", 2, -3);
	local icon = "Interface\\ICONS\\UI_CampCollection";
    showAlert(sceneInfo.name, icon, sceneInfo.quality)
end
Menu.ModifyMenu("MENU_WARBANDSCENE_FAVORITE", function(owner, rootDescription)
    if owner:GetIsOwned() then
        rootDescription:CreateDivider();
        rootDescription:CreateButton("Show Collected Alert", showCampsiteAlert, owner.warbandSceneInfo)
    end
end)

function PrintTableContents(table)
    for key,value in pairs(table) do print(key,value) end
end
