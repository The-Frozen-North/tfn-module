#include "1_inc_treasure"
#include "1_inc_debug"

void main()
{
    int nIndex;
    object oItem;
    string sTier;
    location lStaging = GetTreasureStagingLocation();

    for (nIndex = 1; nIndex < 90; nIndex++)
    {
       oItem = CreateObject(OBJECT_TYPE_ITEM, "potion"+IntToString(nIndex), lStaging);

       int nValue = GetGoldPieceValue(oItem);

       if (nValue >= 400)      {sTier = "T5";}
       else if (nValue >= 200) {sTier = "T4";}
       else if (nValue >= 100) {sTier = "T3";}
       else if (nValue >= 50) {sTier = "T2";}
       else {sTier = "T1";}
       CopyItemToExistingTarget(oItem, GetObjectByTag("_Potions"+sTier));
       DestroyObject(oItem);
    }

    CreateItemOnObject("cure_potion4", GetObjectByTag("_PotionsT5NonUnique"));
    CreateItemOnObject("cure_potion4", GetObjectByTag("_PotionsT4NonUnique"));
    CreateItemOnObject("cure_potion3", GetObjectByTag("_PotionsT3NonUnique"));
    CreateItemOnObject("cure_potion2", GetObjectByTag("_PotionsT2NonUnique"));
    CreateItemOnObject("cure_potion1", GetObjectByTag("_PotionsT1NonUnique"));

    SendDebugMessage("Treasure potions seeded", TRUE);
    DelayCommand(TREASURE_CREATION_DELAY, ExecuteScript("3_gtreas_scrolls", OBJECT_SELF));
}

