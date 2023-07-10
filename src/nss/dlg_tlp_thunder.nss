#include "inc_debug"
void main()
{
    object oPC = GetPCSpeaker();

    if (GetIsDeveloper(oPC))
    {
        SendDiscordLogMessage(GetName(oPC) + " used the developer menu to teleport to Thundertree.");
        AssignCommand(oPC, ActionJumpToLocation(Location(GetObjectByTag("thundertree"), Vector(), 0.0)));
    }
}

