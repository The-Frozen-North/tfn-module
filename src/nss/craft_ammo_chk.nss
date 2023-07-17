#include "inc_craft"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    object oAmmo = GetAmmo(GetLocalString(oPC, "ammo_tag"));

    if (!GetIsObjectValid(oAmmo))
        return FALSE;

    int nValue = DetermineAmmoCraftingCost(oAmmo);

    if (GetGold(oPC) < nValue)
    {
        return FALSE;
    }
    else
    {
        return TRUE;
    }
}
