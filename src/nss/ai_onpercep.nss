#include "inc_ai_combat"
#include "inc_ai_event"

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
        FastBuff();
        SpeakString("GS_AI_ATTACK_TARGET", TALKVOLUME_SILENT_TALK);
// only determine a new combat round if they currently don't have a target
        if (!gsCBGetHasAttackTarget())
            gsCBDetermineCombatRound(oPerceived);
    }
}
