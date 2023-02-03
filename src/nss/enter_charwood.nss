#include "inc_quest"

void main()
{
    object oPC = GetEnteringObject();

    if (!GetIsPC(oPC)) return;

    AdvanceQuest(OBJECT_SELF, oPC, 1);
}
