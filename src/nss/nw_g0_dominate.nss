//::///////////////////////////////////////////////
//:: Dominate Heartbeat
//:: NW_G0_Dominate
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This is the heartbeat that runs on a target
    who is dominated by an NPC.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Sept 27, 2001
//:://////////////////////////////////////////////

#include "x0_inc_henai"

void main()
{
    SendForHelp();

    //Allow commands to be given to the target
    SetCommandable(TRUE);
    //ClearAllActions();
    //SpeakString( "...your will is my command...");

    object oDominator = GetLocalObject(OBJECT_SELF, "dominator");

// if we are attacking the same faction for whatever reason, stop
    if (GetFactionEqual(oDominator, GetAttackTarget()))
    {
        ClearAllActions();
    }

    int nAction = GetCurrentAction();
    int bBusy = nAction == ACTION_ATTACKOBJECT || nAction == ACTION_CASTSPELL;

    if (!bBusy)
    {
        int bValid, nCnt = 1;
        float fDistance;
        //Get the nearest creature to the creature
        object oTarget = GetNearestObject(OBJECT_TYPE_CREATURE);
        while (bBusy == FALSE && bValid == FALSE && fDistance < 20.0)
        {
            fDistance = GetDistanceBetween(OBJECT_SELF, oTarget);
            if(oTarget != OBJECT_SELF && GetIsEnemy(oTarget, oDominator))
            {
                bValid = TRUE;
                bBusy = TRUE;
                //Attack if they are enemy of the target's new faction
                ActionAttack(oTarget);
                break;
            }
            else
            {
                //If not an enemy interate and find the next target
                nCnt++;
                oTarget = GetNearestObject(OBJECT_TYPE_CREATURE, OBJECT_SELF, nCnt);
            }
        }
    }
    //Disable the ability to give commands
    SetCommandable(FALSE);
}
