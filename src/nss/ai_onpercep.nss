#include "inc_ai_combat"
#include "inc_ai_event"
//#include "inc_crime"

/*
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
        //case 6: PlayVoiceChat(VOICE_CHAT_THREATEN);   break;
        }
    }
}
*/
//----------------------------------------------------------------
void main()
{
    object oPerceived = GetLastPerceived();
    if (GetLocalInt(oPerceived, "AI_IGNORE")) return; // Scrying / sent images.

    SignalEvent(OBJECT_SELF, EventUserDefined(GS_EV_ON_PERCEPTION));

    if (GetLastPerceptionVanished() || GetLastPerceptionInaudible())
    {
        if (GetIsEnemy(oPerceived) && !gsCBGetHasAttackTarget())
        {
           SetActionMode(OBJECT_SELF, ACTION_MODE_DETECT, TRUE);
        }
              else if (gsCBGetLastAttackTarget() == oPerceived && GetLastPerceptionVanished())
                {
                  // Our current target vanished.
                if (gsCBGetIsPerceived(oPerceived))
                  {
                    // We can still hear them! Keep chasing them.
                  }
                else
                  {
                    // Look for another target.  Since gsCBGetIsPerceived fails
                    // we'll pick someone else.
                    gsCBDetermineCombatRound();
                  }
                }
        return;
    }

    if (GetIsEnemy(oPerceived) )
    {
        // Summons etc shouldn't attack before their PC - breaks pvp rules.
        if (GetIsPC(oPerceived) && GetIsPC(GetMaster(OBJECT_SELF)) &&
             !GetIsInCombat(GetMaster(OBJECT_SELF))) return;

        FastBuff();


        if (gsCBGetHasAttackTarget())
        {
            object oTarget = gsCBGetLastAttackTarget();

            // If the creature we just spotted (or which just vanished) isn't our
            // current target, and the enemy we spotted is (much) closer than
            // our current target, switch targets.
            if (oPerceived != oTarget &&
                GetDistanceToObject(oPerceived) + 5.0 <=
                GetDistanceToObject(oTarget))
            {
                gsCBDetermineCombatRound(oPerceived);
                //gsPlayVoiceChat();
            }
        }
        else
        {
            gsCBDetermineCombatRound(oPerceived);
            //gsPlayVoiceChat();
        }
    }

}
