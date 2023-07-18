#include "inc_treasure"
#include "nwnx_admin"
#include "nwnx_item"
#include "nwnx_util"
#include "inc_craft"


int GetIsItemConsumableMisc(object oItem)
{
    int nBaseItem = GetBaseItemType(oItem);
    if (nBaseItem == BASE_ITEM_HEALERSKIT || nBaseItem == BASE_ITEM_THIEVESTOOLS)
    {
        return 1;
    }
    itemproperty ipTest = GetFirstItemProperty(oItem);
    while (GetIsItemPropertyValid(ipTest))
    {
        int nType = GetItemPropertyType(ipTest);
        if (nType == ITEM_PROPERTY_CAST_SPELL)
        {
            int nNumUsesConst = GetItemPropertyCostTableValue(ipTest);
            if (nNumUsesConst == IP_CONST_CASTSPELL_NUMUSES_SINGLE_USE ||
                nNumUsesConst == IP_CONST_CASTSPELL_NUMUSES_1_CHARGE_PER_USE ||
                nNumUsesConst == IP_CONST_CASTSPELL_NUMUSES_2_CHARGES_PER_USE ||
                nNumUsesConst == IP_CONST_CASTSPELL_NUMUSES_3_CHARGES_PER_USE ||
                nNumUsesConst == IP_CONST_CASTSPELL_NUMUSES_4_CHARGES_PER_USE ||
                nNumUsesConst == IP_CONST_CASTSPELL_NUMUSES_5_CHARGES_PER_USE)
            {
                return 1;
            }
        }
        ipTest = GetNextItemProperty(oItem);
    }
    return 0;
}

void CreateFabricator(object oAmmo, object oTargetChest)
{
            if (!GetIsObjectValid(oAmmo))
                return;

            SetIdentified(oAmmo, TRUE);

            object oFabricator = CreateItemOnObject("ammo_maker", oTargetChest);
            SetTag(oAmmo, "ammo_"+GetName(oAmmo));
            SetLocalString(oFabricator, "ammo_tag", GetTag(oAmmo));

            int nValue = GetGoldPieceValue(oAmmo);
            string sAmmoName;
            int nAppearance, nStack;
            switch (GetBaseItemType(oAmmo))
            {
                case BASE_ITEM_THROWINGAXE: sAmmoName = "Throwing Axe"; nAppearance = 20; break;
                case BASE_ITEM_DART: sAmmoName = "Dart"; nAppearance = 7; break;
                case BASE_ITEM_SHURIKEN: sAmmoName = "Shuriken"; nAppearance = 9;; break;
                case BASE_ITEM_ARROW: sAmmoName = "Arrow"; nAppearance = 19; break;
                case BASE_ITEM_BULLET: sAmmoName = "Bullet"; nAppearance = 18; break;
                case BASE_ITEM_BOLT: sAmmoName = "Bolt"; nAppearance = 8; break;
            }

            // set the stack size to 50 for similar cost eval to throwing weapons
            SetItemStackSize(oAmmo, 50);

            SetTag(oAmmo, GetTag(oAmmo));
            object oNewAmmo = CopyItemToExistingTarget(oAmmo, GetObjectByTag("_FabricatorAmmo"));

            NWNX_Item_SetAddGoldPieceValue(oFabricator, nValue);

            NWNX_Item_SetItemAppearance(oFabricator, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, nAppearance);
            SetName(oFabricator, sAmmoName+" Fabricator ("+GetName(oAmmo)+")");
}

object ChangeSpecialWeapon(object oItem, int nTopModel, int nTopColor)
{
     int nBaseType = GetBaseItemType(oItem);

     string sSimpleModel, sSimpleColor, sCombinedModel;

     sSimpleModel = IntToString(nTopModel);
     sSimpleColor = IntToString(nTopColor);

     if (sSimpleModel == "0") sSimpleModel = "1";
     if (sSimpleColor == "0") sSimpleColor = "1";

// Fix for out of bounds number for these item types.
     if ((nBaseType == BASE_ITEM_DART || nBaseType == BASE_ITEM_SHURIKEN) && sSimpleColor == "4") sSimpleColor = "1";

     sCombinedModel = sSimpleModel+sSimpleColor;
     object oRet = CopyItemAndModify(oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, StringToInt(sCombinedModel), TRUE);
     DestroyObject(oItem);

     return oRet;
}

object DyeWeaponColor(object oItem, int nColorType, int nColor)
{
        int nBaseType = GetBaseItemType(oItem);

        object oRet;
        if (nBaseType != BASE_ITEM_WHIP) // Whips do not have alternative colors
        {
          oRet = CopyItemAndModify(oItem,ITEM_APPR_TYPE_WEAPON_COLOR,nColorType,nColor,TRUE);
          DestroyObject(oItem); // remove old item
        }
        else
        {
          oRet = oItem;
        }
        return oRet; //return new item
}

object ChangeWeaponModel(object oItem, int nModelType, int nModel)
{
        int nBaseType = GetBaseItemType(oItem);
        object oRet;
        int nSelectedModel = nModel;

        switch (nBaseType)
        {
            // These items do not have any other model, so do not change them.
            case BASE_ITEM_WHIP:
            case BASE_ITEM_KUKRI:
            case BASE_ITEM_SICKLE:
            case BASE_ITEM_KAMA:
            {
               oRet = oItem;
               break;
            }
            case BASE_ITEM_DWARVENWARAXE:
            {
               // up to 8 tops, only 6 other parts... which are shared with battleaxes
               // but doing this to everything pushes them out of range and it goes invalid
               if (nModelType == ITEM_APPR_WEAPON_MODEL_TOP)
               {
                   nSelectedModel = nModel + 5;
                   if (nSelectedModel > 8)
                       nSelectedModel = 8;
               }

               oRet = CopyItemAndModify(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, nModelType, nSelectedModel, TRUE);
               DestroyObject(oItem); // remove old item
               break;
            }
            default:
            {
               oRet = CopyItemAndModify(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, nModelType, nModel, TRUE);
               DestroyObject(oItem); // remove old item
               break;
            }
        }
        return oRet; //return new item
}


//
// ------------------------------------------
// This is the function that will populate a
// a melee or range loot chest. Should not be
// used with other item types!
// ------------------------------------------
//

void PopulateChestWeapon(string sSeedChestTag, string sPrependName, string sAppendName, string sAppendTag, string sDescription, int nTopModel, int nMiddleModel, int nBottomModel, int nTopColor, int nMiddleColor, int nBottomColor, itemproperty ipProp1, itemproperty ipProp2, itemproperty ipProp3, int nPhysicalBonus=0, int bNonUnique = FALSE)
{
   object oSeedChest = GetObjectByTag(sSeedChestTag);
   object oItem = GetFirstItemInInventory(oSeedChest);
   object oNewItem;
   object oNewItemStaging;
   string sOldName;

   location lStaging = GetTreasureStagingLocation();
   object oDistribution = GetObjectByTag(TREASURE_DISTRIBUTION);

// if it matches this item prop, skip it
   itemproperty ipInvalidItemProp = ItemPropertyNoDamage();

   while (GetIsObjectValid(oItem))
   {
// Get the current name of the item ex: "Longsword"
       sOldName = GetName(oItem);

// Copy the item, but for now put it in a modding area
       oNewItemStaging = CopyObject(oItem, lStaging);

// Modify the appearance. If 0, leave unchanged.
       int nBaseType = GetBaseItemType(oNewItemStaging);

// For slings, darts, and shurikens, do something special for them for appearance changing (simple model).
       if (nBaseType == BASE_ITEM_SLING || nBaseType == BASE_ITEM_DART || nBaseType == BASE_ITEM_SHURIKEN)
       {
           oNewItemStaging = ChangeSpecialWeapon(oNewItemStaging, nTopModel, nTopColor);
       }
       else
       {
           if (nTopModel != 0) oNewItemStaging = ChangeWeaponModel(oNewItemStaging, ITEM_APPR_WEAPON_MODEL_TOP, nTopModel);
           if (nMiddleModel != 0) oNewItemStaging = ChangeWeaponModel(oNewItemStaging, ITEM_APPR_WEAPON_MODEL_MIDDLE, nMiddleModel);
           if (nBottomModel != 0) oNewItemStaging = ChangeWeaponModel(oNewItemStaging, ITEM_APPR_WEAPON_MODEL_BOTTOM, nBottomModel);

// Do the same for colors.
           if (nTopColor != 0) oNewItemStaging = DyeWeaponColor(oNewItemStaging, ITEM_APPR_WEAPON_COLOR_TOP, nTopColor);
           if (nMiddleColor != 0) oNewItemStaging = DyeWeaponColor(oNewItemStaging, ITEM_APPR_WEAPON_COLOR_MIDDLE, nMiddleColor);
           if (nBottomColor != 0) oNewItemStaging = DyeWeaponColor(oNewItemStaging, ITEM_APPR_WEAPON_COLOR_BOTTOM, nBottomColor);
       }

// Add item property, if the arg is there.
       if (GetItemPropertyType(ipProp1) != GetItemPropertyType(ipInvalidItemProp)) AddItemProperty(DURATION_TYPE_PERMANENT, ipProp1, oNewItemStaging);
       if (GetItemPropertyType(ipProp2) != GetItemPropertyType(ipInvalidItemProp)) AddItemProperty(DURATION_TYPE_PERMANENT, ipProp2, oNewItemStaging);
       if (GetItemPropertyType(ipProp3) != GetItemPropertyType(ipInvalidItemProp)) AddItemProperty(DURATION_TYPE_PERMANENT, ipProp3, oNewItemStaging);

// Add a physical damage bonus IP if there is one. It's special because it depends on the physical dmg type.
       if (nPhysicalBonus > 0)
       {
           itemproperty ipPhysicalBonus;

// of course, these weapons don't add physical damage but instead use mighty
           switch (nBaseType)
           {
               case BASE_ITEM_LONGBOW:
               case BASE_ITEM_SHORTBOW:
               case BASE_ITEM_HEAVYCROSSBOW:
               case BASE_ITEM_LIGHTCROSSBOW:
               case BASE_ITEM_SLING:
               {
                 ipPhysicalBonus = ItemPropertyMaxRangeStrengthMod(nPhysicalBonus);
                 break;
               }
               case BASE_ITEM_MORNINGSTAR:
               case BASE_ITEM_CLUB:
               case BASE_ITEM_LIGHTMACE:
               case BASE_ITEM_LIGHTHAMMER:
               case BASE_ITEM_LIGHTFLAIL:
               case BASE_ITEM_DIREMACE:
               case BASE_ITEM_HEAVYFLAIL:
               case BASE_ITEM_QUARTERSTAFF:
               case BASE_ITEM_WARHAMMER:
               {
                  ipPhysicalBonus = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_BLUDGEONING, nPhysicalBonus);
                  break;
               }
               case BASE_ITEM_KUKRI:
               case BASE_ITEM_SICKLE:
               case BASE_ITEM_KAMA:
               case BASE_ITEM_KATANA:
               case BASE_ITEM_BATTLEAXE:
               case BASE_ITEM_BASTARDSWORD:
               case BASE_ITEM_HANDAXE:
               case BASE_ITEM_WHIP:
               case BASE_ITEM_SCIMITAR:
               case BASE_ITEM_SCYTHE:
               case BASE_ITEM_HALBERD:
               case BASE_ITEM_DOUBLEAXE:
               case BASE_ITEM_DWARVENWARAXE:
               case BASE_ITEM_LONGSWORD:
               case BASE_ITEM_GREATAXE:
               case BASE_ITEM_GREATSWORD:
               case BASE_ITEM_TWOBLADEDSWORD:
               case BASE_ITEM_THROWINGAXE:
               {
                  ipPhysicalBonus = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_SLASHING, nPhysicalBonus);
                  break;
               }
               case BASE_ITEM_DAGGER:
               case BASE_ITEM_SHORTSWORD:
               case BASE_ITEM_RAPIER:
               case BASE_ITEM_SHORTSPEAR:
               case BASE_ITEM_TRIDENT:
               case BASE_ITEM_DART:
               case BASE_ITEM_SHURIKEN:
               {
                  ipPhysicalBonus = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_PIERCING, nPhysicalBonus);
                  break;
               }
           }

           AddItemProperty(DURATION_TYPE_PERMANENT, ipPhysicalBonus, oNewItemStaging);
       }

       SetDescription(oNewItemStaging, sDescription);

       SetIdentified(oNewItemStaging, FALSE);
       SetName(oNewItemStaging, sPrependName+sOldName+sAppendName); // set given name
       SetTag(oNewItemStaging, GetTag(oNewItemStaging) + sAppendTag);

// physical bonus? not considered magical so identify
// this is the only case for composite or high quality items
       if (nPhysicalBonus > 0) SetIdentified(oNewItemStaging, TRUE);

// Set the stack size so the distribution script works correctly
       switch (GetBaseItemType(oNewItemStaging))
       {
           case BASE_ITEM_ARROW:
           case BASE_ITEM_BOLT:
           case BASE_ITEM_BULLET:
                SetItemStackSize(oNewItem, 99);
           break;
           case BASE_ITEM_DART:
           case BASE_ITEM_THROWINGAXE:
           case BASE_ITEM_SHURIKEN:
                SetItemStackSize(oNewItem, 50);
           break;
       }

       if (bNonUnique) SetLocalInt(oNewItemStaging, "non_unique", 1);

// these types of items will always be identified
       if (nPhysicalBonus > 0) SetLocalInt(oNewItemStaging, "identified", 1);

       oNewItem = CopyItemToExistingTarget(oNewItemStaging, oDistribution);
       DestroyObject(oNewItemStaging);
       if (!GetIsObjectValid(oNewItem))
       {
            WriteTimestampedLogEntry("ERROR: PopulateChestWeapon failed to make an item (" + sPrependName + sAppendName + ") derived from " + GetName(oItem));
       }

       oItem = GetNextItemInInventory(oSeedChest);
   }

}

void PopulateChestArmor(string sSeedChestTag, string sPrependName, string sAppendName, string sAppendTag, string sDescription, int nCloth1, int nCloth2, int nLeather1, int nLeather2, int nMetal1, int nMetal2, int nShoulder, int nForeArm, itemproperty ipProp1, itemproperty ipProp2, itemproperty ipProp3, int bNonUnique = FALSE)
{

   object oSeedChest = GetObjectByTag(sSeedChestTag);
   object oItem = GetFirstItemInInventory(oSeedChest);
   object oNewItem;
   object oNewItemStaging;
   string sOldName;

   location lStaging = GetTreasureStagingLocation();
   object oDistribution = GetObjectByTag(TREASURE_DISTRIBUTION);

   itemproperty ipInvalidItemProp = ItemPropertyNoDamage(); // if it matches this item prop, skip it

   while (GetIsObjectValid(oItem))
   {
// Get the current name of the item ex: "Leather Armor"
       sOldName = GetName(oItem);

// Copy the item, but for now put it in a modding area.
       oNewItemStaging = CopyObject(oItem, lStaging);

// Modify the appearance. If 0, leave unchanged.
       if (nCloth1 != 0) oNewItemStaging = IPDyeArmor(oNewItemStaging, ITEM_APPR_ARMOR_COLOR_CLOTH1, nCloth1);
       if (nCloth2 != 0) oNewItemStaging = IPDyeArmor(oNewItemStaging, ITEM_APPR_ARMOR_COLOR_CLOTH2, nCloth2);
       if (nLeather1 != 0) oNewItemStaging = IPDyeArmor(oNewItemStaging, ITEM_APPR_ARMOR_COLOR_LEATHER1, nLeather1);
       if (nLeather2 != 0) oNewItemStaging = IPDyeArmor(oNewItemStaging, ITEM_APPR_ARMOR_COLOR_LEATHER2, nLeather2);
       if (nMetal1 != 0) oNewItemStaging = IPDyeArmor(oNewItemStaging, ITEM_APPR_ARMOR_COLOR_METAL1, nMetal1);
       if (nMetal2 != 0) oNewItemStaging = IPDyeArmor(oNewItemStaging, ITEM_APPR_ARMOR_COLOR_METAL2, nMetal2);

// Add item property, if the arg is there.
       if (GetItemPropertyType(ipProp1) != GetItemPropertyType(ipInvalidItemProp)) AddItemProperty(DURATION_TYPE_PERMANENT, ipProp1, oNewItemStaging);
       if (GetItemPropertyType(ipProp2) != GetItemPropertyType(ipInvalidItemProp)) AddItemProperty(DURATION_TYPE_PERMANENT, ipProp2, oNewItemStaging);
       if (GetItemPropertyType(ipProp3) != GetItemPropertyType(ipInvalidItemProp)) AddItemProperty(DURATION_TYPE_PERMANENT, ipProp3, oNewItemStaging);

       SetDescription(oNewItemStaging, sDescription);
       SetName(oNewItemStaging, sPrependName+sOldName+sAppendName);
       SetTag(oNewItemStaging, GetTag(oNewItemStaging) + sAppendTag);

       if (bNonUnique) SetLocalInt(oNewItemStaging, "non_unique", 1);

       oNewItem = CopyItemToExistingTarget(oNewItemStaging, oDistribution);
       if (!GetIsObjectValid(oNewItem))
       {
            WriteTimestampedLogEntry("ERROR: PopulateChestArmor failed to make an item (" + sPrependName + sAppendName + ") derived from " + GetName(oItem));
       }
       DestroyObject(oNewItemStaging);

       oItem = GetNextItemInInventory(oSeedChest);
   }

}

void CopySeedContainerToDistribution(object oContainer)
{
    object oItem = GetFirstItemInInventory(oContainer);
    object oNewItem;

    while (GetIsObjectValid(oItem))
    {
        oNewItem = CopyItemToExistingTarget(oItem, GetObjectByTag(TREASURE_DISTRIBUTION));
        SetLocalInt(oNewItem, "non_unique", 1);
        SetLocalInt(oNewItem, "identified", 1);
        oItem = GetNextItemInInventory(oContainer);
    }
}

object CreateTreasureContainer(string sTag, float x = 1.0, float y = 1.0, float z = 1.0)
{
    object oContainer = CreateObject(OBJECT_TYPE_PLACEABLE, "_treas_container", Location(GetObjectByTag("_TREASURE"), Vector(x, y, z), 0.0), FALSE, sTag);
    SetName(oContainer, sTag);
    return oContainer;
}

// this function is used to pull items from the palette
void CreateTypeLoot(string sType)
{
    int nIndex;
    object oItem, oNewItem;
    object oDistribution = GetObjectByTag(TREASURE_DISTRIBUTION);
    location lStaging = GetTreasureStagingLocation();

    for (nIndex = 1; nIndex < 500; nIndex++)
    {
       oItem = CreateObject(OBJECT_TYPE_ITEM, sType+IntToString(nIndex), lStaging);
       // Force unique tags if they have a nw_ prefixed one
       // This is to avoid the item getting merged into something else with the same tag and infinite stock
       // when copied into a store - see lexicon CopyItem
       if (GetStringLeft(GetTag(oItem), 3) == "nw_")
       {
           //WriteTimestampedLogEntry("Change tag for " + GetName(oItem) + " from nw_ prefix");
           SetTag(oItem, GetResRef(oItem));
       }
       oNewItem = CopyItem(oItem, oDistribution, TRUE);

       if (GetIdentified(oItem)) SetLocalInt(oNewItem, "identified", 1);

       switch (GetBaseItemType(oNewItem))
       {
           case BASE_ITEM_ARROW:
           case BASE_ITEM_BOLT:
           case BASE_ITEM_BULLET:
                SetItemStackSize(oNewItem, 99);
           break;
           case BASE_ITEM_DART:
           case BASE_ITEM_THROWINGAXE:
           case BASE_ITEM_SHURIKEN:
                SetItemStackSize(oNewItem, 50);
           break;
       }
       DestroyObject(oItem);
    }
}


void CreateStagingScroll(string sResRef)
{
   object oItem = CreateItemOnObject(sResRef, GetObjectByTag(TREASURE_DISTRIBUTION));
   string sName = GetName(oItem);

   SetName(oItem, "Scroll of " + sName);
   SetIdentified(oItem, TRUE);
}

void DistributeTreasureToStores(object oItem)
{
   //WriteTimestampedLogEntry("Distribute: " + GetName(oItem));
   object oContainer = GetObjectByTag(TREASURE_DISTRIBUTION);
   object oNewItem;
   string sTier, sType, sName, sResRef, sRarity, sNonUnique;
   int nBaseArmorAC, nBaseType, nValue, nEnchantValue;

   int nIdentified = GetLocalInt(oItem, "identified"); // Store the identified state for use later.

   SetIdentified(oItem, TRUE); // Need to identify them for now so we get the proper gold value.

   sResRef = GetResRef(oItem);
   nBaseType = GetBaseItemType(oItem);
   nEnchantValue = GetEnchantValue(oItem);
   sName = GetName(oItem);

    // set the item's charges to 50 for gold evaluation purposes, store the charges so we can change it back later
    int nCharges = 0;
    if (nBaseType == BASE_ITEM_MAGICWAND || nBaseType == BASE_ITEM_MAGICROD)
    {
        nCharges = GetItemCharges(oItem);
        SetItemCharges(oItem, 50);
    }

   int nCount = GetLocalInt(oContainer, "count");
   nCount = nCount + 1;
   SetLocalInt(oContainer, "count", nCount);
   //SendDebugMessage("distributed "+IntToString(nCount)+" "+sName);

   if (GetTag(oItem) == "non_unique") sNonUnique = "NonUnique";
   if (GetLocalInt(oItem, "non_unique") == 1) sNonUnique = "NonUnique";

   if (GetBaseItemType(oItem) == BASE_ITEM_ARMOR)
   {
       nBaseArmorAC = GetBaseArmorAC(oItem);
   }
   else
   {
       nBaseArmorAC = 0;
   }

// Apply the enchanted weight reduction and value modifier based on AC.
   InitializeItem(oItem);

    // it's possible that the item was destroyed because it was zero cost. Do nothing in that case
   if (!GetIsObjectValid(oItem))
   {
       return;
   }

// only get gold value after the weight reduction
   nValue = GetGoldPieceValue(oItem);

   switch (nBaseType)
   {
       case BASE_ITEM_SPELLSCROLL:
       case BASE_ITEM_GEM:
       case BASE_ITEM_POTIONS:
          nIdentified = 1;
       break;
   }

// Enchanted full plate mail is considered 1 tier higher.
       if (nEnchantValue > 0 && nBaseArmorAC == 8) nEnchantValue++;

// Raise an error if there is an item that exceeded the maximum value.
       if (nValue > 22000)
       {
           CopyItemToExistingTarget(oItem, GetObjectByTag("_overvalue"));
           WriteTimestampedLogEntry("Overvalued Item (" + IntToString(nValue) + "): " + GetName(oItem) + ", resref=" + GetResRef(oItem));
           DestroyObject(oItem);
           return;
       }
       
       int nTier = GetItemTier(oItem);
       sTier = "T" + IntToString(nTier);


       if (GetStringLeft(sResRef, 4) == "misc") {sType = "Misc";}
       else if (nBaseType == BASE_ITEM_SPELLSCROLL) {sType = "Scrolls";}
       else if (GetStringLeft(sResRef, 7) == "apparel")
       {
          sType = "Apparel";
          switch (nBaseType)
          {
               case BASE_ITEM_BELT:
               case BASE_ITEM_BOOTS:
               case BASE_ITEM_BRACER:
               case BASE_ITEM_CLOAK:
               case BASE_ITEM_GLOVES:
                  sRarity = "Common";
               break;
               case BASE_ITEM_RING:
                  sRarity = "Uncommon";
               break;
               case BASE_ITEM_AMULET:
                  sRarity = "Rare";
               break;
           }
       }
// all armors, including shields and helmets
       else if (nBaseType == BASE_ITEM_HELMET || nBaseType == BASE_ITEM_ARMOR || nBaseType == BASE_ITEM_TOWERSHIELD || nBaseType == BASE_ITEM_LARGESHIELD || nBaseType == BASE_ITEM_SMALLSHIELD)
       {
          sType = "Armor";

           switch (nBaseType)
           {
             case BASE_ITEM_ARMOR:
                  switch (nBaseArmorAC)
                  {
                     case 1:
                     case 2:
                         sRarity = "Common";
                     break;
                     case 3:
                     case 4:
                     case 5:
                         sRarity = "Uncommon";
                     break;
                     case 0:
                     case 6:
                     case 7:
                     case 8:
                         sRarity = "Rare";
                     break;
                   }
             break;
             case BASE_ITEM_SMALLSHIELD:
             case BASE_ITEM_HELMET:
                  sRarity = "Common";
             break;
             case BASE_ITEM_LARGESHIELD:
                  sRarity = "Uncommon";
             break;
             case BASE_ITEM_TOWERSHIELD:
                  sRarity = "Rare";
             break;
           }

         }
         else if (GetStringLeft(sResRef, 6) == "weapon" || GetMeleeWeapon(oItem) || GetWeaponRanged(oItem) || nBaseType == BASE_ITEM_ARROW || nBaseType == BASE_ITEM_BULLET || nBaseType == BASE_ITEM_BOLT)
         {
            sType = "Melee";

            if (GetWeaponRanged(oItem) || nBaseType == BASE_ITEM_ARROW || nBaseType == BASE_ITEM_BULLET || nBaseType == BASE_ITEM_BOLT) sType = "Range";

            switch (nBaseType)
            {
               case BASE_ITEM_BASTARDSWORD:
               case BASE_ITEM_BATTLEAXE:
               case BASE_ITEM_CLUB:
               case BASE_ITEM_DAGGER:
               case BASE_ITEM_LONGSWORD:
               case BASE_ITEM_SHORTSWORD:
               case BASE_ITEM_WARHAMMER:
               case BASE_ITEM_LIGHTMACE:
               case BASE_ITEM_HANDAXE:
               case BASE_ITEM_QUARTERSTAFF:
               case BASE_ITEM_LONGBOW:
               case BASE_ITEM_SHORTBOW:
               case BASE_ITEM_THROWINGAXE:
               case BASE_ITEM_ARROW:
                  sRarity = "Common";
               break;
               case BASE_ITEM_GLOVES:
               case BASE_ITEM_LIGHTFLAIL:
               case BASE_ITEM_LIGHTHAMMER:
               case BASE_ITEM_HALBERD:
               case BASE_ITEM_SHORTSPEAR:
               case BASE_ITEM_GREATSWORD:
               case BASE_ITEM_GREATAXE:
               case BASE_ITEM_HEAVYFLAIL:
               case BASE_ITEM_DWARVENWARAXE:
               case BASE_ITEM_MORNINGSTAR:
               case BASE_ITEM_HEAVYCROSSBOW:
               case BASE_ITEM_LIGHTCROSSBOW:
               case BASE_ITEM_DART:
               case BASE_ITEM_BOLT:
                  sRarity = "Uncommon";
               break;
               case BASE_ITEM_DIREMACE:
               case BASE_ITEM_DOUBLEAXE:
               case BASE_ITEM_RAPIER:
               case BASE_ITEM_SCIMITAR:
               case BASE_ITEM_KATANA:
               case BASE_ITEM_KAMA:
               case BASE_ITEM_SCYTHE:
               case BASE_ITEM_TWOBLADEDSWORD:
               case BASE_ITEM_WHIP:
               case BASE_ITEM_TRIDENT:
               case BASE_ITEM_KUKRI:
               case BASE_ITEM_SICKLE:
               case BASE_ITEM_MAGICROD:
               case BASE_ITEM_MAGICSTAFF:
               case BASE_ITEM_MAGICWAND:
               case BASE_ITEM_SLING:
               case BASE_ITEM_SHURIKEN:
               case BASE_ITEM_BULLET:
                  sRarity = "Rare";
               break;
             }
          }
        
        if (sType == "Misc" && GetIsItemConsumableMisc(oItem))
        {
            sType = "MiscCons";
        }

        if (nCharges > 0)
        {
            SetItemCharges(oItem, nCharges);
        }
          
        SendDebugMessage(GetName(oItem) + "-> _"+sType+sRarity+sTier+sNonUnique);

        // Turn these into ammo makers.
        if (GetIsItemPropertyValid(GetFirstItemProperty(oItem)) && (nBaseType == BASE_ITEM_THROWINGAXE || nBaseType == BASE_ITEM_DART || nBaseType == BASE_ITEM_SHURIKEN || nBaseType == BASE_ITEM_ARROW || nBaseType == BASE_ITEM_BULLET || nBaseType == BASE_ITEM_BOLT))
        {
            if (!GetItemHasItemProperty(oItem, ITEM_PROPERTY_BOOMERANG))
            {
                CreateFabricator(oItem, GetObjectByTag("_"+sType+sRarity+sTier+sNonUnique));
                SetTag(oItem, "crafted_ammo");
                SetPlotFlag(oItem, TRUE);
            }
        }

        oNewItem = CopyItemToExistingTarget(oItem, GetObjectByTag("_"+sType+sRarity+sTier+sNonUnique));

        if (nIdentified != 1) SetIdentified(oNewItem, FALSE);

        DestroyObject(oItem);
}

void CountItemsThroughTiers()
{
    int nItems;
    object oItem;

    object oArea = GetObjectByTag("_TREASURE");
    object oContainer = GetFirstObjectInArea(oArea);

    while (GetIsObjectValid(oContainer))
    {
        if (GetHasInventory(oContainer) && (GetObjectType(oContainer) == OBJECT_TYPE_PLACEABLE))
        {
            nItems = 0;
            oItem = GetFirstItemInInventory(oContainer);
            while (GetIsObjectValid(oItem) == TRUE)
            {
                nItems = nItems + 1;

                if (GetName(oContainer) != "_FabricatorAmmo")
                    SetItemStackSize(oItem, 1);

                oItem = GetNextItemInInventory(oContainer);
            }

            if (nItems == 0)
            {
                DestroyObject(oContainer);
            }
            else
            {
                SetLocalInt(oContainer, "item_count", nItems);
                SetDescription(oContainer, IntToString(nItems));
                SetName(oContainer, GetName(oContainer)+" - Count:"+IntToString(nItems));

                if (StoreCampaignObject("treasures", GetTag(oContainer), oContainer) == 0)
                {
                    SendDebugMessage("Aborting, failed to store "+GetTag(oContainer), TRUE);
                    NWNX_Administration_ShutdownServer();
                    break;
                }
            }
        }

        oContainer = GetNextObjectInArea(oArea);
    }
}

void CreateContainersForItemTypesByTier()
{
    int nBaseItem;
    int nUnique;
    for (nUnique=0; nUnique <= 1; nUnique++)
    {
        string sUniqueness = nUnique ? "NonUnique" : "";
        int nTier;
        for (nTier=1; nTier<=5; nTier++)
        {
            int nNumItems = 0;
            int nContainerType;
            for (nContainerType=0; nContainerType<=4; nContainerType++)
            {
                string sContainerTypeName;
                switch (nContainerType)
                {
                    case 0: { sContainerTypeName = "Armor"; break; }
                    case 1: { sContainerTypeName = "Range"; break; }
                    case 2: { sContainerTypeName = "Melee"; break; }
                    case 3: { sContainerTypeName = "Apparel"; break; }
                    case 4: { sContainerTypeName = "Scrolls"; break; }
                }
                int nRarity;
                for (nRarity=0; nRarity<=2; nRarity++)
                {
                    string sRarityName;
                    switch (nRarity)
                    {
                        case 0: { sRarityName = "Common"; break; }
                        case 1: { sRarityName = "Uncommon"; break; }
                        case 2: { sRarityName = "Rare"; break; }
                    }
                    object oContainerToSearchThrough = GetObjectByTag("_" + sContainerTypeName + sRarityName + "T" + IntToString(nTier) + sUniqueness);
                    if (GetIsObjectValid(oContainerToSearchThrough))
                    {
                        object oTest = GetFirstItemInInventory(oContainerToSearchThrough);
                        while (GetIsObjectValid(oTest))
                        {
                            int bWasFabricator = 0;
                            // Follow fabricator ammo, or for some reason this doesn't get put into the chests
                            if (GetStringLength(GetLocalString(oTest, "ammo_tag")) > 0)
                            {
                                object oAmmo = GetAmmo(GetLocalString(oTest, "ammo_tag"));
                                if (GetIsObjectValid(oAmmo))
                                {
                                    oTest = oAmmo;
                                    bWasFabricator = 1;
                                }
                            }
                            int nBaseItem = GetBaseItemType(oTest);
                            object oContainerForItem;
                            if (nBaseItem == BASE_ITEM_ARMOR)
                            {
                                int nBaseAC = GetBaseArmorAC(oTest);
                                oContainerForItem = GetObjectByTag("_BaseItem" + IntToString(nBaseItem) + "T" + IntToString(nTier) + "AC" + IntToString(nBaseAC) + sUniqueness);
                                if (!GetIsObjectValid(oContainerForItem))
                                {
                                    oContainerForItem = CreateTreasureContainer("_BaseItem" + IntToString(nBaseItem) + "T" + IntToString(nTier) + "AC" + IntToString(nBaseAC) + sUniqueness, IntToFloat(nTier)*2.0, 36.0 + IntToFloat((nBaseItem * 2) + nUnique));
                                }
                            }
                            else
                            {
                                // Merge gloves/bracers together in one happy union of hand socks
                                if (nBaseItem == BASE_ITEM_BRACER)
                                {
                                    nBaseItem = BASE_ITEM_GLOVES;
                                }
                                oContainerForItem = GetObjectByTag("_BaseItem" + IntToString(nBaseItem) + "T" + IntToString(nTier) + sUniqueness);
                                if (!GetIsObjectValid(oContainerForItem))
                                {
                                    oContainerForItem = CreateTreasureContainer("_BaseItem" + IntToString(nBaseItem) + "T" + IntToString(nTier) + sUniqueness, IntToFloat(nTier)*2.0, 36.0 + IntToFloat((nBaseItem * 2) + nUnique));
                                }
                            }
                            //SendDebugMessage("Base Items by Tier: Copy " + GetName(oTest) + " to " + GetTag(oContainerForItem), TRUE);
                            int bOkay = 1;
                            // Following fabricators is allowing dupes in the same container, so if it was a fabricator
                            // Take a little while to check for dupes first
                            if (bWasFabricator)
                            {
                                object oTest2 = GetFirstItemInInventory(oContainerForItem);
                                while (GetIsObjectValid(oTest2))
                                {
                                    if (GetResRef(oTest2) == GetResRef(oTest))
                                    {
                                        bOkay = 0;
                                        break;
                                    }
                                    oTest2 = GetNextItemInInventory(oContainerForItem);
                                }
                            }
                            if (bOkay)
                            {
                                CopyItem(oTest, oContainerForItem, TRUE);
                            }
                            oTest = GetNextItemInInventory(oContainerToSearchThrough);
                        }
                    }
                }
            }
        }
    }
}

void SeedTreasurePart2();

void main()
{
    // Destroying this is kinda important.
    // If items were seeded into a chest, and then removed, and that chest no longer contains anything to seed
    // there is nothing removing it from the db
    // so the old items continue to pop up
    DestroyCampaignDatabase("treasures");

// ==============================================
//  START TREASURE
// ==============================================

// first we will generate the containers we need. these will act as the treasure tables
   int nIndex;
   for (nIndex = 1; nIndex < 6; nIndex++)
   {
      CreateTreasureContainer("_ArmorCommonT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 0.0);
      CreateTreasureContainer("_ArmorUncommonT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 1.0);
      CreateTreasureContainer("_ArmorRareT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 2.0);

      CreateTreasureContainer("_RangeCommonT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 4.0);
      CreateTreasureContainer("_RangeUncommonT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 5.0);
      CreateTreasureContainer("_RangeRareT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 6.0);

      CreateTreasureContainer("_MeleeCommonT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 8.0);
      CreateTreasureContainer("_MeleeUncommonT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 9.0);
      CreateTreasureContainer("_MeleeRareT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 10.0);

      CreateTreasureContainer("_ApparelCommonT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 12.0);
      CreateTreasureContainer("_ApparelUncommonT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 13.0);
      CreateTreasureContainer("_ApparelRareT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 14.0);

      CreateTreasureContainer("_ScrollsT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 16.0);

      CreateTreasureContainer("_PotionsT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 18.0);

      CreateTreasureContainer("_MiscT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 20.0);
      CreateTreasureContainer("_MiscConsT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 21.0);

      CreateTreasureContainer("_ArmorCommonT"+IntToString(nIndex)+"NonUnique", IntToFloat(nIndex)*2.0, 22.0);
      CreateTreasureContainer("_ArmorUncommonT"+IntToString(nIndex)+"NonUnique", IntToFloat(nIndex)*2.0, 23.0);
      CreateTreasureContainer("_ArmorRareT"+IntToString(nIndex)+"NonUnique", IntToFloat(nIndex)*2.0, 24.0);

      CreateTreasureContainer("_RangeCommonT"+IntToString(nIndex)+"NonUnique", IntToFloat(nIndex)*2.0, 26.0);
      CreateTreasureContainer("_RangeUncommonT"+IntToString(nIndex)+"NonUnique", IntToFloat(nIndex)*2.0, 27.0);
      CreateTreasureContainer("_RangeRareT"+IntToString(nIndex)+"NonUnique", IntToFloat(nIndex)*2.0, 28.0);

      CreateTreasureContainer("_MeleeCommonT"+IntToString(nIndex)+"NonUnique", IntToFloat(nIndex)*2.0, 30.0);
      CreateTreasureContainer("_MeleeUncommonT"+IntToString(nIndex)+"NonUnique", IntToFloat(nIndex)*2.0, 31.0);
      CreateTreasureContainer("_MeleeRareT"+IntToString(nIndex)+"NonUnique", IntToFloat(nIndex)*2.0, 32.0);

      CreateTreasureContainer("_PotionsT"+IntToString(nIndex)+"NonUnique", IntToFloat(nIndex)*2.0, 34.0);

      CreateTreasureContainer("_JewelsT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 35.0);
   }

   object oFabricatorContainer = CreateObject(OBJECT_TYPE_PLACEABLE, "_treas_container", Location(GetObjectByTag("_TREASURE"), Vector(40.0, 40.0, 40.0), 0.0), FALSE, "_FabricatorAmmo");
        SetName(oFabricatorContainer, "_FabricatorAmmo");

// seed these mundane items to distribution
   CopySeedContainerToDistribution(GetObjectByTag(TREASURE_MELEE_SEED_CHEST));
   CopySeedContainerToDistribution(GetObjectByTag(TREASURE_RANGE_SEED_CHEST));
   CopySeedContainerToDistribution(GetObjectByTag(TREASURE_ARMOR_SEED_CHEST));

   int i, nFabricatorCost;
   object oArrow, oBolt, oBullet;
   location lStaging = GetTreasureStagingLocation();
   for (i = 0; i < 5; i++)
   {
        if (i == 0)
        {
            CreateItemOnObject("arrow"+IntToString(i), GetObjectByTag("_RangeCommonT"+IntToString(i+1)+"NonUnique"), 99);
            CreateItemOnObject("bolt"+IntToString(i), GetObjectByTag("_RangeUncommonT"+IntToString(i+1)+"NonUnique"), 99);
            CreateItemOnObject("bullet"+IntToString(i), GetObjectByTag("_RangeRareT"+IntToString(i+1)+"NonUnique"), 99);
        }
        else
        {
            switch (i)
            {
                case 1: nFabricatorCost = 2000; break;
                case 2: nFabricatorCost = 6000; break;
                case 3: nFabricatorCost = 12000; break;
            }

            oArrow = CreateObject(OBJECT_TYPE_ITEM, "arrow"+IntToString(i), lStaging);
            //SetItemStackSize(oArrow, 50);
            CreateFabricator(oArrow, GetObjectByTag("_RangeCommonT"+IntToString(i+1)+"NonUnique"));

            oBolt = CreateObject(OBJECT_TYPE_ITEM, "bolt"+IntToString(i), lStaging);
            //SetItemStackSize(oBolt, 50);
            CreateFabricator(oBolt, GetObjectByTag("_RangeUncommonT"+IntToString(i+1)+"NonUnique"));

            oBullet = CreateObject(OBJECT_TYPE_ITEM, "bullet"+IntToString(i), lStaging);
            //SetItemStackSize(oBullet, 50);
            CreateFabricator(oBullet, GetObjectByTag("_RangeRareT"+IntToString(i+1)+"NonUnique"));
        }
   }

// grab items from palette
   CreateTypeLoot("apparel");
   CreateTypeLoot("misc");
   CreateTypeLoot("weapon");
   CreateTypeLoot("armor");


// ==============================================
//  MANUALLY ADDED ITEMS
// ==============================================

    CreateItemOnObject("manualstr", GetObjectByTag("_MiscT5"));
    CreateItemOnObject("manualdex", GetObjectByTag("_MiscT5"));
    CreateItemOnObject("manualcon", GetObjectByTag("_MiscT5"));
    CreateItemOnObject("manualwis", GetObjectByTag("_MiscT5"));
    CreateItemOnObject("manualcha", GetObjectByTag("_MiscT5"));
    CreateItemOnObject("manualint", GetObjectByTag("_MiscT5"));



    // Hypothesis: there's a limit to the number of items allowed in one container
    // And everything beyond a certain point trying to stuff more in just gets told NO.
    int nCount = 0;
    WriteTimestampedLogEntry("Distributing to stores (early)...");
    // stop at 2000, it could be an infinite loop at this point
    object oContainer = GetObjectByTag(TREASURE_DISTRIBUTION);
    object oDistributionItem = GetFirstItemInInventory(oContainer);
    while (GetIsObjectValid(oDistributionItem))
    {
        DistributeTreasureToStores(oDistributionItem);
        nCount++;
        oDistributionItem = GetNextItemInInventory(oContainer);
    }

    WriteTimestampedLogEntry("Distributing to stores (early) distributed " + IntToString(nCount) + " items");
    DelayCommand(2.0, SeedTreasurePart2());
}

void SeedTreasurePart2()
{
// ==============================================
//  ARMORS
// ==============================================

// +1, +2, +3 armors
   string sEnchantedArmor = "This magic armor grants additional protection to its wearer, but it doesn't bear the hallmarks of any specific maker.";

   PopulateChestArmor("_ArmorSeed", "", " +1", "p1", sEnchantedArmor, 15, 6, 51, 15, 18, 19, 0, 0, ItemPropertyACBonus(1), ItemPropertyNoDamage(), ItemPropertyNoDamage(), TRUE);
   PopulateChestArmor("_ArmorSeed", "", " +2", "p2", sEnchantedArmor, 15, 7, 7, 15, 10, 17, 0, 0, ItemPropertyACBonus(2), ItemPropertyNoDamage(), ItemPropertyNoDamage(), TRUE);
   PopulateChestArmor("_ArmorSeed", "", " +3", "p3", sEnchantedArmor, 46, 23, 23, 46, 3, 39, 0, 0, ItemPropertyACBonus(3), ItemPropertyNoDamage(), ItemPropertyNoDamage(), TRUE);
   SendDebugMessage("Treasure armors created", TRUE);

// ==============================================
//  POTIONS
// ==============================================
    object oItem;
    string sTier;
    location lStaging = GetTreasureStagingLocation();
    int nIndex, i;
    for (nIndex = 1; nIndex < 90; nIndex++)
    {
       oItem = CreateObject(OBJECT_TYPE_ITEM, "potion"+IntToString(nIndex), lStaging);

       int nValue = GetGoldPieceValue(oItem);

       if (nValue >= 700)      {sTier = "T5";}
       else if (nValue >= 400) {sTier = "T4";}
       else if (nValue >= 200) {sTier = "T3";}
       else if (nValue >= 100) {sTier = "T2";}
       else {sTier = "T1";}
       CopyItemToExistingTarget(oItem, GetObjectByTag("_Potions"+sTier));
       DestroyObject(oItem);
    }

    CreateItemOnObject("cure_potion4", GetObjectByTag("_PotionsT5NonUnique"));
    CreateItemOnObject("cure_potion4", GetObjectByTag("_PotionsT4NonUnique"));
    CreateItemOnObject("cure_potion3", GetObjectByTag("_PotionsT3NonUnique"));
    CreateItemOnObject("cure_potion2", GetObjectByTag("_PotionsT2NonUnique"));
    CreateItemOnObject("cure_potion1", GetObjectByTag("_PotionsT1NonUnique"));

    CreateItemOnObject("potion_antidote", GetObjectByTag("_PotionsT2"));
    CreateItemOnObject("potion_rmdisease", GetObjectByTag("_PotionsT2"));
    CreateItemOnObject("potion_restorel", GetObjectByTag("_PotionsT2"));
    CreateItemOnObject("potion_restorem", GetObjectByTag("_PotionsT3"));

    SendDebugMessage("Treasure potions seeded", TRUE);

// ==============================================
//  SCROLLS
// ==============================================

    CreateStagingScroll("nw_it_sparscr001");
    CreateStagingScroll("nw_it_sparscr002");
    CreateStagingScroll("nw_it_sparscr003");
    CreateStagingScroll("nw_it_sparscr004");
    CreateStagingScroll("nw_it_sparscr101");
    CreateStagingScroll("nw_it_sparscr102");
    CreateStagingScroll("nw_it_sparscr103");
    CreateStagingScroll("nw_it_sparscr104");
    CreateStagingScroll("nw_it_sparscr105");
    CreateStagingScroll("nw_it_sparscr106");
    CreateStagingScroll("nw_it_sparscr107");
    CreateStagingScroll("nw_it_sparscr108");
    CreateStagingScroll("nw_it_sparscr109");
    CreateStagingScroll("nw_it_sparscr110");
    CreateStagingScroll("nw_it_sparscr111");
    CreateStagingScroll("nw_it_sparscr112");
    CreateStagingScroll("nw_it_sparscr113");
    CreateStagingScroll("nw_it_sparscr201");
    CreateStagingScroll("nw_it_sparscr202");
    CreateStagingScroll("nw_it_sparscr203");
    CreateStagingScroll("nw_it_sparscr204");
    CreateStagingScroll("nw_it_sparscr205");
    CreateStagingScroll("nw_it_sparscr206");
    CreateStagingScroll("nw_it_sparscr207");
    CreateStagingScroll("nw_it_sparscr208");
    CreateStagingScroll("nw_it_sparscr209");
    CreateStagingScroll("nw_it_sparscr210");
    CreateStagingScroll("nw_it_sparscr211");
    CreateStagingScroll("nw_it_sparscr212");
    CreateStagingScroll("nw_it_sparscr213");
    CreateStagingScroll("nw_it_sparscr214");
    CreateStagingScroll("nw_it_sparscr215");
    CreateStagingScroll("nw_it_sparscr216");
    CreateStagingScroll("nw_it_sparscr217");
    CreateStagingScroll("nw_it_sparscr218");
    CreateStagingScroll("nw_it_sparscr219");
    CreateStagingScroll("nw_it_sparscr220");
    CreateStagingScroll("nw_it_sparscr221");
    CreateStagingScroll("nw_it_sparscr301");
    CreateStagingScroll("nw_it_sparscr302");
    CreateStagingScroll("nw_it_sparscr303");
    CreateStagingScroll("nw_it_sparscr304");
    CreateStagingScroll("nw_it_sparscr305");
    CreateStagingScroll("nw_it_sparscr306");
    CreateStagingScroll("nw_it_sparscr307");
    CreateStagingScroll("nw_it_sparscr308");
    CreateStagingScroll("nw_it_sparscr309");
    CreateStagingScroll("nw_it_sparscr310");
    CreateStagingScroll("nw_it_sparscr311");
    CreateStagingScroll("nw_it_sparscr312");
    CreateStagingScroll("nw_it_sparscr313");
    CreateStagingScroll("nw_it_sparscr314");
    CreateStagingScroll("nw_it_sparscr315");
    CreateStagingScroll("nw_it_sparscr401");
    CreateStagingScroll("nw_it_sparscr402");
    CreateStagingScroll("nw_it_sparscr403");
    CreateStagingScroll("nw_it_sparscr404");
    CreateStagingScroll("nw_it_sparscr405");
    CreateStagingScroll("nw_it_sparscr406");
    CreateStagingScroll("nw_it_sparscr407");
    CreateStagingScroll("nw_it_sparscr408");
    CreateStagingScroll("nw_it_sparscr409");
    CreateStagingScroll("nw_it_sparscr410");
    CreateStagingScroll("nw_it_sparscr411");
    CreateStagingScroll("nw_it_sparscr412");
    CreateStagingScroll("nw_it_sparscr413");
    CreateStagingScroll("nw_it_sparscr414");
    CreateStagingScroll("nw_it_sparscr415");
    CreateStagingScroll("nw_it_sparscr416");
    CreateStagingScroll("nw_it_sparscr417");
    CreateStagingScroll("nw_it_sparscr418");
    CreateStagingScroll("nw_it_sparscr501");
    CreateStagingScroll("nw_it_sparscr502");
    CreateStagingScroll("nw_it_sparscr503");
    CreateStagingScroll("nw_it_sparscr504");
    CreateStagingScroll("nw_it_sparscr505");
    CreateStagingScroll("nw_it_sparscr506");
    CreateStagingScroll("nw_it_sparscr507");
    CreateStagingScroll("nw_it_sparscr508");
    CreateStagingScroll("nw_it_sparscr509");
    CreateStagingScroll("nw_it_sparscr510");
    CreateStagingScroll("nw_it_sparscr511");
    CreateStagingScroll("nw_it_sparscr512");
    CreateStagingScroll("nw_it_sparscr513");
    CreateStagingScroll("nw_it_sparscr601");
    CreateStagingScroll("nw_it_sparscr602");
    CreateStagingScroll("nw_it_sparscr603");
    CreateStagingScroll("nw_it_sparscr604");
    CreateStagingScroll("nw_it_sparscr605");
    CreateStagingScroll("nw_it_sparscr606");
    CreateStagingScroll("nw_it_sparscr607");
    CreateStagingScroll("nw_it_sparscr608");
    CreateStagingScroll("nw_it_sparscr609");
    CreateStagingScroll("nw_it_sparscr610");
    CreateStagingScroll("nw_it_sparscr611");
    CreateStagingScroll("nw_it_sparscr612");
    CreateStagingScroll("nw_it_sparscr613");
    CreateStagingScroll("nw_it_sparscr614");
    CreateStagingScroll("nw_it_sparscr701");
    CreateStagingScroll("nw_it_sparscr702");
    CreateStagingScroll("nw_it_sparscr703");
    CreateStagingScroll("nw_it_sparscr704");
    CreateStagingScroll("nw_it_sparscr705");
    CreateStagingScroll("nw_it_sparscr706");
    CreateStagingScroll("nw_it_sparscr707");
    CreateStagingScroll("nw_it_sparscr708");
    CreateStagingScroll("nw_it_sparscr801");
    CreateStagingScroll("nw_it_sparscr802");
    CreateStagingScroll("nw_it_sparscr803");
    CreateStagingScroll("nw_it_sparscr804");
    CreateStagingScroll("nw_it_sparscr805");
    CreateStagingScroll("nw_it_sparscr806");
    CreateStagingScroll("nw_it_sparscr807");
    CreateStagingScroll("nw_it_sparscr808");
    CreateStagingScroll("nw_it_sparscr809");
    CreateStagingScroll("nw_it_sparscr901");
    CreateStagingScroll("nw_it_sparscr902");
    CreateStagingScroll("nw_it_sparscr903");
    CreateStagingScroll("nw_it_sparscr904");
    CreateStagingScroll("nw_it_sparscr905");
    CreateStagingScroll("nw_it_sparscr906");
    CreateStagingScroll("nw_it_sparscr907");
    CreateStagingScroll("nw_it_sparscr908");
    CreateStagingScroll("nw_it_sparscr909");
    CreateStagingScroll("nw_it_sparscr910");
    CreateStagingScroll("nw_it_sparscr911");
    CreateStagingScroll("nw_it_sparscr912");
    CreateStagingScroll("nw_it_spdvscr201");
    CreateStagingScroll("nw_it_spdvscr202");
    CreateStagingScroll("nw_it_spdvscr203");
    CreateStagingScroll("nw_it_spdvscr204");
    CreateStagingScroll("nw_it_spdvscr301");
    CreateStagingScroll("nw_it_spdvscr302");
    CreateStagingScroll("nw_it_spdvscr401");
    CreateStagingScroll("nw_it_spdvscr402");
    CreateStagingScroll("nw_it_spdvscr501");
    CreateStagingScroll("nw_it_spdvscr701");
    CreateStagingScroll("nw_it_spdvscr702");
    CreateStagingScroll("x1_it_sparscr001");
    CreateStagingScroll("x1_it_sparscr002");
    CreateStagingScroll("x1_it_sparscr003");
    CreateStagingScroll("x1_it_sparscr101");
    CreateStagingScroll("x1_it_sparscr102");
    CreateStagingScroll("x1_it_sparscr103");
    CreateStagingScroll("x1_it_sparscr104");
    CreateStagingScroll("x1_it_sparscr201");
    CreateStagingScroll("x1_it_sparscr202");
    CreateStagingScroll("x1_it_sparscr301");
    CreateStagingScroll("x1_it_sparscr302");
    CreateStagingScroll("x1_it_sparscr303");
    CreateStagingScroll("x1_it_sparscr401");
    CreateStagingScroll("x1_it_sparscr501");
    CreateStagingScroll("x1_it_sparscr502");
    CreateStagingScroll("x1_it_sparscr601");
    CreateStagingScroll("x1_it_sparscr602");
    CreateStagingScroll("x1_it_sparscr603");
    CreateStagingScroll("x1_it_sparscr604");
    CreateStagingScroll("x1_it_sparscr605");
    CreateStagingScroll("x1_it_sparscr701");
    CreateStagingScroll("x1_it_sparscr801");
    CreateStagingScroll("x1_it_sparscr901");
    CreateStagingScroll("x1_it_spdvscr001");
    CreateStagingScroll("x1_it_spdvscr101");
    CreateStagingScroll("x1_it_spdvscr102");
    CreateStagingScroll("x1_it_spdvscr103");
    CreateStagingScroll("x1_it_spdvscr104");
    CreateStagingScroll("x1_it_spdvscr105");
    CreateStagingScroll("x1_it_spdvscr106");
    CreateStagingScroll("x1_it_spdvscr107");
    CreateStagingScroll("x1_it_spdvscr201");
    CreateStagingScroll("x1_it_spdvscr202");
    CreateStagingScroll("x1_it_spdvscr203");
    CreateStagingScroll("x1_it_spdvscr204");
    CreateStagingScroll("x1_it_spdvscr205");
    CreateStagingScroll("x1_it_spdvscr301");
    CreateStagingScroll("x1_it_spdvscr302");
    CreateStagingScroll("x1_it_spdvscr303");
    CreateStagingScroll("x1_it_spdvscr304");
    CreateStagingScroll("x1_it_spdvscr305");
    CreateStagingScroll("x1_it_spdvscr401");
    CreateStagingScroll("x1_it_spdvscr402");
    CreateStagingScroll("x1_it_spdvscr403");
    CreateStagingScroll("x1_it_spdvscr501");
    CreateStagingScroll("x1_it_spdvscr502");
    CreateStagingScroll("x1_it_spdvscr601");
    CreateStagingScroll("x1_it_spdvscr602");
    CreateStagingScroll("x1_it_spdvscr603");
    CreateStagingScroll("x1_it_spdvscr604");
    CreateStagingScroll("x1_it_spdvscr605");
    CreateStagingScroll("x1_it_spdvscr701");
    CreateStagingScroll("x1_it_spdvscr702");
    CreateStagingScroll("x1_it_spdvscr703");
    CreateStagingScroll("x1_it_spdvscr704");
    CreateStagingScroll("x1_it_spdvscr801");
    CreateStagingScroll("x1_it_spdvscr802");
    CreateStagingScroll("x1_it_spdvscr803");
    CreateStagingScroll("x1_it_spdvscr804");
    CreateStagingScroll("x1_it_spdvscr901");
    CreateStagingScroll("x2_it_sparscr101");
    CreateStagingScroll("x2_it_sparscr102");
    CreateStagingScroll("x2_it_sparscr103");
    CreateStagingScroll("x2_it_sparscr104");
    CreateStagingScroll("x2_it_sparscr105");
    CreateStagingScroll("x2_it_sparscr201");
    CreateStagingScroll("x2_it_sparscr202");
    CreateStagingScroll("x2_it_sparscr203");
    CreateStagingScroll("x2_it_sparscr204");
    CreateStagingScroll("x2_it_sparscr205");
    CreateStagingScroll("x2_it_sparscr206");
    CreateStagingScroll("x2_it_sparscr207");
    CreateStagingScroll("x2_it_sparscr301");
    CreateStagingScroll("x2_it_sparscr302");
    CreateStagingScroll("x2_it_sparscr303");
    CreateStagingScroll("x2_it_sparscr304");
    CreateStagingScroll("x2_it_sparscr305");
    CreateStagingScroll("x2_it_sparscr401");
    CreateStagingScroll("x2_it_sparscr501");
    CreateStagingScroll("x2_it_sparscr502");
    CreateStagingScroll("x2_it_sparscr503");
    CreateStagingScroll("x2_it_sparscr601");
    CreateStagingScroll("x2_it_sparscr602");
    CreateStagingScroll("x2_it_sparscr701");
    CreateStagingScroll("x2_it_sparscr703");
    CreateStagingScroll("x2_it_sparscr801");
    CreateStagingScroll("x2_it_sparscr901");
    CreateStagingScroll("x2_it_sparscr902");
    CreateStagingScroll("x2_it_sparscral ");
    CreateStagingScroll("x2_it_sparscrmc");
    CreateStagingScroll("x2_it_spdvscr001");
    CreateStagingScroll("x2_it_spdvscr002");
    CreateStagingScroll("x2_it_spdvscr101");
    CreateStagingScroll("x2_it_spdvscr102");
    CreateStagingScroll("x2_it_spdvscr103");
    CreateStagingScroll("x2_it_spdvscr104");
    CreateStagingScroll("x2_it_spdvscr105");
    CreateStagingScroll("x2_it_spdvscr106");
    CreateStagingScroll("x2_it_spdvscr107");
    CreateStagingScroll("x2_it_spdvscr108");
    CreateStagingScroll("x2_it_spdvscr201");
    CreateStagingScroll("x2_it_spdvscr202");
    CreateStagingScroll("x2_it_spdvscr203");
    CreateStagingScroll("x2_it_spdvscr204");
    CreateStagingScroll("x2_it_spdvscr205");
    CreateStagingScroll("x2_it_spdvscr301");
    CreateStagingScroll("x2_it_spdvscr302");
    CreateStagingScroll("x2_it_spdvscr303");
    CreateStagingScroll("x2_it_spdvscr304");
    CreateStagingScroll("x2_it_spdvscr305");
    CreateStagingScroll("x2_it_spdvscr306");
    CreateStagingScroll("x2_it_spdvscr307");
    CreateStagingScroll("x2_it_spdvscr308");
    CreateStagingScroll("x2_it_spdvscr309");
    CreateStagingScroll("x2_it_spdvscr310");
    CreateStagingScroll("x2_it_spdvscr311");
    CreateStagingScroll("x2_it_spdvscr312");
    CreateStagingScroll("x2_it_spdvscr313");
    CreateStagingScroll("x2_it_spdvscr401");
    CreateStagingScroll("x2_it_spdvscr402");
    CreateStagingScroll("x2_it_spdvscr403");
    CreateStagingScroll("x2_it_spdvscr404");
    CreateStagingScroll("x2_it_spdvscr405");
    CreateStagingScroll("x2_it_spdvscr406");
    CreateStagingScroll("x2_it_spdvscr407");
    CreateStagingScroll("x2_it_spdvscr501");
    CreateStagingScroll("x2_it_spdvscr502");
    CreateStagingScroll("x2_it_spdvscr503");
    CreateStagingScroll("x2_it_spdvscr504");
    CreateStagingScroll("x2_it_spdvscr505");
    CreateStagingScroll("x2_it_spdvscr506");
    CreateStagingScroll("x2_it_spdvscr507");
    CreateStagingScroll("x2_it_spdvscr508");
    CreateStagingScroll("x2_it_spdvscr509");
    CreateStagingScroll("x2_it_spdvscr601");
    CreateStagingScroll("x2_it_spdvscr602");
    CreateStagingScroll("x2_it_spdvscr603");
    CreateStagingScroll("x2_it_spdvscr604");
    CreateStagingScroll("x2_it_spdvscr605");
    CreateStagingScroll("x2_it_spdvscr606");
    CreateStagingScroll("x2_it_spdvscr701");
    CreateStagingScroll("x2_it_spdvscr702");
    CreateStagingScroll("x2_it_spdvscr801");
    CreateStagingScroll("x2_it_spdvscr802");
    CreateStagingScroll("x2_it_spdvscr803");
    CreateStagingScroll("x2_it_spdvscr804");
    CreateStagingScroll("x2_it_spdvscr901");
    CreateStagingScroll("x2_it_spdvscr902");
    CreateStagingScroll("x2_it_spdvscr903");

    SendDebugMessage("Treasure scrolls generated", TRUE);

// ==============================================
//  TRAPS
// ==============================================
    int nSetDC;
    string sTrapTier;

    for (i = 0; i < 44; i++)
    {
        nSetDC = StringToInt(Get2DAString("traps", "SetDC", i));

        if (nSetDC >= 35)
        {
            sTrapTier = "T5";
        }
        else if (nSetDC >= 30)
        {
            sTrapTier = "T4";
        }
        else if (nSetDC >= 25)
        {
            sTrapTier = "T3";
        }
        else if (nSetDC >= 15)
        {
            sTrapTier = "T2";
        }
        else
        {
            sTrapTier = "T1";
        }
        CreateItemOnObject(Get2DAString("traps", "ResRef", i),GetObjectByTag("_Misc"+sTrapTier));
    }

    SendDebugMessage("Treasure traps generated", TRUE);

// ------------------------------------------
// Melee weapons
// ------------------------------------------

// +1 dmg
   PopulateChestWeapon("_MeleeSeed", "High Quality ", "", "hq", "", 2, 0, 0, 1, 1, 1, ItemPropertyNoDamage(), ItemPropertyNoDamage(), ItemPropertyNoDamage(), 1, TRUE);

// +1, +2, and +3 melee and throwing weapons
   string sEnchanted = "This magic weapon has an enhancement bonus to attack and damage, but it doesn't bear the hallmarks of any specific maker.";

   PopulateChestWeapon(TREASURE_MELEE_SEED_CHEST, "", " +1", "p1", sEnchanted, 2, 0, 0, 3, 3, 3, ItemPropertyEnhancementBonus(1), ItemPropertyNoDamage(), ItemPropertyNoDamage(), 0, TRUE);
   PopulateChestWeapon(TREASURE_MELEE_SEED_CHEST, "", " +2", "p2", sEnchanted, 3, 0, 0, 2, 2, 2, ItemPropertyEnhancementBonus(2), ItemPropertyNoDamage(), ItemPropertyNoDamage(), 0, TRUE);
   PopulateChestWeapon(TREASURE_MELEE_SEED_CHEST, "", " +3", "p3", sEnchanted, 1, 3, 2, 4, 1, 4, ItemPropertyEnhancementBonus(3), ItemPropertyNoDamage(), ItemPropertyNoDamage(), 0, TRUE);

   string sColdIron = "A series of these weapons were constructed for the defense of the library fortress of Candlekeep some 200 years ago. The keep had acquired a tome detailing the imprisonment of the pit fiend Aegatohl, and a score of malevolent creatures came to claim it. A small horde was held at bay by the Knights of the Mailed Fist, along with the unexpected assistance of Devon's Privateers, a group of pirates. The tome was later destroyed.";

   PopulateChestWeapon(TREASURE_MELEE_SEED_CHEST, "Cold Iron ", "", "ci", sColdIron, 2, 2, 2, 1, 1, 1, ItemPropertyAttackBonus(1), ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_COLD, IP_CONST_DAMAGEBONUS_1d6), ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_FORTITUDE, 1));

   string sBlessed = "This weapon bears the mark of the Morninglord, and is shrouded in a faint holy aura. While its magic is weaker than more conventional enchanted weaponry, it still possesses additional effectivenss against undead beings.";

   PopulateChestWeapon(TREASURE_MELEE_SEED_CHEST, "Blessed ", "", "bls", sBlessed, 2, 1, 2, 1, 3, 2, ItemPropertyEnhancementBonusVsRace(IP_CONST_RACIALTYPE_UNDEAD, 1), ItemPropertyDamageBonusVsRace(IP_CONST_RACIALTYPE_UNDEAD, IP_CONST_DAMAGETYPE_DIVINE, IP_CONST_DAMAGEBONUS_2), ItemPropertyNoDamage());

// ------------------------------------------
// Range weapons
// ------------------------------------------

// +1 mighty
   PopulateChestWeapon(TREASURE_RANGE_SEED_CHEST, "Composite ", "", "c", "", 2, 3, 4, 1, 1, 1, ItemPropertyNoDamage(), ItemPropertyNoDamage(), ItemPropertyNoDamage(), 2, TRUE);

   string sCompositeEnchanted = "This magic weapon has a bonus to attack. As well, it allows the wielder to add part of their strength modifier to the damage dealt.";

// +1, +2, and +3
   PopulateChestWeapon(TREASURE_RANGE_SEED_CHEST, "Composite ", " +1", "c1", sCompositeEnchanted, 2, 3, 4, 3, 3, 3, ItemPropertyAttackBonus(1), ItemPropertyMaxRangeStrengthMod(3), ItemPropertyNoDamage(), 0, TRUE);
   PopulateChestWeapon(TREASURE_RANGE_SEED_CHEST, "Composite ", " +2", "c2", sCompositeEnchanted, 2, 3, 4, 2, 2, 2, ItemPropertyAttackBonus(2), ItemPropertyMaxRangeStrengthMod(4), ItemPropertyNoDamage(), 0, TRUE);
   PopulateChestWeapon(TREASURE_RANGE_SEED_CHEST, "Composite ", " +3", "c3", sCompositeEnchanted, 2, 3, 4, 4, 4, 4, ItemPropertyAttackBonus(3), ItemPropertyMaxRangeStrengthMod(5), ItemPropertyNoDamage(), 0, TRUE);

   SendDebugMessage("Treasure weapons created", TRUE);

// ------------------------------------------
// GEMS / JEWELRY
// ------------------------------------------
                                                               // gold value
    CreateItemOnObject("misc43", GetObjectByTag("_JewelsT1")); // 16
    CreateItemOnObject("misc44", GetObjectByTag("_JewelsT1")); // 40
    CreateItemOnObject("misc38", GetObjectByTag("_JewelsT1")); // 20
    CreateItemOnObject("misc71", GetObjectByTag("_JewelsT1")); // 90

    CreateItemOnObject("misc35", GetObjectByTag("_JewelsT2")); // 40
    CreateItemOnObject("misc34", GetObjectByTag("_JewelsT2")); // 80
    CreateItemOnObject("misc67", GetObjectByTag("_JewelsT2")); // 250
    CreateItemOnObject("misc72", GetObjectByTag("_JewelsT2")); // 275

    CreateItemOnObject("misc41", GetObjectByTag("_JewelsT3")); // 240
    CreateItemOnObject("misc33", GetObjectByTag("_JewelsT3")); // 290
    CreateItemOnObject("misc70", GetObjectByTag("_JewelsT3")); // 700
    CreateItemOnObject("misc69", GetObjectByTag("_JewelsT3")); // 550
    CreateItemOnObject("misc47", GetObjectByTag("_JewelsT3")); // 500

    CreateItemOnObject("misc39", GetObjectByTag("_JewelsT4")); // 1300
    CreateItemOnObject("misc37", GetObjectByTag("_JewelsT4")); // 1500
    CreateItemOnObject("misc68", GetObjectByTag("_JewelsT4")); // 1050

    CreateItemOnObject("misc36", GetObjectByTag("_JewelsT5")); // 2000
    CreateItemOnObject("misc45", GetObjectByTag("_JewelsT5")); // 3000
    CreateItemOnObject("misc46", GetObjectByTag("_JewelsT5")); // 4000

// ======================================================
// DISTRIBUTION
// ======================================================

    object oContainer = GetObjectByTag(TREASURE_DISTRIBUTION);
    object oDistributionItem = GetFirstItemInInventory(oContainer);

    WriteTimestampedLogEntry("Distributing to stores (late)...");
// stop at 2000, it could be an infinite loop at this point
    int nCount = 0;
    while (GetIsObjectValid(oDistributionItem))
    {
        DistributeTreasureToStores(oDistributionItem);
        nCount++;
        oDistributionItem = GetNextItemInInventory(oContainer);
    }

    WriteTimestampedLogEntry("Distributing to stores (late) distributed " + IntToString(nCount) + " items");

    WriteTimestampedLogEntry("Building treasures by item type...");
    CreateContainersForItemTypesByTier();

    CountItemsThroughTiers();


    SetCampaignInt("treasures", "finished", 1);

    SendDebugMessage("Distribution finished and treasures stored to DB", TRUE);
    SetLocalInt(GetModule(), "seed_complete", 1);
}

