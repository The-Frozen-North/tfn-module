#include "inc_quest"

const string ORB_RESREF = "q_cock_fcap";

void main()
{
    object oPC = GetPCSpeaker();
    string sType = GetScriptParam("type");
    if (sType == "startquests")
    {
        SetQuestEntry(oPC, "q_cockatrice_fbasilisk", 1);
        SetQuestEntry(oPC, "q_cockatrice_fgorgon", 1);
        SetQuestEntry(oPC, "q_cockatrice", 3);
        object oOrb = CreateItemOnObject(ORB_RESREF, oPC);
        SetItemCursedFlag(oOrb, TRUE);
        SetIdentified(oOrb, TRUE);
        SetDroppableFlag(oOrb, FALSE);
        SetPickpocketableFlag(oOrb, FALSE);
        SetPlotFlag(oOrb, TRUE);
        return;
    }
    else if (sType == "turninquests")
    {
        // Safety sanity check
        if (GetQuestEntry(oPC, "q_cockatrice") == 3)
        {
            SetQuestEntry(oPC, "q_cockatrice_fbasilisk", 3);
            SetQuestEntry(oPC, "q_cockatrice_fgorgon", 3);
            SetQuestEntry(oPC, "q_cockatrice", 4);
            // Remove orbs from inventory
            object oTest = GetFirstItemInInventory(oPC);
            while (GetIsObjectValid(oTest))
            {
                if (GetResRef(oTest) == ORB_RESREF)
                {
                    DestroyObject(oTest);
                }
                oTest = GetNextItemInInventory(oPC);
            }
            GiveQuestXPToPC(oPC, 3, 8, 0);
            return;
        }
    }
}
