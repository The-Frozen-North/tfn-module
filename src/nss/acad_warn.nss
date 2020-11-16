#include "inc_quest"

void main()
{
    object oPC = GetEnteringObject();

    if (!GetIsPC(oPC)) return;

    if (GetQuestEntry(oPC, "q_wailing") > 3) return;

    AssignCommand(oPC, ClearAllActions());
    //AssignCommand(oPC, ActionStartConversation(OBJECT_SELF, "acad_warn", TRUE, FALSE));

    BeginConversation("acad_warn", oPC);
}
