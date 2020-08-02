#include "inc_gold"

void main()
{
    object oPC = GetPCSpeaker();

    int nCost = CharismaModifiedGold(oPC, GetLocalInt(OBJECT_SELF, "cost"));

    if (GetGold(oPC) >= nCost)
    {
        TakeGoldFromCreature(nCost, oPC, TRUE);
        location lLocation = GetLocation(GetObjectByTag(GetLocalString(OBJECT_SELF, "warden_tele_wp")));
        AssignCommand(oPC, JumpToLocation(lLocation));
    }
}
