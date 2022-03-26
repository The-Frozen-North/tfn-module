//::///////////////////////////////////////////////
//:: Associate: Heartbeat
//:: NW_CH_AC1.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Move towards master or wait for him
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 21, 2001
//:: Updated On: Jul 25, 2003 - Georg Zoeller
//:://////////////////////////////////////////////
#include "x0_inc_henai"

void DoBanter()
{
    if (GetIsDead(OBJECT_SELF) || GetIsInCombat(OBJECT_SELF) || IsInConversation(OBJECT_SELF) || GetIsFighting(OBJECT_SELF) || GetIsResting(OBJECT_SELF)) return;

    ExecuteScript("hen_banter", OBJECT_SELF);
}

void main()
{
    int nSelected = GetLocalInt(OBJECT_SELF, "selected");
    int nSelectedRemove = GetLocalInt(OBJECT_SELF, "selected_remove");
    if (nSelectedRemove > 2)
    {
        DeleteLocalInt(OBJECT_SELF, "selected");
        DeleteLocalInt(OBJECT_SELF, "selected_remove");
    }
    else if (nSelected > 1)
    {
        SetLocalInt(OBJECT_SELF, "selected_remove", nSelectedRemove + 1);
    }

    if (!GetIsInCombat() && GetLocalInt(OBJECT_SELF, "pending_destroy") == 1)
    {
        AssignCommand(OBJECT_SELF, ActionMoveToObject(GetNearestObject(OBJECT_TYPE_DOOR)));
        return;
    }

    if (GetCurrentAction() != ACTION_REST)
    {
        if (GetHasFeat(FEAT_SUMMON_FAMILIAR) && !GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_FAMILIAR)))
        {
            DecrementRemainingFeatUses(OBJECT_SELF, FEAT_SUMMON_FAMILIAR);
            SummonFamiliar();
        }

        if (GetHasFeat(FEAT_ANIMAL_COMPANION) && !GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION)))
        {
            DecrementRemainingFeatUses(OBJECT_SELF, FEAT_ANIMAL_COMPANION);
            SummonAnimalCompanion();
        }
    }

    string sScript = GetLocalString(OBJECT_SELF, "heartbeat_script");
    if (sScript != "") ExecuteScript(sScript);

    //1.72: this happens when the henchman is not hired and there is no pc in his area
    if (GetAILevel() == AI_LEVEL_VERY_LOW) return;

    if (GetIsObjectValid(GetMaster(OBJECT_SELF)) && GetStringLeft(GetResRef(OBJECT_SELF), 3) == "hen")
    {
        int nBanter = GetLocalInt(OBJECT_SELF, "banter");

        if (nBanter >= 100)
        {
            DelayCommand(IntToFloat(d20())+IntToFloat(d10())/10.0, DoBanter());
            DeleteLocalInt(OBJECT_SELF, "banter");
        }
        else
        {
            SetLocalInt(OBJECT_SELF, "banter", nBanter+d4());
        }
    }

    //1.72: Check to see if should re-enter stealth mode
    if (!GetIsInCombat())
    {
        if(GetLocalInt(OBJECT_SELF, "X2_HENCH_STEALTH_MODE") > 0 && !GetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH))
        {
            SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, TRUE);
        }
    }

    object oMaster = GetMaster();
    if(!GetAssociateState(NW_ASC_IS_BUSY))
    {

        //Seek out and disable undisabled traps
        object oTrap = GetNearestTrapToObject();
        if (GetIsObjectValid(oTrap) && bkAttemptToDisarmTrap(oTrap)) return; // succesful trap found and disarmed

        if(GetIsObjectValid(oMaster) &&
            GetCurrentAction(OBJECT_SELF) != ACTION_FOLLOW &&
            GetCurrentAction(OBJECT_SELF) != ACTION_DISABLETRAP &&
            GetCurrentAction(OBJECT_SELF) != ACTION_OPENLOCK &&
            GetCurrentAction(OBJECT_SELF) != ACTION_REST &&
            GetCurrentAction(OBJECT_SELF) != ACTION_ATTACKOBJECT)
        {
            if(
               !GetIsObjectValid(GetAttackTarget()) &&
               !GetIsObjectValid(GetAttemptedSpellTarget()) &&
               !GetIsObjectValid(GetAttemptedAttackTarget()) &&
               !GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE))
              )
            {
                if (GetIsObjectValid(oMaster) == TRUE)
                {
                    if(GetDistanceToObject(oMaster) > 6.0)
                    {
                        if(GetAssociateState(NW_ASC_HAVE_MASTER))
                        {
                            if(!GetIsFighting(OBJECT_SELF))
                            {
                                if(!GetAssociateState(NW_ASC_MODE_STAND_GROUND))
                                {
                                    if(GetDistanceToObject(GetMaster()) > GetFollowDistance())
                                    {
                                        ClearActions(CLEAR_NW_CH_AC1_49);
                                        if(GetAssociateState(NW_ASC_AGGRESSIVE_STEALTH) || GetAssociateState(NW_ASC_AGGRESSIVE_SEARCH))
                                        {
                                             if(GetAssociateState(NW_ASC_AGGRESSIVE_STEALTH))
                                             {
                                                //ActionUseSkill(SKILL_HIDE, OBJECT_SELF);
                                                //ActionUseSkill(SKILL_MOVE_SILENTLY,OBJECT_SELF);
                                             }
                                             if(GetAssociateState(NW_ASC_AGGRESSIVE_SEARCH))
                                             {
                                                ActionUseSkill(SKILL_SEARCH, OBJECT_SELF);
                                             }
                                             //MyPrintString("GENERIC SCRIPT DEBUG STRING ********** " + "Assigning Force Follow Command with Search and/or Stealth");
                                             ActionForceFollowObject(oMaster, GetFollowDistance());
                                        }
                                        else
                                        {
                                             //MyPrintString("GENERIC SCRIPT DEBUG STRING ********** " + "Assigning Force Follow Normal");
                                             ActionForceFollowObject(oMaster, GetFollowDistance());
                                             //ActionForceMoveToObject(GetMaster(), TRUE, GetFollowDistance(), 5.0);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else if(!GetAssociateState(NW_ASC_MODE_STAND_GROUND))
                {
                    if(GetIsObjectValid(oMaster))
                    {
                        if(GetCurrentAction(oMaster) != ACTION_REST)
                        {
                            ClearActions(CLEAR_NW_CH_AC1_81);
                            if(GetAssociateState(NW_ASC_AGGRESSIVE_STEALTH) || GetAssociateState(NW_ASC_AGGRESSIVE_SEARCH))
                            {
                                 if(GetAssociateState(NW_ASC_AGGRESSIVE_STEALTH))
                                 {
                                    //ActionUseSkill(SKILL_HIDE, OBJECT_SELF);
                                    //ActionUseSkill(SKILL_MOVE_SILENTLY,OBJECT_SELF);
                                 }
                                 if(GetAssociateState(NW_ASC_AGGRESSIVE_SEARCH))
                                 {
                                    ActionUseSkill(SKILL_SEARCH, OBJECT_SELF);
                                 }
                                 //MyPrintString("GENERIC SCRIPT DEBUG STRING ********** " + "Assigning Force Follow Command with Search and/or Stealth");
                                 ActionForceFollowObject(oMaster, GetFollowDistance());
                            }
                            else
                            {
                                 //MyPrintString("GENERIC SCRIPT DEBUG STRING ********** " + "Assigning Force Follow Normal");
                                 ActionForceFollowObject(oMaster, GetFollowDistance());
                            }
                        }
                    }
                }
            }
            else if(!GetIsObjectValid(GetAttackTarget()) &&
               !GetIsObjectValid(GetAttemptedSpellTarget()) &&
               !GetIsObjectValid(GetAttemptedAttackTarget()) &&
               !GetAssociateState(NW_ASC_MODE_STAND_GROUND))
            {
                //DetermineCombatRound();
            }

        }
        // * if I am dominated, ask for some help
        if (GetHasEffect(EFFECT_TYPE_DOMINATED, OBJECT_SELF) == TRUE && GetIsEncounterCreature(OBJECT_SELF) == FALSE)
        {
            SendForHelp();
        }
    }
}

