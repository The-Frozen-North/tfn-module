#include "inc_housing"
#include "inc_webhook"

void main()
{
    int nGold = StringToInt(GetScriptParam("gold"));
    object oPC = GetPCSpeaker();

    if (GetGold(oPC) >= nGold && TakeHouseOwnership(oPC, OBJECT_SELF))
    {
        ActionOpenDoor(OBJECT_SELF);
        TakeGoldFromCreature(nGold, oPC, TRUE);
        SetCampaignInt(GetPCPublicCDKey(oPC), "house_cost", nGold);
        IncrementStat(oPC, "gold_spent_from_buying", nGold);
        InitializeHouseMapPin(oPC);
        HouseBuyWebhook(oPC, nGold, GetArea(OBJECT_SELF));
    }
}
