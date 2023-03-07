// "Take the power source".

#include "inc_quest"
#include "nwnx_visibility"

void main()
{
    object oPC = GetPCSpeaker();
    // I guess this could be done with normal conv stuff, but the visibility is...
    // something else
    int nQuestState = GetQuestEntry(oPC, "q_golems");
    if (nQuestState == 20)
    {
        SetQuestEntry(oPC, "q_golems", 21);
    }
    else if (nQuestState == 26)
    {
        SetQuestEntry(oPC, "q_golems", 27);
    }
    NWNX_Visibility_SetVisibilityOverride(oPC, OBJECT_SELF, NWNX_VISIBILITY_HIDDEN);
}
