/*

    Henchman Inventory And Battle AI

    This file is used for responding to henchman shouts. Includes
    radial menu commands along with PC attack messages.

*/

#include "inc_hai_act"
#include "inc_hai"
#include "inc_hai_assoc"
#include "x0_i0_henchman"
#include "nwnx_player"

// void main() {}

// modified form of shout handler, calls different routines
void HenchChRespondToShout(object oShouter, int nShoutIndex, object oIntruder = OBJECT_INVALID);

//69MEH69 Added for multiple henchmen command relay
void RelayCommandToAssociates(int nShoutIndex)
{
    object oFamiliar = GetAssociate(ASSOCIATE_TYPE_FAMILIAR);
    if(GetIsObjectValid(oFamiliar))
    {
        AssignCommand(oFamiliar, HenchChRespondToShout(OBJECT_SELF, nShoutIndex));
    }
    object oAnimal = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION);
    if(GetIsObjectValid(oAnimal))
    {
        AssignCommand(oAnimal, HenchChRespondToShout(OBJECT_SELF, nShoutIndex));
    }
    object oSummoned = GetAssociate(ASSOCIATE_TYPE_SUMMONED);
    if(GetIsObjectValid(oSummoned))
    {
        AssignCommand(oSummoned, HenchChRespondToShout(OBJECT_SELF, nShoutIndex));
    }
    object oDominated = GetAssociate(ASSOCIATE_TYPE_DOMINATED);
    if(GetIsObjectValid(oDominated))
    {
        AssignCommand(oDominated, HenchChRespondToShout(OBJECT_SELF, nShoutIndex));
    }
}


// sends commands to associates of creature
// TODO floating text is not shown for associates of associates
void RelayModeToAssociates(int nActionMode, int nValue)
{
    SetActionMode(OBJECT_SELF, nActionMode, nValue);
    object oFamiliar = GetAssociate(ASSOCIATE_TYPE_FAMILIAR);
    if(GetIsObjectValid(oFamiliar))
    {
        SetActionMode(oFamiliar, nActionMode, nValue);
    }
    object oAnimal = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION);
    if(GetIsObjectValid(oAnimal))
    {
        SetActionMode(oAnimal, nActionMode, nValue);
    }
    object oSummoned = GetAssociate(ASSOCIATE_TYPE_SUMMONED);
    if(GetIsObjectValid(oSummoned))
    {
        SetActionMode(oSummoned, nActionMode, nValue);
    }
    object oDominated = GetAssociate(ASSOCIATE_TYPE_DOMINATED);
    if(GetIsObjectValid(oDominated))
    {
        SetActionMode(oDominated, nActionMode, nValue);
    }
}


//::///////////////////////////////////////////////
//:: Respond To Shouts
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Allows the listener to react in a manner
    consistant with the given shout but only to one
    combat shout per round
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 25, 2001
//:://////////////////////////////////////////////

//NOTE ABOUT COMMONERS
/*
    Commoners are universal cowards.  If you attack anyone they will flee for 4 seconds away from the attacker.
    However to make the commoners into a mob, make a single commoner at least 10th level of the same faction.
    If that higher level commoner is attacked or killed then the commoners will attack the attacker.  They will disperse again
    after some of them are killed.  Should NOT make multi-class creatures using commoners.
*/
//NOTE ABOUT BLOCKERS
/*
    It should be noted that the Generic Script for On Dialogue attempts to get a local set on the shouter by itself.
    This object represents the LastOpenedBy object.  It is this object that becomes the oIntruder within this function.
*/

//NOTE ABOUT INTRUDERS
/*
    The intruder object is for cases where a placable needs to pass a LastOpenedBy Object or a AttackMyAttacker
    needs to make his attacker the enemy of everyone.
*/

void HenchChRespondToShout(object oShouter, int nShoutIndex, object oIntruder = OBJECT_INVALID)
{
//    Jug_Debug(GetName(OBJECT_SELF) + " res to shout of " + GetName(GetMaster()) + " index " + IntToString(nShoutIndex));
    // * if petrified, jump out
    if (GetHasEffect(EFFECT_TYPE_PETRIFY, OBJECT_SELF))
    {
        return;
    }
    // * MODIFIED February 19 2003
    // * Do not respond to shouts if in dying mode

    /*
    if (GetAssociateState(NW_ASC_MODE_DYING))
    {
        return;
    }
    */

    // Pausanias: Do not respond to shouts if you've surrendered.
    int iSurrendered = GetLocalInt(OBJECT_SELF,"Generic_Surrender");
    if (iSurrendered) return;

    object oMaster = GetMaster();

    switch (nShoutIndex)
    {
        // * toggle search mode for henchmen
        case ASSOCIATE_COMMAND_TOGGLESEARCH:
            if (GetActionMode(OBJECT_SELF, ACTION_MODE_DETECT))
            {
                RelayModeToAssociates(ACTION_MODE_DETECT, FALSE);
            }
            else
            {
                RelayModeToAssociates(ACTION_MODE_DETECT, TRUE);
            }
            break;
        // * toggle stealth mode for henchmen
        case ASSOCIATE_COMMAND_TOGGLESTEALTH:
            if (GetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH))
            {
                SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, FALSE);
                RelayModeToAssociates(ACTION_MODE_STEALTH, FALSE);
            }
            else
            {
                SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, TRUE);
                RelayModeToAssociates(ACTION_MODE_STEALTH, TRUE);
            }
            break;
        // * June 2003: Stop spellcasting
        case ASSOCIATE_COMMAND_TOGGLECASTING:
            if (GetLocalInt(OBJECT_SELF, "X2_L_STOPCASTING") == 10)
            {
               // SpeakString("Was in no casting mode. Switching to cast mode");
                NWNX_Player_FloatingTextStringOnCreature(oMaster, OBJECT_SELF, GetName(OBJECT_SELF)+" will now cast spells when possible");
                SetLocalInt(OBJECT_SELF, "X2_L_STOPCASTING", 0);
                VoiceCanDo();
            }
            else if (GetLocalInt(OBJECT_SELF, "X2_L_STOPCASTING") == 0)
            {
             //   SpeakString("Was in casting mode. Switching to NO cast mode");
                NWNX_Player_FloatingTextStringOnCreature(oMaster, OBJECT_SELF, GetName(OBJECT_SELF)+" will no longer cast spells");
                SetLocalInt(OBJECT_SELF, "X2_L_STOPCASTING", 10);
                VoiceCanDo();
            }
            break;
        case ASSOCIATE_COMMAND_INVENTORY:
            // no inventory stuff - pok
            SendMessageToPCByStrRef(oMaster, 100895);
            break;

        case ASSOCIATE_COMMAND_ATTACKNEAREST: //Used to de-activate AGGRESSIVE DEFEND MODE
            {
                ClearAllActions();
                HenchResetHenchmenState();
                SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, FALSE);
                SetAssociateState(NW_ASC_MODE_STAND_GROUND, FALSE);
                if (GetLocalInt(OBJECT_SELF, sHenchDontAttackFlag))
                {
                    DeleteLocalInt(OBJECT_SELF, sHenchDontAttackFlag);
                    NWNX_Player_FloatingTextStringOnCreature(oMaster, OBJECT_SELF, GetName(OBJECT_SELF)+" will now attack enemies on sight");
                    //SpeakString(sHenchPeacefulModeCancel);
                }
                object oClosest = GetNearestSeenOrHeardEnemyNotDead();
                DeleteLocalObject(OBJECT_SELF, sHenchLastTarget);
                if (GetIsObjectValid(oClosest))
                {
                    HenchDetermineCombatRound(oClosest, TRUE);
                }
                else
                {
                        // Pausanias: Use this command also to pick the nearest lock.
                    object oLockedObject = HenchGetLockedOrTrappedObject(OBJECT_SELF);
                    if (GetIsObjectValid(oLockedObject) && oMaster == GetRealMaster() &&
                        ((GetAssociateType(OBJECT_SELF) == ASSOCIATE_TYPE_FAMILIAR) ||
                        !(GetGeneralOptions(HENCH_GENAI_SOUINSTALLED) & HENCH_GENAI_SOUINSTALLED)))
                    {
                        OpenLock(oLockedObject);
                    }
                    else
                    {
                        // * bonus feature. If master is attacking a door or container, issues VWE Attack Nearest
                        // * will make henchman join in on the fun
                        object oTarget = GetAttackTarget(GetRealMaster());
                        if (GetIsObjectValid(oTarget) && GetObjectType(oTarget) == OBJECT_TYPE_PLACEABLE || GetObjectType(oTarget) == OBJECT_TYPE_DOOR)
                        {
                            if (GetTrapDetectedBy(oTarget, OBJECT_SELF))
                            {
                                HenchStartRangedBashDoor(oTarget);
                            }
                            else
                            {
                                HenchAttackObject(oTarget);
                                SetLocalObject(OBJECT_SELF, "NW_GENERIC_DOOR_TO_BASH", oTarget);
                            }
                        }
                        else
                        {
                            ActionForceFollowObject(GetRealMaster(), GetFollowDistance());
                        }
                    }
                }
                RelayCommandToAssociates(nShoutIndex);
            }
            break;

        case ASSOCIATE_COMMAND_FOLLOWMASTER: //Only used to retreat, or break free from Stand Ground Mode
            {
                if (!GetAssociateState(NW_ASC_MODE_STAND_GROUND))
                {
                    /*
                    int nAssocType = GetAssociateType(OBJECT_SELF);
                    if (nAssocType == ASSOCIATE_TYPE_HENCHMAN)
                        SpeakString(sHenchHenchmanFollow);
                    else if (nAssocType == ASSOCIATE_TYPE_FAMILIAR)
                        SpeakString(sHenchFamiliarFollow);
                    else if (nAssocType == ASSOCIATE_TYPE_ANIMALCOMPANION)
                        SpeakString("<" + GetName(OBJECT_SELF) + sHenchAnCompFollow);
                    else
                        SpeakString(sHenchOtherFollow1 + GetName(OBJECT_SELF) + sHenchOtherFollow2);
                    */

                    NWNX_Player_FloatingTextStringOnCreature(oMaster, OBJECT_SELF, GetName(OBJECT_SELF)+" will follow and avoid attacking enemies");

                    SetLocalInt(OBJECT_SELF, sHenchDontAttackFlag, TRUE);
                    SetLocalInt(OBJECT_SELF, sHenchShouldIAttackMessageGiven, TRUE);

                    if (!GetActionMode(oMaster, ACTION_MODE_STEALTH))
                    {
                        SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, FALSE);
                    }
                    if (!GetActionMode(oMaster, ACTION_MODE_DETECT) && !GetHasFeat(FEAT_KEEN_SENSE))
                    {
                        SetActionMode(OBJECT_SELF, ACTION_MODE_DETECT, FALSE);
                    }
                }
                HenchResetHenchmenState();
                DeleteLocalInt(OBJECT_SELF, sHenchScoutingFlag);
                SetAssociateState(NW_ASC_MODE_STAND_GROUND, FALSE);
                ActionForceFollowObject(GetRealMaster(), GetFollowDistance());
                RelayCommandToAssociates(nShoutIndex);
            }
            break;

        case ASSOCIATE_COMMAND_GUARDMASTER: //Used to activate AGGRESSIVE DEFEND MODE
            {
                HenchResetHenchmenState();
                DeleteLocalInt(OBJECT_SELF, sHenchDontAttackFlag);
                DelayCommand(2.5, VoiceCanDo());
                //Companions will only attack the Masters Last Attacker
                SetAssociateState(NW_ASC_MODE_DEFEND_MASTER);
                SetAssociateState(NW_ASC_MODE_STAND_GROUND, FALSE);
                object oRealMaster = GetRealMaster();

                // remove this flag! - pok
                DeleteLocalInt(OBJECT_SELF, sHenchDontAttackFlag);

                NWNX_Player_FloatingTextStringOnCreature(oMaster, OBJECT_SELF, GetName(OBJECT_SELF)+" will only retaliate against your last attacker");

                if(GetIsObjectValid(GetLastHostileActor(oRealMaster)))
                {
                    HenchDetermineCombatRound(GetLastHostileActor(oRealMaster), TRUE);
                }
                else
                {
                    ActionForceFollowObject(oRealMaster, GetFollowDistance());
                }
                RelayCommandToAssociates(nShoutIndex);
            }
            break;
        case -900: // "MASTER_WAS_ATTACKED"
        case ASSOCIATE_COMMAND_MASTERUNDERATTACK:  //Check whether the master has you in AGGRESSIVE DEFEND MODE
            if(!GetAssociateState(NW_ASC_MODE_STAND_GROUND))
            {
                //Check the henchmens current target
                object oTarget = GetAttemptedAttackTarget();
                object oRealMaster = GetRealMaster();
                if(!GetIsObjectValid(oTarget))
                {
                    oTarget = GetAttemptedSpellTarget();
                    if(!GetIsObjectValid(oTarget))
                    {
                        if(GetAssociateState(NW_ASC_MODE_DEFEND_MASTER))
                        {
                            HenchDetermineCombatRound(GetLastHostileActor(oRealMaster));
                        }
                        else
                        {
                            HenchDetermineCombatRound();
                        }
                    }
                }
                //Switch targets only if the target is not attacking the master and is greater than 6.0 from
                //the master.
                if(GetAttackTarget(oTarget) != oRealMaster && GetDistanceBetween(oTarget, oRealMaster) > 6.0)
                {
                    if(GetAssociateState(NW_ASC_MODE_DEFEND_MASTER) && GetIsObjectValid(GetLastHostileActor(oRealMaster)))
                    {
                        HenchDetermineCombatRound(GetLastHostileActor(oRealMaster));
                    }
                }
                RelayCommandToAssociates(nShoutIndex);
            }
            break;

        case ASSOCIATE_COMMAND_STANDGROUND: //No longer follow the master or guard him
            SetAssociateState(NW_ASC_MODE_STAND_GROUND);

            NWNX_Player_FloatingTextStringOnCreature(oMaster, OBJECT_SELF, GetName(OBJECT_SELF)+" is waiting");

            SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, FALSE);
            DelayCommand(2.0, VoiceCanDo());
            ActionAttack(OBJECT_INVALID);
            ClearAllActions();
            RelayCommandToAssociates(nShoutIndex);
            break;

        case ASSOCIATE_COMMAND_MASTERATTACKEDOTHER:
            if(!GetAssociateState(NW_ASC_MODE_STAND_GROUND))
            {
                if(!GetAssociateState(NW_ASC_MODE_DEFEND_MASTER))
                {
                    if(!GetIsFighting(OBJECT_SELF))
                    {
                        object oAttack = GetAttackTarget(GetRealMaster());
                        if(GetIsObjectValid(oAttack))
                        {
                            HenchDetermineCombatRound(oAttack);
                        }
                    }
                    RelayCommandToAssociates(nShoutIndex);
                }
            }
            break;

        case ASSOCIATE_COMMAND_MASTERGOINGTOBEATTACKED:
            if(!GetAssociateState(NW_ASC_MODE_STAND_GROUND))
            {
                if(!GetIsFighting(OBJECT_SELF))
                {
                    object oAttacker = GetGoingToBeAttackedBy(GetRealMaster());
                    if(GetIsObjectValid(oAttacker))
                    {
                        HenchDetermineCombatRound(oAttacker);
                    }
                }
                RelayCommandToAssociates(nShoutIndex);
            }
            break;

        case ASSOCIATE_COMMAND_HEALMASTER: //Ignore current healing settings and heal me now
            HenchResetHenchmenState();
            SetLocalInt(OBJECT_SELF, henchHealCountStr, -1);
            ExecuteScript("hen_heal", OBJECT_SELF);
            break;

        case ASSOCIATE_COMMAND_PICKLOCK:
            OpenLock(GetLockedObject(oMaster));
            break;

        case ASSOCIATE_COMMAND_DISARMTRAP:
            ForceTrap(GetNearestTrapToObject(oMaster));
            break;

        case ASSOCIATE_COMMAND_MASTERSAWTRAP:
            HenchCheckArea(TRUE);
            break;

        case ASSOCIATE_COMMAND_MASTERFAILEDLOCKPICK: //Check local for Re-try locked doors and
            if(!GetAssociateState(NW_ASC_MODE_STAND_GROUND))
            {
                if(GetAssociateState(NW_ASC_RETRY_OPEN_LOCKS))
                {
                    OpenLock(GetLockedObject(oMaster));
                }
            }
            break;

        case ASSOCIATE_COMMAND_LEAVEPARTY:
            {
                /* don't do this at all, make henchman leave via dialogue - pok
                if(GetIsObjectValid(oMaster))
                {
                    ClearActions(CLEAR_X0_INC_HENAI_RespondToShout4);
                    if(GetAssociateType(OBJECT_SELF) == ASSOCIATE_TYPE_HENCHMAN)
                    {
                        FireHenchman(oMaster, OBJECT_SELF);
                    }
                }
                break;
                */
            }

    }
}
