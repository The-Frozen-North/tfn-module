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
    else if(nRandom < 7) // 2-6 - do nothing
    {
        ClearAllActions(TRUE);
    }
    else // 7-10 - attack nearest creature
    {
        int nTh = 2;
        object oTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE,TRUE);
        while(oTarget != OBJECT_INVALID)
        {
            if(GetObjectSeen(oTarget) || GetObjectHeard(oTarget))
            {
                ActionAttack(GetNearestObject(OBJECT_TYPE_CREATURE));
                break;
            }
        oTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE,TRUE,OBJECT_SELF,nTh++);
        }
    }
    SetCommandable(FALSE);
}
