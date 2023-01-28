#include "inc_debug"
void main()
{
    object oPC = GetPCSpeaker();

    if (GetIsDeveloper(oPC))
    {
        SendDiscordLogMessage(GetName(oPC) + " used the developer menu to teleport to City Core.");
        AssignCommand(oPC, ActionJumpToLocation(Location(GetObjectByTag("core"), Vector(), 0.0)));
    }
}
