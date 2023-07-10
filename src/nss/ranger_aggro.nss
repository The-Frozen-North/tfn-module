#include "nwnx_creature"
#include "inc_event"
#include "inc_ai_combat"

void main()
{
     object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, OBJECT_SELF, 1, CREATURE_TYPE_IS_ALIVE, TRUE, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);

     float fDistance = GetDistanceToObject(oPC);

     ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(100), OBJECT_SELF);

     ChangeToStandardFaction(OBJECT_SELF, STANDARD_FACTION_HOSTILE);

     AssignCommand(CreateEventCreature("krenshar"), ActionAttack(oPC));
     AssignCommand(CreateEventCreature("krenshar"), ActionAttack(oPC));
     AssignCommand(CreateEventCreature("krenshar"), ActionAttack(oPC));

     DeleteLocalString(OBJECT_SELF, "heartbeat_script");
     DeleteLocalString(OBJECT_SELF, "attack_script");
     DeleteLocalString(OBJECT_SELF, "damage_script");

     ActionAttack(oPC);

     gsCBDetermineCombatRound();
}
