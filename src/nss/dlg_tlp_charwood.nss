#include "inc_debug"
void main()
{
    object oPC = GetPCSpeaker();

    if (GetIsDeveloper(oPC))
    {
        SendDiscordLogMessage(GetName(oPC) + " used the developer menu to teleport to Charwood.");
        AssignCommand(oPC, ActionJumpToLocation(Location(GetObjectByTag("nwood_charwood"), Vector(), 0.0)));
    }
}
