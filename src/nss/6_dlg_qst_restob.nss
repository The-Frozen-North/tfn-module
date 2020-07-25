#include "1_inc_debug"
#include "1_inc_quest"

void main()
{
    object oPC = GetPCSpeaker();

    if (GetIsDeveloper(oPC))
    {
        SetQuestEntry(oPC, "q_undead_infestation", 4);
        SetQuestEntry(oPC, "q_prison_riot", 4);
        SetQuestEntry(oPC, "q_sword_coast_boys", 4);
        SetQuestEntry(oPC, "q_wailing", 4);
    }
}
