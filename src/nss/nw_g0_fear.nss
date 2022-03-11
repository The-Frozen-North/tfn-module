//::///////////////////////////////////////////////
//:: Fear Heartbeat
//:: NW_G0_FEAR
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This is the heartbeat that runs on a creature
    when the creature is under the fear effect.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On:  , 2001
//:://////////////////////////////////////////////

#include "x0_inc_henai"

void main()
{    SendForHelp();
    //Allow the target to recieve commands for the round
    SetCommandable(TRUE);

    ClearAllActions();

    //Get the nearest creature to the affected creature
    object oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);

    //Run away if they are an enemy of the target's faction
    if(GetIsObjectValid(oTarget) && GetIsEnemy(oTarget) && !GetIsDead(oTarget))
        ActionMoveAwayFromLocation(GetLocation(oTarget), TRUE, 50.0);


    //Disable the ability to recieve commands.
    SetCommandable(FALSE);
}
