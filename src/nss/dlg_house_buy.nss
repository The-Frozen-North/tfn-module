#include "inc_housing"

void main()
{
    int nGold = StringToInt(GetScriptParam("gold"));
    object oPC = GetPCSpeaker();

    if (GetGold(oPC) >= nGold && TakeHouseOwnership(oPC, OBJECT_SELF))
    {
        TakeGoldFromCreature(nGold, oPC, TRUE);
        SetCampaignInt(GetPCPublicCDKey(oPC), "house_cost", nGold);
    }
}
