#include "util_i_csvlists"
#include "inc_persist"

int StartingConditional()
{
    object oMaker3 = GetObjectByTag("ud_maker3");
    object oPC = GetPCSpeaker();
    string sPC = GetPCPublicCDKey(oPC) + GetName(oPC);

    int nAmbush = GetScriptParam("ambush") != "";
    int nGold = StringToInt(GetScriptParam("gold"));
    int nPersuade = GetScriptParam("persuade") != "";

    if (nPersuade)
    {
        if (GetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+"_"+GetTag(OBJECT_SELF)+"_pers") == 1)
        {
            return 0;
        }
    }

    if (nGold)
    {
        if (GetGold(oPC) < nGold)
        {
            return 0;
        }
    }

    if (nAmbush)
    {
        if (FindListItem(GetLocalString(oMaker3, "pcs_entered"), sPC) <= -1)
        {
            return 0;
        }
    }
    return 1;
}
