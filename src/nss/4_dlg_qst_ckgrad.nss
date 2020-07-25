#include "1_inc_quest"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

// if PC hasn't finished academy, don't continue
    if (!GetIsAtQuestStage(OBJECT_SELF, oPC, 1)) return FALSE;

    return TRUE;

}

