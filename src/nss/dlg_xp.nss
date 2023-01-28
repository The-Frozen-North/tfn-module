#include "inc_debug"
void main()
{
    object oPC = GetPCSpeaker();

    if (GetIsDeveloper(oPC))
    {
        SendDiscordLogMessage(GetName(oPC) + " used the developer menu to give themselves enough experience to reach level 12.");
        GiveXPToCreature(oPC, 100000);
    }
}
