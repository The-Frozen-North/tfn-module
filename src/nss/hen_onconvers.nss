//::///////////////////////////////////////////////
//:: Associate: On Dialogue
//:: NW_CH_AC4
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Determines the course of action to be taken
    by the generic script after dialogue or a
    shout is initiated.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 24, 2001
//:://////////////////////////////////////////////
/*
Patch 1.72
- fixed bug that allowed to speak with associate in disable states such as petrify
- HotU associate conversation will now be used even outside of the HotU campaign
*/

#include "x0_inc_henai"
#include "inc_henchman"
#include "x2_inc_switches"

// * This function checks to make sure no
// * dehibilating effects are on the player that should
// * Don't use getcommandable for this since the dying system
// * will sometimes leave a player in a noncommandable state
int AbleToTalk(object oSelf)
{
    if (GetLocalInt(oSelf, "pending_destroy") == 1)
    {
        AssignCommand(OBJECT_SELF, ActionMoveToObject(GetNearestObject(OBJECT_TYPE_DOOR)));
        return FALSE;
    }

    effect eSearch = GetFirstEffect(oSelf);
    while(GetIsEffectValid(eSearch))
    {
        switch(GetEffectType(eSearch))
        {
            case EFFECT_TYPE_CONFUSED:
            case EFFECT_TYPE_DOMINATED:
            case EFFECT_TYPE_PETRIFY:
            case EFFECT_TYPE_PARALYZE:
            case EFFECT_TYPE_STUNNED:
            case EFFECT_TYPE_FRIGHTENED:
            case EFFECT_TYPE_DAZED:
            case EFFECT_TYPE_CHARMED:
            case EFFECT_TYPE_TURNED:
            case EFFECT_TYPE_CUTSCENE_PARALYZE:
            case EFFECT_TYPE_SLEEP:
            return FALSE;
        }
        switch(GetEffectSpellId(eSearch))
        {
            case SPELL_BIGBYS_FORCEFUL_HAND:
            case SPELL_BALAGARNSIRONHORN:
            return FALSE;
        }
        eSearch = GetNextEffect(oSelf);
    }
    return TRUE;
}

void main()
{
    object oMaster = GetMaster();
    int nMatch = GetListenPatternNumber();
    object oShouter = GetLastSpeaker();
    object oIntruder;



    if (nMatch == ASSOCIATE_COMMAND_LEAVEPARTY)
    {
        DelayCommand(0.1, AddHenchman(oMaster));
        SendMessageToPC(oMaster, "Henchmen cannot be dismissed from the radial menu");
    }

    if (nMatch == 200 && GetIsFriend(oShouter)) // PARTY_I_WAS_ATTACKED
    {
        HenchmenCombatRound(GetLastHostileActor(oShouter));
    }

    if (nMatch == -1) {
        if(AbleToTalk(OBJECT_SELF) && GetCurrentAction() != ACTION_OPENLOCK)
        {
            ClearActions(CLEAR_NW_CH_AC4_28);

            // * if in XP2, use an alternative dialog file
            string sDialog = "";
            if (GetLocalInt(GetModule(), "X2_L_XP2") ==  1 || (GetAssociateType(OBJECT_SELF) != ASSOCIATE_TYPE_NONE && GetAssociateType(OBJECT_SELF) != ASSOCIATE_TYPE_HENCHMAN))
            {
                sDialog = "x2_associate";
            }
            BeginConversation(sDialog);
        }
    } else {
        // listening pattern matched
        if (GetIsObjectValid(oShouter) && oMaster == oShouter)
        {
            SetCommandable(TRUE);
            bkRespondToHenchmenShout(oShouter, nMatch, oIntruder, TRUE);
        }
    }

    // Signal user-defined event
    if(GetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT)) {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_DIALOGUE));
    }
}

