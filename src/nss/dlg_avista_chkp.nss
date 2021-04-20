#include "inc_gold"
#include "inc_persist"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    if (GetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+GetTag(OBJECT_SELF)) == 1) return FALSE;

    if (GetGold(oPC) >= CharismaModifiedPersuadeGold(oPC, 70))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
