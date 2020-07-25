#include "1_inc_persist"
#include "x3_inc_string"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    if(!(GetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+"dlg_talked_"+StringReplace(GetName(OBJECT_SELF), " ", "_")) == 1)) return FALSE;

    return TRUE;
}
