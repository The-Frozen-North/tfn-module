#include "inc_quest"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    if (GetQuestEntry(oPC, "q_cockatrice_fbasilisk") == 2 && GetQuestEntry(oPC, "q_cockatrice_fgorgon") == 2)
    {
        return 1;
    }
    return 0;
}
