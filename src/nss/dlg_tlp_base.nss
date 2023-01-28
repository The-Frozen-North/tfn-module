#include "inc_debug"
void main()
{
    object oPC = GetPCSpeaker();

    if (GetIsDeveloper(oPC))
    {
        SendDiscordLogMessage(GetName(oPC) + " used the developer menu to enter a system area.");
        AssignCommand(oPC, ActionJumpToLocation(Location(GetObjectByTag("_BASE"), Vector(), 0.0)));
    }
}
