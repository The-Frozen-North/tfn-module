#include "1_inc_treasure"
#include "1_inc_debug"

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

// For slings, darts, and shurikens, do something special for them.
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
// this is the only case for mighty or high quality items
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

void main()
{

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
   DelayCommand(TREASURE_CREATION_DELAY, ExecuteScript("3_gtreas_distrib", OBJECT_SELF));
}

