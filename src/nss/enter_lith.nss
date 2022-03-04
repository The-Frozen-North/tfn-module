#include "inc_quest"

void main()
{
    object oPC = GetEnteringObject();

    if (GetIsObjectValid(oPC))
    {
        AdvanceQuest(OBJECT_SELF, oPC, 1);
    }
}
