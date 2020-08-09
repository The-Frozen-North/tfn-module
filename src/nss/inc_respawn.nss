//::////////////////////////////////////////////////////////////////////////////
//:: Sir Elric's Simple Creature Respawns - SE v2.0
//:: FileName - se_respawn_inc
//::////////////////////////////////////////////////////////////////////////////
//::////////////////////////////////////////////////////////////////////////////
//:: Created By: Sir Elric
//:: Created On: 17th February, 2004
//:: Updated On: 20th July, 2008
//::////////////////////////////////////////////////////////////////////////////

#include "inc_debug"


// -----------------------------------------------------------------------------
//  CONSTANTS
// -----------------------------------------------------------------------------

const int SECONDS_TO_RESPAWN = 600;
const int RANDOM_SECONDS_TO_RESPAWN = 300;

// -----------------------------------------------------------------------------
//  PROTOTYPES
// -----------------------------------------------------------------------------

// Respawn mob at original placed location
void RespawnObject(int nType, string sResRef, location lLoc, string sNewTag, int bRandomSpawn = FALSE);

// Respawn object in nMinutes plus nRandom minutes
// nMinutes - Minutes till respawn
// nRandom  - Random minutes(1 to nRandom are added to nMinutes)
// OBJECT_SELF
void StartRespawn();

// Set on the spawn of a creature. Required for respawning to work.
// OBJECT_SELF
void SetSpawn();

// Returns a spawn ref. If the creature has a local int "random_spawn", it will
// choose a random one. Otherwise, it will just return the resref it had.
string SpawnRef(object oCreature, object oArea, int nTarget);

// -----------------------------------------------------------------------------
//  FUNCTIONS
// -----------------------------------------------------------------------------

string SpawnRef(object oCreature, object oArea, int nTarget)
{
    string sRef = GetResRef(oCreature);

// If this creature isn't tagged as random spawn, just use the resref on the creature
    if (nTarget == 0) return sRef;

    string sTarget = "random"+IntToString(nTarget)+"_spawn";

// get the total amount of random spawns in the area
    int nRandom = GetLocalInt(oArea, sTarget+"_total");

// only count the random spawns in the area if it isn't already set
    if (nRandom == 0)
    {
        nRandom = 1;
        while (nRandom < 25)
        {
            if (GetLocalString(oArea, sTarget+IntToString(nRandom)) == "")
            {
                nRandom--;
                break;
            }
            nRandom++;
        }
        SetLocalInt(oArea, sTarget+"_total", nRandom);
    }

// inally, choose a random a random spawn
    string sRandomRef = GetLocalString(oArea, sTarget+IntToString(Random(nRandom)+1));

// If there is no valid spawn selected, use the default
    if (sRandomRef == "")
    {
        return sRef;
    }
// Otherwise, return the random ref.
    else
    {
        return sRandomRef;
    }

}

void SetSpawn()
{
    SetLocalLocation(OBJECT_SELF, "spawn", GetLocation(OBJECT_SELF));
}

void RespawnObject(int nType, string sResRef, location lLoc, string sNewTag, int bRandomSpawn = FALSE)
{
    object oRespawnedObject = CreateObject(nType, sResRef, lLoc, FALSE, sNewTag);

// Make placeables get set up immediately.
    ExecuteScript(GetEventScript(oRespawnedObject, EVENT_SCRIPT_PLACEABLE_ON_HEARTBEAT), oRespawnedObject);

    if (bRandomSpawn == TRUE) SetLocalInt(oRespawnedObject, "random_spawn", 1);
}

void StartRespawn()
{
    if (GetLocalInt(OBJECT_SELF, "respawn") != 1) return;
    if (GetLocalInt(OBJECT_SELF, "ambush") == 1) {
        SendDebugMessage(GetName(OBJECT_SELF)+" is an ambush - no respawn");
        return;
    }

    int nSeconds = SECONDS_TO_RESPAWN;
    int nRandomSeconds = RANDOM_SECONDS_TO_RESPAWN;
    int nType      = GetObjectType(OBJECT_SELF);
    string sRef    = SpawnRef(OBJECT_SELF, GetArea(OBJECT_SELF), GetLocalInt(OBJECT_SELF, "random_spawn"));
    string sTag    = GetTag(OBJECT_SELF);
    location lLoc  = GetLocalLocation(OBJECT_SELF, "spawn");

    if (GetIsObjectValid(GetAreaFromLocation(lLoc))) {DeleteLocalInt(OBJECT_SELF, "spawn");}
    else {lLoc = GetLocation(OBJECT_SELF);}

    float fDelay = IntToFloat(nSeconds);
    // Add random delay time
    if (nRandomSeconds > 0) fDelay = IntToFloat(Random(nRandomSeconds)+1) + fDelay;

    int bRandomSpawn = FALSE;
    if (GetLocalInt(OBJECT_SELF, "random_spawn") == 1) bRandomSpawn = TRUE;

    SendDebugMessage(GetName(OBJECT_SELF)+" will respawn in "+FloatToString(fDelay)+" seconds");

    // Set the respawn
    AssignCommand(GetModule(), DelayCommand(fDelay, RespawnObject(nType, sRef, lLoc, sTag, bRandomSpawn)));
}

//void main(){}

