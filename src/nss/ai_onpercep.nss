#include "inc_ai_combat"
#include "inc_ai_event"

//----------------------------------------------------------------

void main()
{
    SignalEvent(OBJECT_SELF, EventUserDefined(GS_EV_ON_PERCEPTION));

    object oPerceived = GetLastPerceived();

    int nHeard = GetLastPerceptionHeard();
    
    string sScript = GetLocalString(OBJECT_SELF, "perception_script");
    if (sScript != "")
    {
        ExecuteScript(sScript, OBJECT_SELF);
    }

// don't return if heard
    if ((GetLastPerceptionVanished() || GetLastPerceptionInaudible()) && !nHeard)
    {
// Added a check if the target is in stealth mode.
        if (GetIsEnemy(oPerceived) && GetActionMode(oPerceived, ACTION_MODE_STEALTH) &&
            ! gsCBGetHasAttackTarget())
        {
            SetActionMode(OBJECT_SELF, ACTION_MODE_DETECT, TRUE);
        }
        return;
    }

    if (GetIsEnemy(oPerceived)&& !gsCBGetIsInCombat())
    {
        FastBuff();
// seen the enemy? go for the eyes boo!
        if (GetLastPerceptionSeen())
        {
            SpeakString("GS_AI_ATTACK_TARGET", TALKVOLUME_SILENT_TALK);
    // only determine a new combat round if they currently don't have a target
            if (!gsCBGetHasAttackTarget())
                gsCBDetermineCombatRound(oPerceived);
        }
        else if (nHeard)
// can't see the enemy but heard them? let's move to them to investigate
        {
            float fDistance = GetDistanceToObject(oPerceived);

// attack immediately if within range
            if (!gsCBGetHasAttackTarget() && fDistance >= 0.0 && fDistance <= 10.0)
            {
                gsCBDetermineCombatRound(oPerceived);
            }
            else
            {
                ActionMoveToObject(oPerceived, TRUE, 0.0);
            }
        }
    }
}
