local mainFrame = CreateFrame("Frame", "YouCollected_AlertFrame", UIParent, "YouCollected_AlertFrame")
mainFrame:SetSize(512, 128)
mainFrame:ClearAllPoints()
mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
mainFrame:Hide()
table.insert(UISpecialFrames, "YouCollected_AlertFrame")

mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
mainFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)
mainFrame:SetScript("OnMouseDown", function(self, button)
    if button == "RightButton" then
        self:Hide()
    end
end)

local qualityReferences = {
    [Enum.ItemQuality.Poor] = {
        BorderAtlas = "loottoast-itemborder-gray",
        FontColour = ITEM_POOR_COLOR
    },
    [Enum.ItemQuality.Common] = {
        BorderAtlas = "loottoast-itemborder-white",
        FontColour = WHITE_FONT_COLOR -- COMMON_GRAY_COLOR doesn't look right, so substituting white here instead
    },
    [Enum.ItemQuality.Uncommon] = {
        BorderAtlas = "loottoast-itemborder-green",
        FontColour = UNCOMMON_GREEN_COLOR
    },
    [Enum.ItemQuality.Rare] = {
        BorderAtlas = "loottoast-itemborder-blue",
        FontColour = RARE_BLUE_COLOR
    },
    [Enum.ItemQuality.Epic] = {
        BorderAtlas = "loottoast-itemborder-purple",
        FontColour = EPIC_PURPLE_COLOR
    },
    [Enum.ItemQuality.Legendary] = {
        BorderAtlas = "loottoast-itemborder-orange",
        FontColour = LEGENDARY_ORANGE_COLOR
    },
    [Enum.ItemQuality.Artifact] = {
        BorderAtlas = "loottoast-itemborder-artifact",
        FontColour = ARTIFACT_GOLD_COLOR
    },
    [Enum.ItemQuality.Heirloom] = {
        BorderAtlas = "loottoast-itemborder-heirloom",
        FontColour = HEIRLOOM_BLUE_COLOR
    }
}

local function setBackgroundTextureAtlas(atlasName)
    mainFrame.Background:SetAtlas(atlasName, true)
end
local function showAlert(spellName, spellIcon, quality)
    mainFrame.ItemName:SetText(spellName)
    mainFrame.ItemIcon:SetTexture(spellIcon)
    local reference = qualityReferences[quality]
    mainFrame.ItemName:SetTextColor(reference.FontColour:GetRGBA())
    mainFrame.IconBorder:SetAtlas(reference.BorderAtlas, false)

    mainFrame:Show()
end

local function YouCollected_ShowPetAlert(petID)
    setBackgroundTextureAtlas("PetToast-background")
    local _,_,_,_,_,_,_,name,icon = C_PetJournal.GetPetInfoByPetID(petID)
    local _,_,_,_,rarity = C_PetJournal.GetPetStats(petID)
    -- Subtracting 1 from rarity as a crude map from pet rarity to item quality (rarity starts at 1, quality starts at 0)
    showAlert(name, icon, rarity - 1)
end
Menu.ModifyMenu("MENU_PET_COLLECTION_PET", function(owner, rootDescription, contextData)
    local petID = owner.petID or owner:GetParent().petID
    if petID then
        rootDescription:CreateDivider();
        rootDescription:CreateButton("Show Collected Alert", YouCollected_ShowPetAlert, petID)
    end
end)

local function YouCollected_ShowMountAlert(mountID)
    setBackgroundTextureAtlas("MountToast-Background")
    local _, spellId = C_MountJournal.GetMountInfoByID(mountID);
    local data = C_Spell.GetSpellInfo(spellId)
    -- Assuming here that mounts are always Epic quality as I can't find a counterexample
    showAlert(data.name, data.iconID, Enum.ItemQuality.Epic)
end
Menu.ModifyMenu("MENU_MOUNT_COLLECTION_MOUNT", function(owner, rootDescription, contextData)
    local mountID = owner.mountID or owner:GetParent().mountID
    if mountID then
        rootDescription:CreateDivider();
        rootDescription:CreateButton("Show Collected Alert", YouCollected_ShowMountAlert, mountID)
    end
end)

local function YouCollected_ShowToyAlert(toyID)
    setBackgroundTextureAtlas("LootToast-MoreAwesome")
    local _,name,icon,_,_,quality = C_ToyBox.GetToyInfo(toyID);
    showAlert(name, icon, quality)
end
Menu.ModifyMenu("MENU_TOYBOX_FAVORITE", function(owner, rootDescription, contextData)
    local itemID = owner.itemID or owner:GetParent().itemID
    if itemID then
        rootDescription:CreateDivider();
        rootDescription:CreateButton("Show Collected Alert", YouCollected_ShowToyAlert, itemID)
    end
end)

local function YouCollected_ShowTransmogItemAlert(sourceInfo)
    setBackgroundTextureAtlas("CosmeticToast-Background")
    local icon = C_TransmogCollection.GetSourceIcon(sourceInfo.sourceID);
    showAlert(sourceInfo.name, icon, sourceInfo.quality);
end
Menu.ModifyMenu("MENU_WARDROBE_ITEMS_MODEL_FILTER", function(owner, rootDescription, contextData)
    local sourceInfo = owner:GetSourceInfoForTracking();
    if sourceInfo then
        rootDescription:CreateDivider();
        rootDescription:CreateButton("Show Collected Alert", YouCollected_ShowTransmogItemAlert, sourceInfo)
    end
end)

-- TODO - How can we distinguish between the currently selected variant and the base set?
-- It must be possible as the "Set Favorite" item is variable, but I can't find the information I need yet

-- Menu.ModifyMenu("MENU_WARDROBE_SETS_SET", function(owner, rootDescription, contextData)
--     print('OWNER:', owner)
--     for key,value in pairs(owner) do
--         print(key, value)
--     end
--     print('\n');
--     -- print('owner:GetData()');
--     -- for key,value in pairs(owner:GetData()) do
--     --     print(key, value)
--     -- end
--     -- print('\n');
--     -- print('C_TransmogSets.GetVariantSets()');
--     -- for _,variantSet in pairs(C_TransmogSets.GetVariantSets(owner:GetData().setID)) do
--     --     for key,value in pairs(variantSet) do
--     --         print(key,value)
--     --     end
--     --     print('\n')
--     -- end
--     -- print('\n')
-- end)