#include "inc_loot"


void main()
{

    object oPC = GetFirstPC();

    object oItem = GetFirstItemInInventory(OBJECT_SELF);

    while (GetIsObjectValid(oItem))
    {
        DestroyObject(oItem);

        oItem = GetNextItemInInventory(OBJECT_SELF);
    }

    int i;
    for (i = 0; i < 100; i++)
    {
        // This generates random weapons for ACR 6
        SelectLootItemFromACR(OBJECT_SELF, 6, LOOT_TYPE_WEAPON_MELEE);
    }

    SendMessageToPC(oPC, "T1: "+IntToString(GetLocalInt(GetModule(), "T1")));
    SendMessageToPC(oPC, "T2: "+IntToString(GetLocalInt(GetModule(), "T2")));
    SendMessageToPC(oPC, "T3: "+IntToString(GetLocalInt(GetModule(), "T3")));
    SendMessageToPC(oPC, "T4: "+IntToString(GetLocalInt(GetModule(), "T4")));
    SendMessageToPC(oPC, "T5: "+IntToString(GetLocalInt(GetModule(), "T5")));

    SendMessageToPC(oPC, "Scrolls: "+IntToString(GetLocalInt(GetModule(), "Scrolls")));
    SendMessageToPC(oPC, "Potions: "+IntToString(GetLocalInt(GetModule(), "Scrolls")));
    SendMessageToPC(oPC, "Gold: "+IntToString(GetLocalInt(GetModule(), "Gold")));
    SendMessageToPC(oPC, "Misc: "+IntToString(GetLocalInt(GetModule(), "Misc")));
    SendMessageToPC(oPC, "Armor: "+IntToString(GetLocalInt(GetModule(), "Armor")));
    SendMessageToPC(oPC, "Melee: "+IntToString(GetLocalInt(GetModule(), "Melee")));
    SendMessageToPC(oPC, "Range: "+IntToString(GetLocalInt(GetModule(), "Range")));
    SendMessageToPC(oPC, "Apparel: "+IntToString(GetLocalInt(GetModule(), "Apparel")));


}

