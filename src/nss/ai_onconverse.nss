#include "inc_ai_combat"
#include "inc_ai_event"

void main()
{
    SignalEvent(OBJECT_SELF, EventUserDefined(GS_EV_ON_CONVERSATION));

    object oSpeaker = GetLastSpeaker();
    object oTarget  = OBJECT_INVALID;

    SetListening(OBJECT_SELF, FALSE);

    switch (GetListenPatternNumber())
    {
    case -1:
        if (! gsCBGetHasAttackTarget() &&
            gsCBGetIsPerceived(oSpeaker))
        {
            ClearAllActions(TRUE);
            BeginConversation();
        }
        break;

    case 10000: //GS_AI_ATTACK_TARGET
        if (! (GetLevelByClass(CLASS_TYPE_COMMONER) ||
               gsCBGetHasAttackTarget()))
        {
            gsCBDetermineAttackTarget(oSpeaker);
        }
        break;

    case 10001: //GS_AI_PVP
        oTarget = GetLocalObject(oSpeaker, "GS_PVP_TARGET");

        if (GetIsObjectValid(oTarget) &&
            ! GetIsEnemy(oTarget))
        {
            gsCBDetermineCombatRound(oSpeaker);
        }
        break;

    case 10002: //GS_AI_THEFT
        if (GetIsSkillSuccessful(OBJECT_SELF, SKILL_SPOT, GetSkillRank(SKILL_PICK_POCKET, oSpeaker) + d20()))
        {
            gsCBDetermineCombatRound(oSpeaker);
        }
        break;

    case 10003: //GS_AI_REQUEST_REINFORCEMENT
        if (! GetIsEnemy(oSpeaker)) gsCBSetReinforcementRequestedBy(oSpeaker);
        break;
    case 10100: // GS_AI_INNOCENT_ATTACKED
    // commoners always run away
        if (GetLocalInt(OBJECT_SELF, "fear") != 1 && GetClassByPosition(1, OBJECT_SELF) == CLASS_TYPE_COMMONER)
        {
            SetLocalInt(OBJECT_SELF, "fear", 1);
            DelayCommand(15.0, DeleteLocalInt(OBJECT_SELF, "fear"));
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectFrightened(), OBJECT_SELF, 30.0);
            switch(d6())
            {
                case 1: PlayVoiceChat(VOICE_CHAT_HELP); break;
                case 2: PlayVoiceChat(VOICE_CHAT_BATTLECRY1); break;
                case 3: PlayVoiceChat(VOICE_CHAT_BATTLECRY2); break;
            }
        }
    break;
    }

    SetListening(OBJECT_SELF, TRUE);
}

