#include "inc_quest"
#include "inc_persist"
#include "x3_inc_string"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

// if PC hasn't finished academy, don't continue
    if (!GetIsAtQuestStage(OBJECT_SELF, oPC, 1)) return FALSE;

// check if the PC talked yet
    if(!(GetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+"dlg_talked_"+StringReplace(GetName(OBJECT_SELF), " ", "_")) == 1)) return FALSE;

    return TRUE;

}

