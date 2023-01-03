#include "inc_adv_assassin"

void main()
{
    if (GetAdventurerPartyLeader(OBJECT_SELF) == OBJECT_SELF)
    {
        object oPC = GetAdventurerPartyTarget(OBJECT_SELF, OBJECT_INVALID);
        if (GetIsObjectValid(oPC) && GetArea(oPC) == GetArea(OBJECT_SELF))
        {
            MakeAssassinNote(OBJECT_SELF, oPC);
        }
    }
}