#include "inc_debug"
void main()
{
    object oPC = GetPCSpeaker();

    if (GetIsDeveloper(oPC))
    {
        SendDiscordLogMessage(GetName(oPC) + " used the developer menu to enter the treasure staging area.");
        AssignCommand(oPC, ActionJumpToLocation(Location(GetObjectByTag("_TREASURE"), Vector(), 0.0)));
    }
}
