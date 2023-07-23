/*/////////////////////// [On Heartbeat - Move Nearer PC] //////////////////////
    Filename: J_AI_Heart_Serch
///////////////////////// [On Heartbeat - Move Nearer PC] //////////////////////
    This is fired to perform moving nearer the PC, or searching towards them.

    Yes, like the Henchmen and Battle AI code. I am sure they won't mind - if
    they do, I will remove it :-)
///////////////////////// [History] ////////////////////////////////////////////
    1.3 - Added
    1.4 - Reformatted as with the rest of the AI
///////////////////////// [Workings] ///////////////////////////////////////////
    This makes the NPC move nearer to a PC. Fires if the spawn condition
    is on and the timer is not, and only 1/4 heartbeats to lessen the effect.
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: N/A
///////////////////////// [On Heartbeat - Move Nearer PC] ////////////////////*/

#include "J_INC_CONSTANTS"

void main()
{
    object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC);
    if(GetIsObjectValid(oPC) && GetIsEnemy(oPC) &&
       GetDistanceToObject(oPC) <
       IntToFloat(GetBoundriedAIInteger(AI_SEARCH_IF_ENEMIES_NEAR_RANGE, 25, 50, 5)))
    {
        vector vPC = GetPosition(oPC);
        // Whats the distance we use to move a bit nearer?
        int nRandom = 10 + Random(10);
        // Randomise a point nearby.
        vPC.x += IntToFloat(nRandom - (Random(2 * nRandom + 1)));
        vPC.y += IntToFloat(nRandom - (Random(2 * nRandom + 1)));
        vPC.z += IntToFloat(nRandom - (Random(2 * nRandom + 1)));
        // Define the location
        location lNew = Location(GetArea(oPC), vPC, IntToFloat(Random(359)));
        SetLocalTimer(AI_TIMER_SEARCHING, GetDistanceToObject(oPC));
        ClearAllActions();
        ActionMoveToLocation(lNew);
    }
}
