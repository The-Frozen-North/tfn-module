#include "inc_debug"
void main()
{
    object oPC = GetPCSpeaker();

    if (GetIsDeveloper(oPC))
    {
        SendDiscordLogMessage(GetName(oPC) + " used the developer menu to teleport to Luskan.");
        AssignCommand(oPC, ActionJumpToLocation(Location(GetObjectByTag("luskan_eastroad"), Vector(50.0, 50.0, 50.0), 0.0)));
    }
}
