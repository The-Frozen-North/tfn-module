#include "inc_debug"
#include "inc_quest"

void main()
{
    object oPC = GetPCSpeaker();

    if (GetIsDeveloper(oPC))
    {
        SendDiscordLogMessage(GetName(oPC) + " used the developer menu to set main quest states.");
        SetQuestEntry(oPC, "q_undead_infestation", 4);
        SetQuestEntry(oPC, "q_prison_riot", 4);
        SetQuestEntry(oPC, "q_sword_coast_boys", 4);
        SetQuestEntry(oPC, "q_wailing", 4);
    }
}
