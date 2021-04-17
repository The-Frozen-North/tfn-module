//::///////////////////////////////////////////////
//:: Community Patch Combat AI engine
//:: 70_ai_generic
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
This is the generic combat AI detached into new script to allow modify the AI
routines without need to recompile all creature events scripts.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.72
//:: Created On: 22-7-2014
//:://////////////////////////////////////////////

#include "70_inc_ai"
#include "nw_i0_generic"

void main()
{
    object oIntruder = GetLocalObject(OBJECT_SELF,"Intruder");
    int nAI_Difficulty = GetLocalInt(OBJECT_SELF,"AI_Difficulty");

    // MyPrintString("************** DETERMINE COMBAT ROUND START *************");
    // MyPrintString("**************  " + GetTag(OBJECT_SELF) + "  ************");

    // ----------------------------------------------------------------------------------------
    // May 2003
    // Abort out of here, if petrified
    // ----------------------------------------------------------------------------------------
    if (GetHasEffect(EFFECT_TYPE_PETRIFY, OBJECT_SELF))
    {
        return;
    }

    // ----------------------------------------------------------------------------------------
    // Oct 06/2003 - Georg Zoeller,
    // Fix for ActionRandomWalk blocking the action queue under certain circumstances
    // ----------------------------------------------------------------------------------------
    if (GetCurrentAction() == ACTION_RANDOMWALK)
    {
        ClearAllActions();
    }

    // ----------------------------------------------------------------------------------------
    // July 27/2003 - Georg Zoeller,
    // Added to allow a replacement for determine combat round
    // If a creature has a local string variable named X2_SPECIAL_COMBAT_AI_SCRIPT
    // set, the script name specified in the variable gets run instead
    // see x2_ai_behold for details:
    // ----------------------------------------------------------------------------------------
    string sSpecialAI = GetLocalString(OBJECT_SELF,"X2_SPECIAL_COMBAT_AI_SCRIPT");
    if (sSpecialAI != "")
    {
        SetLocalObject(OBJECT_SELF,"X2_NW_I0_GENERIC_INTRUDER", oIntruder);
        ExecuteScript(sSpecialAI, OBJECT_SELF);
        if (GetLocalInt(OBJECT_SELF,"X2_SPECIAL_COMBAT_AI_SCRIPT_OK"))
        {
            DeleteLocalInt(OBJECT_SELF,"X2_SPECIAL_COMBAT_AI_SCRIPT_OK");
            return;
        }
    }

    // ----------------------------------------------------------------------------------------
    // DetermineCombatRound: EVALUATIONS
    // ----------------------------------------------------------------------------------------
    if(GetAssociateState(NW_ASC_IS_BUSY))
    {
        return;
    }

    if(BashDoorCheck(oIntruder)) {return;}

    // ----------------------------------------------------------------------------------------
    // BK: stop fighting if something bizarre that shouldn't happen, happens
    // ----------------------------------------------------------------------------------------

    if (bkEvaluationSanityCheck(oIntruder, GetFollowDistance()))
        return;

    // ** Store HOw Difficult the combat is for this round
    int nDiff = GetCombatDifficulty();
    SetLocalInt(OBJECT_SELF, "NW_L_COMBATDIFF", nDiff);

    // MyPrintString("COMBAT: " + IntToString(nDiff));

    // ----------------------------------------------------------------------------------------
    // If no special target has been passed into the function
    // then choose an appropriate target
    // ----------------------------------------------------------------------------------------
    if (!GetIsObjectValid(oIntruder) || GetIsDead(oIntruder) || GetArea(oIntruder) != GetArea(OBJECT_SELF) || GetHasSpellEffect(SPELL_ETHEREALNESS,oIntruder))
        oIntruder = bkAcquireTarget();

    if(GetIsDead(oIntruder) || GetHasSpellEffect(SPELL_ETHEREALNESS,oIntruder))
    {
        // ----------------------------------------------------------------------------------------
        // If for some reason my target is dead, then leave
        // the poor guy alone. Jeez. What kind of monster am I?
        // ----------------------------------------------------------------------------------------
        if(GetIsObjectValid(oIntruder))
        {
            ClearAllActions();
        }
        return;
    }

    // ----------------------------------------------------------------------------------------
    /*
       JULY 11 2003
       If in combat round already (variable set) do not enter it again.
       This is meant to prevent multiple calls to DetermineCombatRound
       from happening during the *same* round.

       This variable is turned on at the start of this function call.
       It is turned off at each "return" point for this function
       */
    // ----------------------------------------------------------------------------------------
    if (__InCombatRound())
    {
        return;
    }

    __TurnCombatRoundOn(TRUE);

    // ----------------------------------------------------------------------------------------
    // DetermineCombatRound: ACTIONS
    // ----------------------------------------------------------------------------------------
    if(GetIsObjectValid(oIntruder))
    {
        if(GetActionMode(OBJECT_SELF,ACTION_MODE_DEFENSIVE_CAST))//1.72: needs to be disabled after every cast
        {
            SetActionMode(OBJECT_SELF,ACTION_MODE_DEFENSIVE_CAST,FALSE);
        }

        if(TalentPersistentAbilities()) // * Will put up things like Auras quickly
        {
            __TurnCombatRoundOn(FALSE);
            if(GetGameDifficulty() == GAME_DIFFICULTY_DIFFICULT || GetAILevel() >= AI_LEVEL_HIGH)
            {
                ActionDoCommand(DetermineCombatRound(oIntruder));
            }
            return;
        }

        //1.70: BBoD clever behavior
        if (GetAILevel(OBJECT_SELF) >= AI_LEVEL_HIGH && GetResRef(oIntruder) == "x2_s_bblade")
        {
            if(GetHasSpell(SPELL_MORDENKAINENS_DISJUNCTION) || GetHasSpell(SPELL_DISMISSAL))
            {
                ClearAllActions();
                ActionCastSpellAtObject(GetHasSpell(SPELL_DISMISSAL) ? SPELL_DISMISSAL : SPELL_MORDENKAINENS_DISJUNCTION,oIntruder);
                __TurnCombatRoundOn(FALSE);
                return;
            }
            else
            {   //still creature can have a scroll with one of these spell
                talent tUse = GetCreatureTalent(TALENT_CATEGORY_HARMFUL_AREAEFFECT_INDISCRIMINANT,0);
                int nRnd;
                while(GetIsTalentValid(tUse) && nRnd++ < 10)
                {
                    if(GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL && (GetIdFromTalent(tUse) == SPELL_DISMISSAL || GetIdFromTalent(tUse) == SPELL_MORDENKAINENS_DISJUNCTION))
                    {
                        ClearAllActions();
                        ActionUseTalentOnObject(tUse,oIntruder);
                        __TurnCombatRoundOn(FALSE);
                        return;
                    }
                    tUse = GetCreatureTalent(TALENT_CATEGORY_HARMFUL_AREAEFFECT_INDISCRIMINANT,0);
                }
                object oNewTarget = ChooseDifferentTarget(oIntruder);
                if(GetIsObjectValid(oNewTarget) && oNewTarget != oIntruder)
                    oIntruder = oNewTarget;
            }
        }

        // ----------------------------------------------------------------------------------------
        // BK September 2002
        // If a succesful tactic has been chosen then
        // exit this function directly
        // ----------------------------------------------------------------------------------------

        if (chooseTactics(oIntruder) == 99)
        {
            __TurnCombatRoundOn(FALSE);
            return;
        }

        // ----------------------------------------------------------------------------------------
        // This check is to make sure that people do not drop out of
        // combat before they are supposed to.
        // ----------------------------------------------------------------------------------------

        DetermineCombatRound(GetNearestSeenEnemy());
        return;
    }
     __TurnCombatRoundOn(FALSE);

    // ----------------------------------------------------------------------------------------
    // This is a call to the function which determines which
    // way point to go back to.
    // ----------------------------------------------------------------------------------------
    ClearActions(CLEAR_NW_I0_GENERIC_658);
    SetLocalObject(OBJECT_SELF,"NW_GENERIC_LAST_ATTACK_TARGET",OBJECT_INVALID);
    WalkWayPoints();
}
