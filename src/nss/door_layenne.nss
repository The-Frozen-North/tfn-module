#include "inc_key"

void main()
{
    object oPC = GetClickingObject();

    if (GetHasKey(oPC, "key_lay_wiz") && GetHasKey(oPC, "key_lay_wiz"))
    {
        SetLocked(OBJECT_SELF, FALSE);
        AssignCommand(OBJECT_SELF, ActionOpenDoor(OBJECT_SELF));
    }
    else
    {
        FloatingTextStringOnCreature("There appears to be two keyholes on this door. You will probably need both to open it.", oPC, FALSE);
    }
}
