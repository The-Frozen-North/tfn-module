#include "inc_trap"
#include "inc_loot"
#include "inc_debug"
#include "util_i_csvlists"
#include "nwnx_object"
#include "nwnx_encounter"

string ChooseSpawnRef(object oArea, int nTarget)
{
    string sTarget = "random"+IntToString(nTarget);

    string sList = GetLocalString(oArea, sTarget+"_list");
    string sListUnique = GetLocalString(oArea, sTarget+"_list_unique");

    int nUniqueChance = GetLocalInt(oArea, sTarget+"_unique_chance");

    if (d100() <= nUniqueChance)
    {
        return GetListItem(sListUnique, Random(CountList(sListUnique)));
    }
    else
    {
        return GetListItem(sList, Random(CountList(sList)));
    }
}

void CreateRandomSpawns(object oArea, int nTarget, int nSpawnPoints)
{
      string sResRef = GetResRef(oArea);
      int nMax = 100;

      string sSpawnScript = GetLocalString(oArea, "random"+IntToString(nTarget)+"_spawn_script");

      int nSpawns = GetLocalInt(oArea, "random"+IntToString(nTarget)+"_spawns");
      if (nSpawns == 0) return;
      int nTotalSpawns = nSpawns + (Random(nSpawns/4));
      if (nTotalSpawns > nMax) nMax = 100;

// Destroy all stored creatures.
// typically done on a refresh
      int i;
      for (i = 1; i <= nMax; i++)
        DestroyObject(GetLocalObject(oArea, "random"+IntToString(nTarget)+"_creature"+IntToString(i)));

      object oCreature;
      location lLocation;
      vector vSpawnWP;
      int nSpawn;
      for (nSpawn = 1; nSpawn <= nTotalSpawns; nSpawn++)
      {
           lLocation = GetLocalLocation(oArea, "random"+IntToString(nTarget)+"_spawn_point"+IntToString(Random(nSpawnPoints)+1));
           vSpawnWP = GetPositionFromLocation(lLocation);

           oCreature = CreateObject(OBJECT_TYPE_CREATURE, ChooseSpawnRef(oArea, nTarget), Location(oArea, Vector(vSpawnWP.x, vSpawnWP.y, vSpawnWP.z), IntToFloat(Random(360)+1)));

           if (sSpawnScript != "") ExecuteScript(sSpawnScript, oCreature);

// Store the creature so it can be deleted later.
           SetLocalObject(oArea, "random"+IntToString(nTarget)+"_creature"+IntToString(nSpawn), oCreature);
      }
}

void main()
{
     string sResRef = GetResRef(OBJECT_SELF);

     int iRows = GetAreaSize(AREA_WIDTH, OBJECT_SELF);
     int iColumns = GetAreaSize(AREA_HEIGHT, OBJECT_SELF);
     int bInstance = GetLocalInt(OBJECT_SELF, "instance");

// ==============================
// Treasures
// ==============================
// clean up old treasures
    int nOldTreasure;
    for (nOldTreasure = 0; nOldTreasure < 50; nOldTreasure++)
        DestroyObject(GetLocalObject(OBJECT_SELF, "treasure"+IntToString(nOldTreasure)));

     float fAreaSize = IntToFloat(GetAreaSize(AREA_HEIGHT, OBJECT_SELF)*GetAreaSize(AREA_WIDTH, OBJECT_SELF));

     int nTreasures = GetLocalInt(OBJECT_SELF, "treasures");

     if (nTreasures > 0)
     {
        int nTreasureChance = ((iRows*iColumns)/nTreasures)*10;

        object oTreasure;
        vector vTreasurePosition;
        location lTreasureLocation;


// cap the density of treasure
        if (nTreasureChance >= 75) nTreasureChance = 75;

        int i;
        for (i = 1; i <= nTreasures; i++)
        {
            if ((GetLocalInt(OBJECT_SELF, "treasure_keep"+IntToString(i)) == 1) || (d100() <= nTreasureChance))
            {
                vTreasurePosition = Vector(GetLocalFloat(OBJECT_SELF, "treasure_x"+IntToString(i)), GetLocalFloat(OBJECT_SELF, "treasure_y"+IntToString(i)), GetLocalFloat(OBJECT_SELF, "treasure_z"+IntToString(i)));
                lTreasureLocation = Location(OBJECT_SELF, vTreasurePosition, GetLocalFloat(OBJECT_SELF, "treasure_o"+IntToString(i)));
                oTreasure = CreateObject(OBJECT_TYPE_PLACEABLE, GetLocalString(OBJECT_SELF, "treasure_resref"+IntToString(i)), lTreasureLocation);
                ExecuteScript("treas_init", oTreasure);

// store the treasure so it can deleted later on refresh
                SetLocalObject(OBJECT_SELF, "treasure"+IntToString(i), oTreasure);
            }
        }
     }
// ==============================
// Events
// ==============================
// clean up old events
    int nOldEvent;
    for (nOldEvent = 0; nOldEvent < 20; nOldEvent++)
        DestroyObject(GetObjectByTag(sResRef+"_event", nOldEvent));

// 50% chance of an event
    int nEventSpawns = GetLocalInt(OBJECT_SELF, "event_spawn_points");
    if (nEventSpawns > 0 && d2() == 1)
    {
        int nEvents = GetLocalInt(OBJECT_SELF, "events");

        int nEventNum = Random(nEvents)+1;


        string sEvent = GetLocalString(OBJECT_SELF, "event"+IntToString(nEventNum));
        string sEventWP = sResRef+"WP_EVENT"+IntToString(Random(nEventSpawns)+1);
        object oEventWP = GetObjectByTag(sEventWP);

        SendDebugMessage(sResRef+" chosen event num : "+IntToString(nEventNum), TRUE);
        SendDebugMessage(sResRef+" chosen event : "+sEvent, TRUE);
        SendDebugMessage(sResRef+" event WP : "+sEventWP, TRUE);
        SendDebugMessage(sResRef+" event WP exists : "+IntToString(GetIsObjectValid(oEventWP)), TRUE);

        ExecuteScript(sEvent, oEventWP);
     }

// ==============================
// Traps
// ==============================

     int iCR = GetLocalInt(OBJECT_SELF, "cr");

     if (GetLocalInt(OBJECT_SELF, "trapped") == 1)
     {
        int nTrapChance = (iRows*iColumns)/12;

        object oTrap, oTrapWP;

        int nTrapSpawns = GetLocalInt(OBJECT_SELF, "trap_spawns");

// cap the density of traps
        if (nTrapChance >= 30) nTrapChance = 30;

        int i;
        for (i = 1; i <= nTrapSpawns; i++)
        {
            oTrapWP = GetObjectByTag(sResRef+"_trap_spawn_point"+IntToString(i));

// delete the trap that is stored on this WP
// this is typically needed when the area is refreshed
            DestroyObject(GetLocalObject(oTrapWP, "trap"));

            if (d100() <= nTrapChance)
            {
                oTrap = CreateTrapAtLocation(DetermineTrap(iCR), GetLocation(oTrapWP), 2.5+(IntToFloat(Random(10)+1)/10.0), "", STANDARD_FACTION_HOSTILE, "on_trap_disarm");
                TrapLogic(oTrap);

// store the trap so it can deleted later on refresh
                SetLocalObject(oTrapWP, "trap", oTrap);
            }
        }
}

// ==============================
// Doors
// ==============================

     if (bInstance == 1)
     {

        int nDoors = GetLocalInt(OBJECT_SELF, "doors");
        object oDoor;

        int i;
        for (i = 1; i <= nDoors; i++)
        {
            oDoor = GetLocalObject(OBJECT_SELF, "door"+IntToString(i));

// close all doors
            AssignCommand(oDoor, ActionCloseDoor(oDoor));

// lock door if set
            if (GetLocalInt(OBJECT_SELF, "door_locked"+IntToString(i)) == 1)
            {
                SetLocked(oDoor, TRUE);
            }
// 50% chance the door will be already open
            else if (GetLocalInt(OBJECT_SELF, "door_locked"+IntToString(i)) == 0 && d2() == 1)
            {
                AssignCommand(oDoor, ActionOpenDoor(oDoor));
            }
        }
}

// ==============================
// Hand-placed creatures
// ==============================

    if (bInstance == 1)
    {
// clean up old creatures
        int nOldCreature;
        for (nOldCreature = 0; nOldCreature < 50; nOldCreature++)
            DestroyObject(GetLocalObject(OBJECT_SELF, "creature"+IntToString(nOldCreature)));

         int nCreatures = GetLocalInt(OBJECT_SELF, "creatures");

         if (nCreatures > 0)
         {
            object oCreature;
            vector vCreaturePosition;
            location lCreatureLocation;

            int i;
            for (i = 1; i <= nCreatures; i++)
            {
                vCreaturePosition = Vector(GetLocalFloat(OBJECT_SELF, "creature_x"+IntToString(i)), GetLocalFloat(OBJECT_SELF, "creature_y"+IntToString(i)), GetLocalFloat(OBJECT_SELF, "creature_z"+IntToString(i)));
                lCreatureLocation = Location(OBJECT_SELF, vCreaturePosition, GetLocalFloat(OBJECT_SELF, "creature_o"+IntToString(i)));
                oCreature = CreateObject(OBJECT_TYPE_CREATURE, GetLocalString(OBJECT_SELF, "creature_resref"+IntToString(i)), lCreatureLocation);

// store the creature so it can deleted later on refresh
                SetLocalObject(OBJECT_SELF, "creature"+IntToString(i), oCreature);
            }
         }
     }

// ==============================
// Random Creature Spawns
// ==============================
     string sEncounter;
     int nRandomSpawnPointTotal;
     int i;
     for (i = 1; i < 10; i++)
     {
        sEncounter = GetLocalString(OBJECT_SELF, "random"+IntToString(i));
        if (sEncounter == "") continue;

        nRandomSpawnPointTotal = GetLocalInt(OBJECT_SELF, "random"+IntToString(i)+"_spawn_point_total");
        if (nRandomSpawnPointTotal == 0) continue;

        CreateRandomSpawns(OBJECT_SELF, i, nRandomSpawnPointTotal);
     }

     string sRefreshScript = GetLocalString(OBJECT_SELF, "refresh_script");
     if (sRefreshScript != "") ExecuteScript(sRefreshScript, OBJECT_SELF);
}

