#include "inc_housing"

void main()
{
    object oPC = GetPCSpeaker();

    if (!GetIsPlayerHomeless(oPC))
    {
        ClearHouseOwnership(OBJECT_SELF, oPC);
        InitializeHouseMapPin(oPC);
        GiveGoldToCreature(oPC, GetHouseSellPrice(oPC));
        // This forces a recheck of the PC's house items when they next buy one and reenter.
        // If you enter a small house, the updater scans only the containers present in the small house
        // (and sets the timestamp of the treasure db in the player's databsae)
        // so then if they buy a big house, it won't scan the containers that weren't in the smaller one
        // and they'd get by without being updated
        
        // So if we blow up the database timestamp, that can't happen any more.
        string sKey = GetPCPublicCDKey(oPC, TRUE);
        DeleteCampaignVariable(sKey, "house_item_revision");
    }
}
