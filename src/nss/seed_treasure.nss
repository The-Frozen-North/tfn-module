#include "inc_treasure"
#include "nwnx_admin"

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

void PopulateChestWeapon(string sSeedChestTag, string sPrependName, string sAppendName, string sDescription, int nTopModel, int nMiddleModel, int nBottomModel, int nTopColor, int nMiddleColor, int nBottomColor, itemproperty ipProp1, itemproperty ipProp2, itemproperty ipProp3, int nPhysicalBonus=0, int bNonUnique = FALSE)
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

       oItem = GetNextItemInInventory(oSeedChest);
   }

}

void PopulateChestArmor(string sSeedChestTag, string sPrependName, string sAppendName, string sDescription, int nCloth1, int nCloth2, int nLeather1, int nLeather2, int nMetal1, int nMetal2, int nShoulder, int nForeArm, itemproperty ipProp1, itemproperty ipProp2, itemproperty ipProp3, int bNonUnique = FALSE)
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

       if (bNonUnique) SetLocalInt(oNewItemStaging, "non_unique", 1);

       oNewItem = CopyItemToExistingTarget(oNewItemStaging, oDistribution);
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

    for (nIndex = 1; nIndex < 300; nIndex++)
    {
       oItem = CreateObject(OBJECT_TYPE_ITEM, sType+IntToString(nIndex), lStaging);
       oNewItem = CopyItem(oItem, oDistribution);

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

// This function determines the AC from the armor given
int GetBaseArmorAC(object oArmor)
{
  return
  StringToInt
  (
    Get2DAString
    (
      "parts_chest",
      "ACBONUS",
      GetItemAppearance(oArmor,ITEM_APPR_TYPE_ARMOR_MODEL,ITEM_APPR_ARMOR_MODEL_TORSO)
    )
  );
}

void DistributeTreasureToStores(object oItem)
{
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

// Apply the enchanted weight reduction at this point.
   AddEnchantedWeightReduction(oItem);

// only get gold value after the weight reduction
   nValue = GetGoldPieceValue(oItem);
   switch (nBaseType)
   {
       case BASE_ITEM_SPELLSCROLL:
          nValue = nValue * 4;
       break;
       case BASE_ITEM_SHURIKEN:
       case BASE_ITEM_THROWINGAXE:
       case BASE_ITEM_DART:
          nValue = nValue * 8;
       break;
       case BASE_ITEM_ARROW:
       case BASE_ITEM_BULLET:
       case BASE_ITEM_BOLT:
          nValue = nValue * 10;
       break;
   }

   switch (nBaseType)
   {
       case BASE_ITEM_SPELLSCROLL:
       case BASE_ITEM_GEM:
       case BASE_ITEM_POTIONS:
          nIdentified = 1;
       break;
   }


// Apply a multiplier for misc items (junk and art)
       if (TestStringAgainstPattern("**misc**", sResRef)) nValue = nValue * 5;

// Enchanted full plate mail is considered 1 tier higher.
       if (nEnchantValue > 0 && nBaseArmorAC == 8) nEnchantValue++;

// Raise an error if there is an item that exceeded the maximum value.
       if (nValue > 22000)
       {
           CopyItemToExistingTarget(oItem, GetObjectByTag("_overvalue"));
           DestroyObject(oItem);
           return;
       }

// Sort by item value
       if (nValue >= MIN_VALUE_T5) {sTier = "T5";}
       else if (nValue >= MIN_VALUE_T4) {sTier = "T4";}
       else if (nValue >= MIN_VALUE_T3) {sTier = "T3";}
       else if (nValue >= MIN_VALUE_T2) {sTier = "T2";}
       else {sTier = "T1";}

// special rule to bump up unidentified items to the next tier, too much magic gear encountered at low level
       if (sTier == "T1" && nIdentified == 0) sTier = "T2";

// High quality/composite range items are always T2
       if (nEnchantValue == 0 && (GetStringLeft(sName, 12) == "High Quality" || GetStringLeft(sName, 9) == "Composite"))
       {
           sTier = "T2";
       }

// Boost some full plates and tower shields to next tier
       if (sName == "Tower Shield +1") sTier = "T4";
       if (sName == "Tower Shield +2") sTier = "T5";
       if (sName == "Half Plate +1") sTier = "T4";
       if (sName == "Full Plate +2") sTier = "T5";

// Bump up items to the right tier for non-uniques
       if (sNonUnique == "NonUnique")
       {
           if (FindSubString(sName, "+1") > -1 && sTier == "T2") sTier = "T3";
           if (FindSubString(sName, "+2") > -1 && sTier == "T3") sTier = "T4";
           if (FindSubString(sName, "+3") > -1 && sTier == "T4") sTier = "T5";
       }

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
        SendDebugMessage("_"+sType+sRarity+sTier+sNonUnique);
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

void main()
{

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
   }

// seed these mundane items to distribution
   CopySeedContainerToDistribution(GetObjectByTag(TREASURE_MELEE_SEED_CHEST));
   CopySeedContainerToDistribution(GetObjectByTag(TREASURE_RANGE_SEED_CHEST));
   CopySeedContainerToDistribution(GetObjectByTag(TREASURE_ARMOR_SEED_CHEST));

   int i;
   for (i = 0; i < 5; i++)
   {
        CreateItemOnObject("arrow"+IntToString(i), GetObjectByTag("_RangeCommonT"+IntToString(i+1)+"NonUnique"), 99);
        CreateItemOnObject("bolt"+IntToString(i), GetObjectByTag("_RangeUncommonT"+IntToString(i+1)+"NonUnique"), 99);
        CreateItemOnObject("bullet"+IntToString(i), GetObjectByTag("_RangeRareT"+IntToString(i+1)+"NonUnique"), 99);
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

// ==============================================
//  ARMORS
// ==============================================

// +1, +2, +3 armors
   string sEnchantedArmor = "This magic armor grants additional protection to its wearer, but it doesn't bear the hallmarks of any specific maker.";

   PopulateChestArmor("_ArmorSeed", "", " +1", sEnchantedArmor, 15, 6, 51, 15, 18, 19, 0, 0, ItemPropertyACBonus(1), ItemPropertyNoDamage(), ItemPropertyNoDamage(), TRUE);
   PopulateChestArmor("_ArmorSeed", "", " +2", sEnchantedArmor, 15, 7, 7, 15, 10, 17, 0, 0, ItemPropertyACBonus(2), ItemPropertyNoDamage(), ItemPropertyNoDamage(), TRUE);
   PopulateChestArmor("_ArmorSeed", "", " +3", sEnchantedArmor, 46, 23, 23, 46, 3, 39, 0, 0, ItemPropertyACBonus(3), ItemPropertyNoDamage(), ItemPropertyNoDamage(), TRUE);
   SendDebugMessage("Treasure armors created", TRUE);

// ==============================================
//  POTIONS
// ==============================================
    object oItem;
    string sTier;
    location lStaging = GetTreasureStagingLocation();

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
   PopulateChestWeapon("_MeleeSeed", "High Quality ", "", "", 2, 0, 0, 1, 1, 1, ItemPropertyNoDamage(), ItemPropertyNoDamage(), ItemPropertyNoDamage(), 1, TRUE);

// +1, +2, and +3 melee and throwing weapons
   string sEnchanted = "This magic weapon has an enhancement bonus to attack and damage, but it doesn't bear the hallmarks of any specific maker.";

   PopulateChestWeapon(TREASURE_MELEE_SEED_CHEST, "", " +1", sEnchanted, 2, 0, 0, 3, 3, 3, ItemPropertyEnhancementBonus(1), ItemPropertyNoDamage(), ItemPropertyNoDamage(), 0, TRUE);
   PopulateChestWeapon(TREASURE_MELEE_SEED_CHEST, "", " +2", sEnchanted, 3, 0, 0, 2, 2, 2, ItemPropertyEnhancementBonus(2), ItemPropertyNoDamage(), ItemPropertyNoDamage(), 0, TRUE);
   PopulateChestWeapon(TREASURE_MELEE_SEED_CHEST, "", " +3", sEnchanted, 1, 3, 2, 4, 1, 4, ItemPropertyEnhancementBonus(3), ItemPropertyNoDamage(), ItemPropertyNoDamage(), 0, TRUE);

   string sColdIron = "A series of these weapons were constructed for the defense of the library fortress of Candlekeep some 200 years ago. The keep had acquired a tome detailing the imprisonment of the pit fiend Aegatohl, and a score of malevolent creatures came to claim it. A small horde was held at bay by the Knights of the Mailed Fist, along with the unexpected assistance of Devon's Privateers, a group of pirates. The tome was later destroyed.";

   PopulateChestWeapon(TREASURE_MELEE_SEED_CHEST, "Cold Iron ", "", sColdIron, 2, 2, 2, 1, 1, 1, ItemPropertyAttackBonus(1), ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_COLD, IP_CONST_DAMAGEBONUS_1d6), ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_FORTITUDE, 1));

// ------------------------------------------
// Range weapons
// ------------------------------------------

// +1 mighty
   PopulateChestWeapon(TREASURE_RANGE_SEED_CHEST, "Composite ", "", "", 2, 3, 4, 1, 1, 1, ItemPropertyNoDamage(), ItemPropertyNoDamage(), ItemPropertyNoDamage(), 2, TRUE);

   string sCompositeEnchanted = "This magic weapon has a bonus to attack. As well, it allows the wielder to add part of their strength modifier to the damage dealt.";

// +1, +2, and +3
   PopulateChestWeapon(TREASURE_RANGE_SEED_CHEST, "Composite ", " +1", sCompositeEnchanted, 2, 3, 4, 3, 3, 3, ItemPropertyAttackBonus(1), ItemPropertyMaxRangeStrengthMod(3), ItemPropertyNoDamage(), 0, TRUE);
   PopulateChestWeapon(TREASURE_RANGE_SEED_CHEST, "Composite ", " +2", sCompositeEnchanted, 2, 3, 4, 2, 2, 2, ItemPropertyAttackBonus(2), ItemPropertyMaxRangeStrengthMod(4), ItemPropertyNoDamage(), 0, TRUE);
   PopulateChestWeapon(TREASURE_RANGE_SEED_CHEST, "Composite ", " +3", sCompositeEnchanted, 2, 3, 4, 4, 4, 4, ItemPropertyAttackBonus(3), ItemPropertyMaxRangeStrengthMod(5), ItemPropertyNoDamage(), 0, TRUE);

   SendDebugMessage("Treasure weapons created", TRUE);

// ======================================================
// DISTRIBUTION
// ======================================================

    object oContainer = GetObjectByTag(TREASURE_DISTRIBUTION);
    object oDistributionItem = GetFirstItemInInventory(oContainer);

// stop at 2000, it could be an infinite loop at this point
    while (GetIsObjectValid(oDistributionItem))
    {
        DistributeTreasureToStores(oDistributionItem);
        oDistributionItem = GetNextItemInInventory(oContainer);
    }

    CountItemsThroughTiers();

    SetCampaignInt("treasures", "finished", 1);

    SendDebugMessage("Distribution finished and treasures stored to DB", TRUE);
}
