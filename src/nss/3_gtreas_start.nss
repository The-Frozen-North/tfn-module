#include "1_inc_treasure"

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


void main()
{

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

   CreateTypeLoot("apparel");
   CreateTypeLoot("misc");
   CreateTypeLoot("weapon");
   CreateTypeLoot("armor");

   DelayCommand(TREASURE_CREATION_DELAY, ExecuteScript("3_gtreas_armors", OBJECT_SELF));
}
