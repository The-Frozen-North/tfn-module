#include "inc_ai_combat"
#include "inc_ai_event"
#include "inc_ai"

void main()
{
    if (GetIsDead(OBJECT_SELF))
        return;

    SignalEvent(OBJECT_SELF, EventUserDefined(GS_EV_ON_CONVERSATION));

    if (GetLocalInt(OBJECT_SELF, "herbivore") == 1)
    {
        HerbivoreRunAway();
        return;
    }

    object oSpeaker = GetLastSpeaker();
    object oTarget  = OBJECT_INVALID;

    int bCanRespond = GetAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE) >= 6;

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
        if (bCanRespond && ! (GetLevelByClass(CLASS_TYPE_COMMONER) ||
               gsCBGetHasAttackTarget()) &&
            gsCBGetIsPerceived(oSpeaker))
        {
            gsCBDetermineAttackTarget(oSpeaker);
        }
        break;

    case 10001: //GS_AI_PVP
        oTarget = GetLocalObject(oSpeaker, "GS_PVP_TARGET");

        if (bCanRespond && GetIsObjectValid(oTarget) &&
            ! GetIsEnemy(oTarget) &&
            gsCBGetIsPerceived(oSpeaker))
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
        if (bCanRespond && ! GetIsEnemy(oSpeaker) &&
            gsCBGetIsPerceived(oSpeaker)) gsCBSetReinforcementRequestedBy(oSpeaker);
        break;
    case 10100: // GS_AI_INNOCENT_ATTACKED
    // commoners always run away
        if (GetTag(oSpeaker) == "brawler")
        {
            if (!gsC2GetHasEffect(EFFECT_TYPE_PETRIFY, OBJECT_SELF))
            {
                switch(d8())
                {
                    case 1: PlayVoiceChat(VOICE_CHAT_ATTACK); break;
                    case 2: PlayVoiceChat(VOICE_CHAT_CHEER); break;
                }
            }
        }
        else if (GetLocalInt(OBJECT_SELF, "fear") != 1 && GetClassByPosition(1, OBJECT_SELF) == CLASS_TYPE_COMMONER)
        {
            SetLocalInt(OBJECT_SELF, "fear", 1);
            DelayCommand(15.0, DeleteLocalInt(OBJECT_SELF, "fear"));
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectFrightened(), OBJECT_SELF, 30.0);
            if (!gsC2GetHasEffect(EFFECT_TYPE_PETRIFY, OBJECT_SELF))
            {
                switch(d6())
                {
                    case 1: PlayVoiceChat(VOICE_CHAT_HELP); break;
                    case 2: PlayVoiceChat(VOICE_CHAT_BATTLECRY1); break;
                    case 3: PlayVoiceChat(VOICE_CHAT_BATTLECRY2); break;
                }
            }
        }
    break;
    case 10200: //GS_AI_BASH_OBJECT
        if (GetLocalInt(OBJECT_SELF, "check_bash") != 1 &&
            !gsCBGetHasAttackTarget() &&
            !GetIsInCombat() &&
            !(GetClassByPosition(1, OBJECT_SELF) == CLASS_TYPE_COMMONER))
        {
            SetLocalInt(OBJECT_SELF, "check_bash", 1);
            DelayCommand(10.0, DeleteLocalInt(OBJECT_SELF, "check_bash"));
            if (!gsC2GetHasEffect(EFFECT_TYPE_PETRIFY, OBJECT_SELF))
            {
                switch(d6())
                {
                    case 1: PlayVoiceChat(VOICE_CHAT_ENEMIES); break;
                    case 2: PlayVoiceChat(VOICE_CHAT_SEARCH); break;
                    case 3: PlayVoiceChat(VOICE_CHAT_LOOKHERE); break;
                }
            }
            ActionMoveToObject(oSpeaker, FALSE, 2.0);
        }
    break;
    }

    SetListening(OBJECT_SELF, TRUE);
}

