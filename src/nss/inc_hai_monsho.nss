/*

    Henchman Inventory And Battle AI

    This file is used for responding to monster shouts. Mostly
    involves getting the listening creature to start attacking
    unseen and unheard foe.

*/


#include "inc_hai_act"
#include "inc_hai"


// void main() {    }


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

// modified form of shout handler, calls different routines
void HenchMonRespondToShout(object oShouter, int nShoutIndex, object oIntruder = OBJECT_INVALID)
{
    // Pausanias: Do not respond to shouts if you've surrendered.
    int iSurrendered = GetLocalInt(OBJECT_SELF,"Generic_Surrender");
    if (iSurrendered) return;

    switch (nShoutIndex)
    {
        case 1://NW_GENERIC_SHOUT_I_WAS_ATTACKED:
        case 3://NW_GENERIC_SHOUT_I_AM_DEAD:
            {
                object oTarget = oIntruder;
                if(!GetIsObjectValid(oTarget))
                {
                    oTarget = GetLastHostileActor(oShouter);
                    if (!GetIsObjectValid(oTarget))
                    {
                        oTarget = GetLocalObject(oShouter, sHenchLastTarget);
                    }
                }
                if(!GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL))
                {
                    if(!GetLevelByClass(CLASS_TYPE_COMMONER))
                    {
                        if(!GetIsObjectValid(GetAttemptedAttackTarget()) && !GetIsObjectValid(GetAttemptedSpellTarget()))
                        {
                            if(GetIsObjectValid(oTarget))
                            {
                                if(!GetIsFriend(oTarget) && GetIsFriend(oShouter))
                                {
                                    RemoveAmbientSleep();
                                    HenchDetermineCombatRound(oTarget);
                                }
                            }
                        }
                    }
                    else if (GetLevelByClass(CLASS_TYPE_COMMONER, oShouter) >= 10)
                    {
                         HenchStartAttack(GetLastHostileActor(oShouter));
                    }
                    else
                    {
                        HenchDetermineCombatRound(oTarget);
                    }
                }
                else
                {
                    HenchDetermineSpecialBehavior();
                }
            }
        break;

        case 2://NW_GENERIC_SHOUT_MOB_ATTACK:
            {
                if(!GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL))
                {
                    //Is friendly check to make sure that only like minded commoners attack.
                    if(GetIsFriend(oShouter))
                    {
                         HenchStartAttack(GetLastHostileActor(oShouter));
                    }
                }
                else
                {
                    HenchDetermineSpecialBehavior();
                }
            }
        break;

        //For this shout to work the object must shout the following
        //string sHelp = "NW_BLOCKER_BLK_" + GetTag(OBJECT_SELF);
        case 4: //BLOCKER OBJECT HAS BEEN DISTURBED
            {
                if(!GetLevelByClass(CLASS_TYPE_COMMONER))
                {
                    if(!GetIsObjectValid(GetAttemptedAttackTarget()) && !GetIsObjectValid(GetAttemptedSpellTarget()))
                    {
                        if(GetIsObjectValid(oIntruder))
                        {
                            SetIsTemporaryEnemy(oIntruder);
                            HenchDetermineCombatRound(oIntruder);
                        }
                    }
                }
                else if (GetLevelByClass(CLASS_TYPE_COMMONER, oShouter) >= 10)
                {
                    HenchStartAttack(GetLastHostileActor(oShouter));
                }
                else
                {
                    HenchDetermineCombatRound();
                }
            }
        break;

        case 5: //ATTACK MY TARGET
            {
                if(GetIsFriend(oShouter))
                {
                    AdjustReputation(oIntruder, OBJECT_SELF, -100);
                    SetIsTemporaryEnemy(oIntruder);
                    HenchDetermineCombatRound(oIntruder);
                }
            }
        break;

        case 6: //CALL_TO_ARMS
            {
                //This was once commented out.
                HenchDetermineCombatRound();
            }
        break;
    }
}
