#include "1_inc_treasure"
#include "x2_inc_itemprop"
#include "1_inc_debug"

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

void main()
{
// +1, +2, +3 armors
   string sEnchantedArmor = "This magic armor grants additional protection to its wearer, but it doesn't bear the hallmarks of any specific maker.";

   PopulateChestArmor("_ArmorSeed", "", " +1", sEnchantedArmor, 15, 6, 51, 15, 18, 19, 0, 0, ItemPropertyACBonus(1), ItemPropertyNoDamage(), ItemPropertyNoDamage(), TRUE);
   PopulateChestArmor("_ArmorSeed", "", " +2", sEnchantedArmor, 15, 7, 7, 15, 10, 17, 0, 0, ItemPropertyACBonus(2), ItemPropertyNoDamage(), ItemPropertyNoDamage(), TRUE);
   PopulateChestArmor("_ArmorSeed", "", " +3", sEnchantedArmor, 46, 23, 23, 46, 3, 39, 0, 0, ItemPropertyACBonus(3), ItemPropertyNoDamage(), ItemPropertyNoDamage(), TRUE);
   SendDebugMessage("Treasure armors created", TRUE);
   DelayCommand(TREASURE_CREATION_DELAY, ExecuteScript("3_gtreas_potions", OBJECT_SELF));
}

