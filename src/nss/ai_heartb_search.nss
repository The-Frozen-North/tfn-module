/************************ [On Heartbeat - Move Nearer PC] **********************
    Filename: ai_heartb_search
************************* [On Heartbeat - Move Nearer PC] **********************
    This is fired to perform moving nearer the PC, or searching towards them.

    Yes, like the Henchmen and Battle AI code. I am sure they won't mind - if
    they do, I will remove it :-)
************************* [History] ********************************************
    1.3 - Added
************************* [Workings] *******************************************
    This makes the NPC move nearer to a PC. Fires if the spawn condition
    is on and the timer is not, and only 1/4 heartbeats to lessen the effect.
************************* [Arguments] ******************************************
    Arguments: N/A
************************* [On Heartbeat - Move Nearer PC] *********************/

#include "inc_ai_constants"

void main()
{
    object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC);
    if(GetIsObjectValid(oPC) && GetIsEnemy(oPC) &&
       GetDistanceToObject(oPC) <
       IntToFloat(GetBoundriedAIInteger(AI_SEARCH_IF_ENEMIES_NEAR_RANGE, i25, i50, i5)))
    {
        vector vPC = GetPosition(oPC);
        // Whats the distance we use to move a bit nearer?
        int iRandom = i10 + Random(i10);
        // Randomise a point nearby.
        vPC.x += IntToFloat(iRandom - (Random(i2 * iRandom + i1)));
        vPC.y += IntToFloat(iRandom - (Random(i2 * iRandom + i1)));
        vPC.z += IntToFloat(iRandom - (Random(i2 * iRandom + i1)));
        // Define the location
        location lNew = Location(GetArea(oPC), vPC, IntToFloat(Random(359)));
        SetLocalTimer(AI_TIMER_SEARCHING, GetDistanceToObject(oPC));
        ClearAllActions();
        ActionMoveToLocation(lNew);
    }
}
