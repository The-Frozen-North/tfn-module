//::///////////////////////////////////////////////
//:: Confusion Heartbeat Support Script
//:: NW_G0_Confuse
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This heartbeat script runs on any creature
    that has been hit with the confusion effect.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Sept 27, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- when attack, confused creature must be able to see target
*/

#include "x0_inc_henai"

void main()
{
    SendForHelp();

    //Make sure the creature is commandable for the round
    SetCommandable(TRUE);
    //Clear all previous actions.
    ClearAllActions(TRUE);
    int nRandom = d10();
    //Roll a random int to determine this rounds effects
    if(nRandom < 2) // 1 - wander randomly
    {
        ActionRandomWalk();
    }
    else if(nRandom <= 6) // 2-6 - do nothing
    {
        ClearAllActions(TRUE);
    }
    else // 7-10 - attack nearest object
    {
        object oCreatureTarget, oPlaceableTarget;

        int nTh = 2;
        object oCreature = GetNearestCreature(CREATURE_TYPE_IS_ALIVE,TRUE);

        while(oCreature != OBJECT_INVALID)
        {
            if(GetObjectSeen(oCreature) || GetObjectHeard(oCreature))
            {

                oCreatureTarget = oCreature;
                break;
            }
            oCreature = GetNearestCreature(CREATURE_TYPE_IS_ALIVE,TRUE,OBJECT_SELF,nTh++);
        }

        nTh = 2;
        object oPlaceable = GetNearestObject(OBJECT_TYPE_PLACEABLE);

        while(oPlaceable != OBJECT_INVALID)
        {
            if(GetUseableFlag(oPlaceable) && LineOfSightObject(OBJECT_SELF, oPlaceable))
            {
                oPlaceableTarget = oPlaceable;
                break;
            }
            oPlaceable = GetNearestObject(OBJECT_TYPE_PLACEABLE, OBJECT_SELF, nTh++);
        }

        // creature but not placeable, just attack creature
        if (GetIsObjectValid(oCreatureTarget) && !GetIsObjectValid(oPlaceableTarget))
        {
            ActionAttack(oCreatureTarget);
        }
        // vice versa
        else if (GetIsObjectValid(oPlaceableTarget) && !GetIsObjectValid(oCreatureTarget))
        {
            ActionAttack(oPlaceableTarget);
        }
        // if both, choose one randomly to attack
        else if (GetIsObjectValid(oPlaceableTarget) && GetIsObjectValid(oCreatureTarget))
        {
            if (d2() == 1)
            {
                ActionAttack(oCreatureTarget);
            }
            else
            {
                ActionAttack(oPlaceableTarget);
            }
        }
    }
    SetCommandable(FALSE);
}
