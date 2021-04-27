#include "inc_ai_combat"
#include "inc_ai_event"
//#include "inc_divination"

void main()
{
    SignalEvent(OBJECT_SELF, EventUserDefined(GS_EV_ON_PHYSICAL_ATTACKED));

    object oAttacker = GetLastAttacker();

    if (GetIsPC(oAttacker) || GetIsPC(GetMaster(oAttacker))) SetLocalInt(OBJECT_SELF, "player_tagged", 1);

    if (!gsCBGetHasAttackTarget() && d100() > 75 && GetAbilityModifier(ABILITY_INTELLIGENCE, OBJECT_SELF) >= -2)
        PlayVoiceChat(VOICE_CHAT_ENEMIES);

    if (gsCBGetHasAttackTarget())
    {
        object oTarget = gsCBGetLastAttackTarget();

        if (oAttacker != oTarget &&
            (gsCBGetIsFollowing() ||
             GetDistanceToObject(oAttacker) <=
             GetDistanceToObject(oTarget) + 5.0))
        {
            gsCBDetermineCombatRound(oAttacker);
        }
    }
    else
    {
        gsCBDetermineCombatRound(oAttacker);
    }

}

