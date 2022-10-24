#include "inc_adv_assassin"

void main()
{
    object oPC = GetAdventurerPartyTarget(OBJECT_SELF, OBJECT_INVALID);
    if (GetIsObjectValid(oPC) && GetArea(oPC) == GetArea(OBJECT_SELF))
    {
        MakeAssassinNote(OBJECT_SELF, oPC);
    }
}