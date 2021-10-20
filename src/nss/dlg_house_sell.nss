#include "inc_housing"

void main()
{
    object oPC = GetPCSpeaker();

    if (!GetIsPlayerHomeless(oPC))
    {
        ClearHouseOwnership(OBJECT_SELF, oPC);
        InitializeHouseMapPin(oPC);
        GiveGoldToCreature(oPC, GetHouseSellPrice(oPC));
    }
}
