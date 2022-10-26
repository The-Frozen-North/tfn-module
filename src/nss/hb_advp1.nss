#include "inc_adventurer"
#include "inc_adv_assassin"
#include "inc_ai_combat"

// Adventure party leader heartbeat - assassin group

void main()
{
    if (GetIsInCombat(OBJECT_SELF) || IsInConversation(OBJECT_SELF))
    {
        return;
    }
    object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, OBJECT_SELF, 1, CREATURE_TYPE_IS_ALIVE, TRUE, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
    object oTarget = GetAdventurerPartyTarget(OBJECT_SELF, oPC);
    if (oTarget == oPC)
    {
        string sConv = GetLocalString(OBJECT_SELF, "conversation_override");
        BeginConversation(sConv, oTarget);
    }
}