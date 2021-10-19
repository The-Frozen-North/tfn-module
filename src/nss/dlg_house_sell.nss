#include "inc_housing"

void main()
{
    object oPC = GetPCSpeaker();

    if (!GetIsPlayerHomeless(oPC))
    {
        ClearHouseOwnership(OBJECT_SELF, oPC);
        GiveGoldToCreature(oPC, GetHouseSellPrice(oPC));
    }
}
