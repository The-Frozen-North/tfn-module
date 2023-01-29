#include "inc_debug"
void main()
{
    object oPC = GetPCSpeaker();

    if (GetIsDeveloper(oPC))
    {
        SendDiscordLogMessage(GetName(oPC) + " used the developer menu to give themselves 100000 gold.");
        GiveGoldToCreature(oPC, 100000);
    }
}
