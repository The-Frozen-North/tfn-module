#include "inc_ai_combat"
#include "inc_ai_event"

void gsPlayVoiceChat()
{
    if (Random(100) >= 75)
    {
        switch (Random(7))
        {
        case 0: PlayVoiceChat(VOICE_CHAT_ATTACK);     break;
        case 1: PlayVoiceChat(VOICE_CHAT_BATTLECRY1); break;
        case 2: PlayVoiceChat(VOICE_CHAT_BATTLECRY2); break;
        case 3: PlayVoiceChat(VOICE_CHAT_BATTLECRY3); break;
        case 4: PlayVoiceChat(VOICE_CHAT_ENEMIES);    break;
        case 5: PlayVoiceChat(VOICE_CHAT_TAUNT);      break;
        case 6: PlayVoiceChat(VOICE_CHAT_THREATEN);   break;
        }
    }
}


//----------------------------------------------------------------
void main()
{
    SignalEvent(OBJECT_SELF, EventUserDefined(GS_EV_ON_PERCEPTION));

    object oPerceived = GetLastPerceived();

    if (GetLastPerceptionVanished() ||
        GetLastPerceptionInaudible())
    {
// Added a check if the target is in stealth mode.
        if (GetIsEnemy(oPerceived) && GetActionMode(oPerceived, ACTION_MODE_STEALTH) &&
            ! gsCBGetHasAttackTarget())
        {
            SetActionMode(OBJECT_SELF, ACTION_MODE_DETECT, TRUE);
        }
        return;
    }

    if (GetIsEnemy(oPerceived))
    {
        if (gsCBGetHasAttackTarget())
        {
            object oTarget = gsCBGetLastAttackTarget();
            FastBuff();

            if (oPerceived != oTarget &&
                GetDistanceToObject(oPerceived) + 5.0 <=
                GetDistanceToObject(oTarget))
            {
                gsCBDetermineCombatRound(oPerceived);
                gsPlayVoiceChat();
            }
        }
        else
        {
            gsCBDetermineCombatRound(oPerceived);
            gsPlayVoiceChat();
        }
    }
}
