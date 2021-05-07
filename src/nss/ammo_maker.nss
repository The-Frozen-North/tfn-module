#include "nwnx_player"
#include "inc_craft"

void main()
{
    object oItem = GetItemActivated();
    string sTag = GetLocalString(oItem, "ammo_tag");
    object oAmmo = GetObjectByTag("fabricator_"+sTag);
    object oPC = GetItemActivator();

    if (GetIsObjectValid(oAmmo))
    {
        SetLocalString(oPC, "ammo_tag", sTag);

        NWNX_Player_SetCustomToken(GetItemActivator(), 30001, GetName(oAmmo)); // name
        NWNX_Player_SetCustomToken(GetItemActivator(), 30002, IntToString(DetermineAmmoCraftingDC(oAmmo))); // DC
        NWNX_Player_SetCustomToken(GetItemActivator(), 30003, IntToString(DetermineAmmoCraftingCost(oAmmo))); // gold
        ActionStartConversation(OBJECT_SELF, "ammo_maker", TRUE, FALSE);
    }
}
