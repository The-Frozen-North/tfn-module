#include "nwnx_player"
#include "inc_craft"
#include "inc_ctoken"

void main()
{
    object oItem = GetItemActivated();
    string sTag = GetLocalString(oItem, "ammo_tag");
    object oAmmo = GetObjectByTag("fabricator_"+sTag);
    object oPC = GetItemActivator();

    if (GetIsObjectValid(oAmmo))
    {
        SetLocalString(oPC, "ammo_tag", sTag);

        NWNX_Player_SetCustomToken(GetItemActivator(), CTOKEN_AMMOMAKER_NAME, GetName(oAmmo)); // name
        NWNX_Player_SetCustomToken(GetItemActivator(), CTOKEN_AMMOMAKER_DC, IntToString(DetermineAmmoCraftingDC(oAmmo))); // DC
        NWNX_Player_SetCustomToken(GetItemActivator(), CTOKEN_AMMOMAKER_GOLD, IntToString(DetermineAmmoCraftingCost(oAmmo))); // gold
        ActionStartConversation(OBJECT_SELF, "ammo_maker", TRUE, FALSE);
    }
}
