//:://////////////////////////////////////////////////
//:: X0_CH_HEN_PERCEP
/*

  OnPerception event handler for henchmen/associates.

 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 01/05/2003
//:://////////////////////////////////////////////////


#include "X0_INC_HENAI"
#include "inc_hai"

void main()
{
    // dying function removed - pok

    //This is the equivalent of a force conversation bubble, should only be used if you want an NPC
    //to say something while he is already engaged in combat.
    if(GetSpawnInCondition(NW_FLAG_SPECIAL_COMBAT_CONVERSATION))
    {
        ActionStartConversation(OBJECT_SELF);
    }
    object oLastPerceived = GetLastPerceived();

//    if (GetIsEnemy(oLastPerceived))
//    {
//        Jug_Debug(GetName(OBJECT_SELF) + " perceived " + GetName(oLastPerceived) + " seen " + IntToString(GetLastPerceptionSeen()) + " heard " + IntToString(GetLastPerceptionHeard()) + " van " + IntToString(GetLastPerceptionVanished()) + " ina " + IntToString(GetLastPerceptionInaudible()) + " action " + IntToString(GetCurrentAction()));
//    }
        // TODO HotU added check for stealth
    if (!GetAssociateState(NW_ASC_MODE_STAND_GROUND))
    {
  // using CPP logic - pok
 //Check if the last percieved creature was actually seen
            if(GetLastPerceptionSeen())
            {
                if(GetIsEnemy(GetLastPerceived()))
                {
                    SetFacingPoint(GetPosition(GetLastPerceived()));
                    //HenchmenCombatRound(OBJECT_INVALID);
                    HenchDetermineCombatRound(oLastPerceived, TRUE);
                }
                //Linked up to the special conversation check to initiate a special one-off conversation
                //to get the PCs attention
                /*
                else if(GetSpawnInCondition(NW_FLAG_SPECIAL_CONVERSATION) && GetIsPC(GetLastPerceived()))
                {
                    ActionStartConversation(OBJECT_SELF);
                }
                */
            }

        /*
        //If the last perception event was hearing based or if someone vanished then go to search mode
        if (GetLastPerceptionVanished() || GetLastPerceptionInaudible())
        {
            if (!GetObjectSeen(oLastPerceived) && !GetObjectHeard(oLastPerceived) &&
                !GetIsDead(oLastPerceived) && GetArea(oLastPerceived) == GetArea(OBJECT_SELF) &&
                GetIsEnemy(oLastPerceived))
            {
                // add check if target - prevents creature from following the target
                // due to ActionAttack without actually perceiving them
                if (GetLocalObject(OBJECT_SELF, sHenchLastTarget) == oLastPerceived)
                {
                    DeleteLocalObject(OBJECT_SELF, sHenchLastTarget);
                    HenchDetermineCombatRound(oLastPerceived, TRUE);
                }
            }
        }
        else if(GetLastPerceptionSeen())
        {
            //Do not bother checking the last target seen if already fighting
                // PAUS: No, actually please do check
                // Auldar: Use these more accurate checks for being in combat. ie uncomment them.
            if(!GetIsObjectValid(GetAttemptedAttackTarget()) &&
               !GetIsObjectValid(GetAttackTarget()) &&
               !GetIsObjectValid(GetAttemptedSpellTarget()) && GetCurrentAction() != ACTION_TAUNT)
            {
                //Check if the last percieved creature was actually seen
                if(GetIsEnemy(oLastPerceived) && !GetIsDead(oLastPerceived))
                {
    //            Jug_Debug(GetName(OBJECT_SELF) + " perceived " + GetName(oLastPerceived) + " seen " + IntToString(GetLastPerceptionSeen()) + " heard " + IntToString(GetLastPerceptionHeard()) + " van " + IntToString(GetLastPerceptionVanished()) + " ina " + IntToString(GetLastPerceptionInaudible()) + " action " + IntToString(GetCurrentAction()));
                    SetFacingPoint(GetPosition(oLastPerceived));
                    HenchDetermineCombatRound(oLastPerceived);
                }
                //Linked up to the special conversation check to initiate a special one-off conversation
                //to get the PCs attention
                else if (GetSpawnInCondition(NW_FLAG_SPECIAL_CONVERSATION) && GetIsPC(oLastPerceived))
                {
                    ActionStartConversation(OBJECT_SELF);
                }
            }
        }
        */
    }
    if(GetSpawnInCondition(NW_FLAG_PERCIEVE_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_PERCEIVE));
    }
}


