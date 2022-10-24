#include "inc_adventurer"
#include "inc_adv_assassin"
#include "inc_ai_combat"

// Adventure party leader perception - assassin group

void main()
{
    if (GetIsInCombat(OBJECT_SELF) || IsInConversation(OBJECT_SELF))
    {
        return;
    }
    object oPerceived = GetLastPerceived();
    if (GetLastPerceptionSeen() && GetIsPC(oPerceived) && !GetIsDead(oPerceived) && !GetIsEnemy(oPerceived))
    {
        object oTarget = GetAdventurerPartyTarget(OBJECT_SELF, oPerceived);
        if (oTarget == oPerceived)
        {
            string sConv = GetLocalString(OBJECT_SELF, "conversation_override");
            BeginConversation(sConv, oTarget);
        }
    }
}