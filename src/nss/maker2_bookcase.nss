#include "nwnx_player"

void main()
{
    object oPC = GetLastUsedBy();
    if (!GetIsPC(oPC)) { return; }
    
	if (GetLocalInt(OBJECT_SELF, "active"))
    {
        object oNote = GetObjectByTag("maker2_solution_note");
        NWNX_Player_ForcePlaceableExamineWindow(oPC, oNote);
    }
    else
    {
        SendMessageToPC(oPC, "There is nothing especially notable amongst the tomes on this bookcase.");
        SetUseableFlag(OBJECT_SELF, FALSE);
    }
}
