//::///////////////////////////////////////////////
//:: Community Patch Combat AI engine
//:: 70_ai_henchman
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

#include "x0_inc_henai"

void DoCombatVoice()
{
    if (GetIsDead(OBJECT_SELF)) return;

// don't proceed if there is a cooldown
    if (GetLocalInt(OBJECT_SELF, "battlecry_cd") == 1)
        return;

    SetLocalInt(OBJECT_SELF, "battlecry_cd", 1);

    DelayCommand(10.0+IntToFloat(d10()), DeleteLocalInt(OBJECT_SELF, "battlecry_cd"));

    string sBattlecryScript = GetLocalString(OBJECT_SELF, "battlecry_script");
    if (sBattlecryScript != "")
    {
        ExecuteScript(sBattlecryScript, OBJECT_SELF);
    }
    else
    {
        int nRand = 40;
        if (GetLocalInt(OBJECT_SELF, "boss") == 1) nRand = nRand/2;

        switch (Random(nRand))
        {
            case 0: PlayVoiceChat(VOICE_CHAT_BATTLECRY1, OBJECT_SELF); break;
            case 1: PlayVoiceChat(VOICE_CHAT_BATTLECRY2, OBJECT_SELF); break;
            case 2: PlayVoiceChat(VOICE_CHAT_BATTLECRY3, OBJECT_SELF); break;
            case 3: PlayVoiceChat(VOICE_CHAT_ATTACK, OBJECT_SELF); break;
            case 4: PlayVoiceChat(VOICE_CHAT_TAUNT, OBJECT_SELF); break;
            case 5: PlayVoiceChat(VOICE_CHAT_LAUGH, OBJECT_SELF); break;
        }
    }
}

void main()
{
    object oIntruder = GetLocalObject(OBJECT_SELF,"Intruder");

    // * If someone has surrendered, then don't attack them.
    // * feb 25 2003
    if (GetIsObjectValid(oIntruder))
    {
        if (!GetIsEnemy(oIntruder))
        {
            ClearActions(999, TRUE);
            ActionAttack(OBJECT_INVALID);
            return;
        }
    }
    //SpeakString("in combat round. Is an enemy");
    // * This is the nearest enemy
    object oNearestTarget = GetNearestSeenEnemy();//1.72: using GetNearestSeenEnemy now in order to apply fix for EE issue

    //    SpeakString("Henchman combat dude");

    // ****************************************
    // SETUP AND SANITY CHECKS (Quick Returns)
    // ****************************************

    // * BK: stop fighting if something bizarre that shouldn't happen, happens
    if (bkEvaluationSanityCheck(oIntruder, GetFollowDistance())) return;

    if(GetAssociateState(NW_ASC_IS_BUSY) || GetAssociateState(NW_ASC_MODE_DYING))
    {
        return;
    }

    // June 2/04: Fix for when henchmen is told to use stealth until next fight
    if(GetLocalInt(OBJECT_SELF, "X2_HENCH_STEALTH_MODE")==2)
        SetLocalInt(OBJECT_SELF, "X2_HENCH_STEALTH_MODE", 0);

    // MODIFIED FEBRUARY 13 2003
    // The associate will not engage in battle if in Stand Ground mode unless
    // he takes damage
    if(GetAssociateState(NW_ASC_MODE_STAND_GROUND))//1.72: no longer will associates breaks the stand ground command
    {
        return;
    }

    if(BashDoorCheck(oIntruder)) return;

    // ** Store how difficult the combat is for this round
    int nDiff = GetCombatDifficulty();
    SetLocalInt(OBJECT_SELF, "NW_L_COMBATDIFF", nDiff);

    object oMaster = GetMaster();

    //1.72:  If in combat round already (variable set) do not enter it again.
    if (__InCombatRound())
    {
        return;
    }


    // * Do henchmen specific things if I am a henchman otherwise run default AI
    if (GetIsObjectValid(oMaster))
    {
        /*
        if(GetActionMode(OBJECT_SELF,ACTION_MODE_DEFENSIVE_CAST))//1.72: needs to be disabled after every cast
        {
            SetActionMode(OBJECT_SELF,ACTION_MODE_DEFENSIVE_CAST,FALSE);
        }
        */
        // *******************************************
        // Healing
        // *******************************************
        // The FIRST PRIORITY: self-preservation
        // The SECOND PRIORITY: heal master;
        if (bkCombatAttemptHeal())
        {
            return;
        }

        // NEXT priority: follow or return to master for up to three rounds.
        if (bkCombatFollowMaster())
        {
            return;
        }

        //5. This check is to see if the master is being attacked and in need of help
        // * Guard Mode -- only attack if master attacking
        // * or being attacked.
        if(GetAssociateState(NW_ASC_MODE_DEFEND_MASTER))
        {
            oIntruder = GetLastHostileActor(GetMaster());
            if(!GetIsObjectValid(oIntruder))
            {
                //oIntruder = GetGoingToBeAttackedBy(GetMaster());

                // MODIFIED Major change. Defend is now Defend only if I attack
                // February 11 2003

                oIntruder = GetAttackTarget(GetMaster());
                // * February 11 2003
                // * means that the player was invovled in a battle

                if (GetIsObjectValid(oIntruder) || GetLocalInt(OBJECT_SELF, "X0_BATTLEJOINEDMASTER") == TRUE)
                {

                    SetLocalInt(OBJECT_SELF, "X0_BATTLEJOINEDMASTER", TRUE);
                    // * This is turned back to false whenever he hits the end of combat
                    if (!GetIsObjectValid(oIntruder))
                    {
                        oIntruder = oNearestTarget;
                        if (!GetIsObjectValid(oIntruder))
                        {
                            //* turn off the "I am in battle" sub-mode
                            SetLocalInt(OBJECT_SELF, "X0_BATTLEJOINEDMASTER", FALSE);
                        }
                    }
                }
                // * Exit out and do nothing this combat round
                else
                {
                  // * August 2003: If I'm getting beaten up and my master
                  // * is just standing around, I should attempt, one last time
                  // * to see if there is someone I should be fighting
                  oIntruder = GetLastAttacker(OBJECT_SELF);

                  // * EXIT CONDITION = There really is not anyone
                  // * near me to justify going into combat
                  if (!GetIsObjectValid(oIntruder))
                  {
                    return;
                  }
                }
            }
        }
/*
        int iAmHenchman = FALSE;
        if (GetAssociateType(OBJECT_SELF) == ASSOCIATE_TYPE_HENCHMAN)
        {
            iAmHenchman = TRUE;
        }
        if (iAmHenchman)
*/
        if (GetAssociateType(OBJECT_SELF) == ASSOCIATE_TYPE_HENCHMAN)
        {
            // 5% chance per round of speaking the relative challenge of the encounter.
            if (d100() > 95) {
                if (nDiff <= 1) VoiceLaugh(TRUE);
             // MODIFIED February 7 2003. This was confusing testing
             //   else if (nDiff <= 4) VoiceThreaten(TRUE);
             //   else VoiceBadIdea();
            }
        } // is a henchman

        // I am a familiar FLEE if tough
        /*
        MODIFIED FEB10 2003. Q/A hated this.

        int iAmFamiliar = (GetAssociate(ASSOCIATE_TYPE_FAMILIAR,oMaster) == OBJECT_SELF);
        if (iAmFamiliar) {
            // Run away from tough enemies
            if (nDiff >= BK_FAMILIAR_COWARD || GetPercentageHPLoss(OBJECT_SELF) < 40) {
                VoiceFlee();

                ClearActions(CLEAR_X0_INC_HENAI_HCR);
                ActionMoveAwayFromObject(oNearestTarget, TRUE, 40.0);
                return;
            }
        }
        */
    } // * is an associate


    // Fall through to generic combat

    // * only go into determinecombatround if there's a valid enemy nearby
    // * feb 26 2003: To prevent henchmen from resuming combat
    if (GetIsObjectValid(oIntruder)) DelayCommand(IntToFloat(d10())/10.0, DoCombatVoice());

    if (GetIsObjectValid(oIntruder) || GetIsObjectValid(oNearestTarget)) DetermineCombatRound(oIntruder);

}
