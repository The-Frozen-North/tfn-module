#include "inc_adventurer"
#include "inc_adv_assassin"
#include "inc_ai_combat"
#include "nwnx_creature"

// Adventure party leader perception - assassin group

void main()
{
    if (GetIsInCombat(OBJECT_SELF) || IsInConversation(OBJECT_SELF) || NWNX_Creature_GetFaction(OBJECT_SELF) == STANDARD_FACTION_HOSTILE)
    {
        return;
    }
    object oPerceived = GetLastPerceived();
    if (GetLastPerceptionSeen() && GetIsPC(oPerceived) && !GetIsDead(oPerceived) && !GetIsEnemy(oPerceived) && !GetIsEnemy(OBJECT_SELF, oPerceived))
    {
        object oTarget = GetAdventurerPartyTarget(OBJECT_SELF, oPerceived);
        if (oTarget == oPerceived)
        {
            SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, FALSE);
            string sConv = GetLocalString(OBJECT_SELF, "conversation_override");
            AssignCommand(oTarget, ClearAllActions());
            BeginConversation(sConv, oTarget);
        }
    }
}