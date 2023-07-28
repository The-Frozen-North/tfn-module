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
//#include "x0_inc_henai"
#include "inc_henchman"
#include "inc_follower"
#include "inc_horse"
#include "nwnx_creature"
#include "j_inc_henchman"
#include "inc_ai_combat"
#include "nwnx_area"
#include "j_inc_generic_ai"

// we are not using Jasperre's AI script for heartbeats

void DoBanter()
{
    if (GetIsDead(OBJECT_SELF) || GetIsInCombat(OBJECT_SELF) || IsInConversation(OBJECT_SELF) || GetIsFighting() || GetIsResting(OBJECT_SELF)) return;

    ExecuteScript("hen_banter", OBJECT_SELF);
}

void main()
{
    if (GetIsDead(OBJECT_SELF)) return;
    if (GetHasEffect(EFFECT_TYPE_PETRIFY, OBJECT_SELF)) return;

    // attempt to make the ai more responsive
    if (GetIsInCombat())
    {
        ExecuteScript("j_ai_detercombat");

        DelayCommand(3.0, ExecuteScript("j_ai_detercombat"));
    }
    // const int NWNX_AREA_PVP_SETTING_FULL_PVP            = 2;
    // const int NWNX_AREA_PVP_SETTING_SERVER_DEFAULT      = 3;
    // this is considered a dangerous area, start buffing
    else if (NWNX_Area_GetPVPSetting(GetArea(OBJECT_SELF)) >= 2) 
    {
        FastBuff(FALSE, FALSE, FALSE); // do not do low duration buffs. no item buffs because we cant tell if it is buffed yet     
    }

    DetermineHenchmanMount(OBJECT_SELF);

// this routine should make the henchman go straight to the stored master if it's dead in an attempt to revive them
// keep this high up in case any other routines stop and return early
    object oStoredMaster;

    if (GetStringLeft(GetResRef(OBJECT_SELF), 3) == "hen")
    {
        oStoredMaster = GetMasterByUUID(OBJECT_SELF);
    }
    else
    {
        oStoredMaster = GetMasterByStoredUUID(OBJECT_SELF);
    }

    // After curing petrification, this will add them back to the party
    if (!GetIsObjectValid(GetMaster(OBJECT_SELF)))
    {
        SetMaster(OBJECT_SELF, oStoredMaster);
    }

    // That bebilith can unequip shields/armour
    if (!GetIsInCombat(OBJECT_SELF))
    {
        object oShield = GetLocalObject(OBJECT_SELF, "hen_shield");
        if (!GetIsObjectValid(oShield))
        {
            oShield = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, OBJECT_SELF);
            if (GetIsObjectValid(oShield))
            {
                SetLocalObject(OBJECT_SELF, "hen_shield", oShield);
            }
        }
        else if (GetItemInSlot(INVENTORY_SLOT_LEFTHAND, OBJECT_SELF) != oShield)
        {
            NWNX_Creature_RunEquip(OBJECT_SELF, oShield, INVENTORY_SLOT_LEFTHAND);
        }
        object oArmour = GetLocalObject(OBJECT_SELF, "hen_armour");
        if (!GetIsObjectValid(oArmour))
        {
            DeleteLocalObject(OBJECT_SELF, "hen_armour");
            oArmour = GetItemInSlot(INVENTORY_SLOT_CHEST, OBJECT_SELF);
            if (GetIsObjectValid(oArmour))
            {
                SetLocalObject(OBJECT_SELF, "hen_armour", oArmour);
            }
        }
        else if (GetItemInSlot(INVENTORY_SLOT_CHEST, OBJECT_SELF) != oArmour)
        {
            NWNX_Creature_RunEquip(OBJECT_SELF, oArmour, INVENTORY_SLOT_CHEST);
        }
    }

    // if master is dead, commence operation black hawk down
    if (GetIsDead(oStoredMaster))
    {
        float fEnemyDistance = 40.0;

        string sVarName = "being_useless_while_master_dead";
        
        // too far to revive? go to master
        if (GetDistanceToObject(oStoredMaster) > fEnemyDistance)
        {
            //SendMessageToPC(GetFirstPC(), GetName(OBJECT_SELF)+" moving to master because too far");
            ClearAllActions();
            DeleteLocalInt(OBJECT_SELF, sVarName);
            ActionMoveToObject(oStoredMaster, TRUE);
            return; // do nothing else but go to the master    
        }

        object oClosestEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oStoredMaster, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);

        // if the enemy is still alive and within 40 yards, make the follower attack them immediately if not already doing so
        if (GetIsObjectValid(oClosestEnemy) && 
            GetDistanceBetween(oStoredMaster, oClosestEnemy) < fEnemyDistance &&
            GetAttemptedAttackTarget() != oClosestEnemy &&
            GetAttemptedSpellTarget() != oClosestEnemy)
        {
            //SendMessageToPC(GetFirstPC(), GetName(OBJECT_SELF)+" attacking nearest enemy to master");
            ClearAllActions();
            DeleteLocalInt(OBJECT_SELF, sVarName);
            AI_DetermineCombatRound(oClosestEnemy);
            return; // do nothing else but attack the enemy
        }

        int nBeingUselessWhileMasterIsDead = GetLocalInt(OBJECT_SELF, sVarName);

        // if i have been stuck for a while, go immediately to the master
        if (nBeingUselessWhileMasterIsDead > 2)
        {
            // if i am close enough it is okay not to go to the master anymore in this scenario. there might be an enemy to fight at this point
            if (GetDistanceToObject(oStoredMaster) < 10.0)
            {
                DeleteLocalInt(OBJECT_SELF, sVarName);
            }
            else
            {            
                ClearAllActions();
                ActionMoveToObject(oStoredMaster, TRUE);  
            }
        }

        // if you are NOT attacking anything at all at this point, most likely you are stuck. count how long we are stuck on this, but dont return or clear actions in case i am doing something
        if (!GetIsObjectValid(GetAttemptedAttackTarget()) &&
            !GetIsObjectValid(GetAttemptedSpellTarget()))
        {
            //SendMessageToPC(GetFirstPC(), GetName(OBJECT_SELF)+" attacking nearest enemy to master");
            SetLocalInt(OBJECT_SELF, sVarName, nBeingUselessWhileMasterIsDead + 1);
        }


        // if that fails, attempt to attack the nearest enemy to yourself
        /*
        oClosestEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);

        // if the enemy is still alive and within 40 yards, make the follower attack them immediately if not already doing so
        if (GetIsObjectValid(oClosestEnemy) && 
            GetDistanceBetween(OBJECT_SELF, oClosestEnemy) < fEnemyDistance &&
            GetAttemptedAttackTarget() != oClosestEnemy &&
            GetAttemptedSpellTarget() != oClosestEnemy)
        {
            //SendMessageToPC(GetFirstPC(), GetName(OBJECT_SELF)+" attacking nearest enemy to myself");
            ClearAllActions();
            AI_DetermineCombatRound(oClosestEnemy);
            return; // do nothing else but attack the enemy
        }
        */

        // if that fails, do it again but based on yourself, not the master
    }

    /*
    if (GetIsObjectValid(oStoredMaster) && !GetIsInCombat(OBJECT_SELF) && GetIsDead(oStoredMaster))
    {
        ClearAllActions(TRUE);
        // The function this variable controls can get stuck set to 1
        // which results in the henchman not doing anything except stand there being a punching bag
        // I have no direct evidence that this function is to blame, but given this behaviour
        // is most common after a PC dies and the henchman moved next to them, it's a really big culprit
        //__TurnCombatRoundOn(FALSE);
        // This uses ActionDoCommand to clear it, which can clearly get interrupted somehow
        SetLocalInt(OBJECT_SELF, "X2_L_MUTEXCOMBATROUND", 0);
        ActionMoveToObject(oStoredMaster, TRUE);
        return; // don't do any more actions that might interrupt this
    }
    */

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

    // Have paladins try to remove diseases on nearby non-enemies
    if (!GetIsInCombat() && GetIsObjectValid(oStoredMaster) && GetHasFeat(FEAT_REMOVE_DISEASE, OBJECT_SELF))
    {
        location lSelf = GetLocation(OBJECT_SELF);
        object oTest = GetFirstObjectInShape(SHAPE_SPHERE, 10.0, lSelf);
        while (GetIsObjectValid(oTest))
        {
            if (!GetIsDead(oTest) && !GetIsEnemy(oTest) && GetHasEffect(EFFECT_TYPE_DISEASE, oTest))
            {
                ActionUseFeat(FEAT_REMOVE_DISEASE, oTest);
                return;
            }
            oTest = GetNextObjectInShape(SHAPE_SPHERE, 10.0, lSelf);
        }
    }

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

// if alive and master exists
    if (GetIsObjectValid(oMaster) && !GetIsDead(oMaster))
        DeleteLocalInt(OBJECT_SELF, "no_master_count");

    if(!GetAssociateState(NW_ASC_IS_BUSY))
    {

        //Seek out and disable undisabled traps
        object oTrap = GetNearestTrapToObject();
        if (GetIsObjectValid(oTrap) && AI_AttemptToDisarmTrap(oTrap)) return; // succesful trap found and disarmed

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
                            if(!GetIsFighting())
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






/************************ [On Heartbeat] ***************************************
    Filename: nw_c2_default1 or j_ai_onheartbeat
************************* [On Heartbeat] ***************************************
    Removed stupid stuff, special behaviour, sleep.

    Also, note please, I removed waypoints and day/night posting from this.
    It can be re-added if you like, but it does reduce heartbeats.

    Added in better checks to see if we should fire this script. Stops early if
    some conditions (like we can't move, low AI settings) are set.

    Hint: If nothing is used within this script, either remove it from creatures
          or create one witch is blank, with just a "void main(){}" at the top.

    Hint 2: You could add this very small file to your catche of scripts in the
            module properties, as it runs on every creature every 6 seconds (ow!)

    This also uses a system of Execute Script :-D This means the heartbeat, when
    compiled, should be very tiny.

    Note: NO Debug strings!
    Note 2: Remember, I use default SoU Animations/normal animations. As it is
            executed, we can check the prerequisists here, and then do it VIA
            execute script.

    -Working- Best possible, fast compile.
************************* [History] ********************************************
    1.3 - Added more "buffs" to fast buff.
        - Fixed animations (they both WORK and looping ones do loop right!)
        - Loot behaviour!
        - Randomly moving nearer a PC in 25M if set.
        - Removed silly day/night optional setting. Anything we can remove, is a good idea.
************************* [Workings] *******************************************
    This fires off every 6 seconds (with PCs in the area, or AI_LEVEL_HIGH without)
    and therefore is intensive.

    It fires of ExecutesScript things for the different parts - saves CPU stuff
    if the bits are not used.
************************* [Arguments] ******************************************
    Arguments: Basically, none. Nothing activates this script. Fires every 6 seconds.
************************* [On Heartbeat] **************************************/
/*
// - This includes J_Inc_Constants
#include "J_INC_HEARTBEAT"

void main()
{
    // Special - Runner from the leader shouts, each heartbeat, to others to get thier
    // attention that they are being attacked.
    // - Includes fleeing making sure (so it resets the ActionMoveTo each 6 seconds -
    //   this is not too bad)
    // - Includes door bashing stop heartbeat
    if(PerformSpecialAction()) return;

    // Pre-heartbeat-event
    if(FireUserEvent(AI_FLAG_UDE_HEARTBEAT_PRE_EVENT, EVENT_HEARTBEAT_PRE_EVENT))
        // We may exit if it fires
        if(ExitFromUDE(EVENT_HEARTBEAT_PRE_EVENT)) return;

    // AI status check. Is the AI on?
    if(GetAIOff() || GetSpawnInCondition(AI_FLAG_OTHER_LAG_IGNORE_HEARTBEAT, AI_OTHER_MASTER)) return;

    // Define the enemy and player to use.
    object oEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
    object oPlayer = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC);
    int iTempInt;

    // AI level (re)setting
    if(!GetIsInCombat() && !GetIsObjectValid(GetAttackTarget()) &&
       (GetIsObjectValid(oEnemy) && GetDistanceToObject(oEnemy) <= f50 ||
        GetIsObjectValid(oPlayer) && GetDistanceToObject(oPlayer) <= f50))
    {
        // AI setting, normally higher then normal.
        iTempInt = GetAIConstant(LAG_AI_LEVEL_YES_PC_OR_ENEMY_50M);
        if(iTempInt > iM1 && GetAILevel() != iTempInt)
        {
            SetAILevel(OBJECT_SELF, iTempInt);
        }
    }
    else
    {
        // AI setting, normally higher then normal.
        iTempInt = GetAIConstant(LAG_AI_LEVEL_NO_PC_OR_ENEMY_50M);
        if(iTempInt > iM1 && GetAILevel() != iTempInt)
        {
            SetAILevel(OBJECT_SELF, iTempInt);
        }
    }

    // We can skip to the end if we are in combat, or something...
    if(!JumpOutOfHeartBeat() && // We don't stop due to effects.
       !GetIsInCombat() &&      // We are not in combat.
       !GetIsObjectValid(GetAttackTarget()) && // Second combat check.
       !GetObjectSeen(oEnemy))  // Nearest enemy is not seen.
    {
        // Fast buffing...if we have the spawn in condition...
        if(GetSpawnInCondition(AI_FLAG_COMBAT_FLAG_FAST_BUFF_ENEMY, AI_COMBAT_MASTER) &&
           GetIsObjectValid(oEnemy) && GetDistanceToObject(oEnemy) <= f40)
        {
            // ...we may do an advanced buff. If we cannot see/hear oEnemy, but oEnemy
            // is within 40M, we cast many defensive spells instantly...
            ExecuteScript(FILE_HEARTBEAT_TALENT_BUFF, OBJECT_SELF);
            //...if TRUE (IE it does something) we turn of future calls.
            DeleteSpawnInCondition(AI_FLAG_COMBAT_FLAG_FAST_BUFF_ENEMY, AI_COMBAT_MASTER);
            // This MUST STOP the heartbeat event - else, the actions may be interrupted.
            return;
        }
        // Execute waypoints file if we have waypoints set up.
        if(GetWalkCondition(NW_WALK_FLAG_CONSTANT))
        {
            ExecuteScript(FILE_WALK_WAYPOINTS, OBJECT_SELF);
        }
        // We can't have any waypoints for the other things
        else
        {
            // We must have animations set, and not be "paused", so doing a
            // longer looping one
            // - Need a valid player.
            if(GetIsObjectValid(oPlayer))
            {
                // Do we have any animations to speak of?
                // If we have a nearby PC, not in conversation, we do animations.
                if(!IsInConversation(OBJECT_SELF) &&
                    GetAIInteger(AI_VALID_ANIMATIONS))
                {
                    ExecuteScript(FILE_HEARTBEAT_ANIMATIONS, OBJECT_SELF);
                }
                // We may search for PC enemies :-) move closer to PC's
                else if(GetSpawnInCondition(AI_FLAG_OTHER_SEARCH_IF_ENEMIES_NEAR, AI_OTHER_MASTER) &&
                       !GetLocalTimer(AI_TIMER_SEARCHING) && d4() == i1)
                {
                    ExecuteScript(FILE_HEARTBEAT_WALK_TO_PC, OBJECT_SELF);
                }
            }
        }
    }
    // Fire End-heartbeat-UDE
    FireUserEvent(AI_FLAG_UDE_HEARTBEAT_EVENT, EVENT_HEARTBEAT_EVENT);
}
*/