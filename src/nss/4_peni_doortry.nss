#include "1_inc_quest"

void main()
{
    object oPC = GetClickingObject();

    if (!GetIsPC(oPC)) return;

    if (GetIsCurrentlyAtQuestStage(OBJECT_SELF, oPC, 1)) ActionStartConversation(oPC, "", TRUE, FALSE);
}
