#include "1_inc_debug"
void main()
{
    object oPC = GetPCSpeaker();

    if (GetIsDeveloper(oPC))
    {
        AssignCommand(oPC, ActionJumpToLocation(Location(GetObjectByTag("core"), Vector(), 0.0)));
    }
}
