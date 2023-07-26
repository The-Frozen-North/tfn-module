#include "inc_trap"
#include "inc_loot"
#include "inc_debug"
#include "util_i_csvlists"
#include "nwnx_object"

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

void SpawnTreasureIndex(int nIndex)
{
    vector vTreasurePosition = Vector(GetLocalFloat(OBJECT_SELF, "treasure_x"+IntToString(nIndex)), GetLocalFloat(OBJECT_SELF, "treasure_y"+IntToString(nIndex)), GetLocalFloat(OBJECT_SELF, "treasure_z"+IntToString(nIndex)));
    location lTreasureLocation = Location(OBJECT_SELF, vTreasurePosition, GetLocalFloat(OBJECT_SELF, "treasure_o"+IntToString(nIndex)));
    object oTreasure = CreateObject(OBJECT_TYPE_PLACEABLE, GetLocalString(OBJECT_SELF, "treasure_resref"+IntToString(nIndex)), lTreasureLocation);
    ExecuteScript("treas_init", oTreasure);
    int nNum = GetLocalInt(OBJECT_SELF, "num_spawned_treasures");
    SetLocalObject(OBJECT_SELF, "treasure"+IntToString(nNum), oTreasure);
    SetLocalInt(OBJECT_SELF, "num_spawned_treasures", nNum+1);
}

int CanSpendGoldOnPlaceable(int nTargetGold, int nPlaceableCost)
{
    if (nTargetGold >= nPlaceableCost)
    {
        return 1;
    }
    float fRatio = 100.0*IntToFloat(nTargetGold)/IntToFloat(nPlaceableCost);
    if (Random(100) < FloatToInt(fRatio))
    {
        return 1;
    }
    return 0;
}

void CreateRandomSpawns(object oArea, int nTarget, int nSpawnPoints)
{
      string sResRef = GetResRef(oArea);
      int nMax = 100;

      string sSpawnScript = GetLocalString(oArea, "random"+IntToString(nTarget)+"_spawn_script");

      int nSpawns = GetLocalInt(oArea, "random"+IntToString(nTarget)+"_spawns");
      if (nSpawns == 0) return;
      int nTotalSpawns = nSpawns + (Random(nSpawns/4));
      if (nTotalSpawns > nMax) nTotalSpawns = 100;

// Destroy all stored creatures.
// typically done on a refresh
      int i;
      for (i = 1; i <= nMax; i++)
        DestroyObject(GetLocalObject(oArea, "random"+IntToString(nTarget)+"_creature"+IntToString(i)));



      // Make spawns a little more even
      // In areas with few strong creatures, they are much more likely to become clustered, making them
      // way harder than whoever designed the area might have intended to the point of being
      // just downright unfair
      int nSpawnsToSpreadEvenly = (nTotalSpawns*60)/100;
      int nEvenSpawnsPerSpawnPoint = nSpawnsToSpreadEvenly / nSpawnPoints;
      int nLeftoverEvenSpawns = nSpawnsToSpreadEvenly - (nEvenSpawnsPerSpawnPoint * nSpawnPoints);
      //WriteTimestampedLogEntry(IntToString(nTotalSpawns) + " total, " + IntToString(nSpawnsToSpreadEvenly) + " should be evenly, " + IntToString(nEvenSpawnsPerSpawnPoint) + " per spawn (over " + IntToString(nSpawnPoints) + " spawnpoints), " + IntToString(nLeftoverEvenSpawns) + " leftover");
      nTotalSpawns -= nSpawnsToSpreadEvenly;
      object oCreature;
      location lLocation;
      vector vSpawnWP;
      int nSpawn;
      int nSpawnPoint;
      int nTotalSpawnsOfThisTarget = 1;
      for (nSpawnPoint = 1; nSpawnPoint <= nSpawnPoints; nSpawnPoint++)
      {
          int nSpawnPointsRemaining = (nSpawnPoints+1) - nSpawnPoints;
          int nNumAtThisSpawnPoint = nEvenSpawnsPerSpawnPoint;
          int nChanceToUseLeftover = (nLeftoverEvenSpawns*100)/nSpawnPointsRemaining;
          if (Random(100) < nChanceToUseLeftover)
          {
              nNumAtThisSpawnPoint++;
              nLeftoverEvenSpawns--;
          }
          for (nSpawn = 1; nSpawn <= nNumAtThisSpawnPoint; nSpawn++)
          {
               lLocation = GetLocalLocation(oArea, "random"+IntToString(nTarget)+"_spawn_point"+IntToString(nSpawnPoint));
               vSpawnWP = GetPositionFromLocation(lLocation);

               oCreature = CreateObject(OBJECT_TYPE_CREATURE, ChooseSpawnRef(oArea, nTarget), Location(oArea, Vector(vSpawnWP.x, vSpawnWP.y, vSpawnWP.z), IntToFloat(Random(360)+1)));

               if (sSpawnScript != "")
               {
                   // Stagger running this a bit, because large amounts of creature randomisation may cause server lag in places
                   DelayCommand(0.3 * nSpawn, ExecuteScript(sSpawnScript, oCreature));
               }

    // Store the creature so it can be deleted later.
               SetLocalObject(oArea, "random"+IntToString(nTarget)+"_creature"+IntToString(nTotalSpawnsOfThisTarget), oCreature);
               nTotalSpawnsOfThisTarget++;
          }


      }

      // Do the rest randomly
      for (nSpawn = 1; nSpawn <= nTotalSpawns; nSpawn++)
      {
           lLocation = GetLocalLocation(oArea, "random"+IntToString(nTarget)+"_spawn_point"+IntToString(Random(nSpawnPoints)+1));
           vSpawnWP = GetPositionFromLocation(lLocation);

           oCreature = CreateObject(OBJECT_TYPE_CREATURE, ChooseSpawnRef(oArea, nTarget), Location(oArea, Vector(vSpawnWP.x, vSpawnWP.y, vSpawnWP.z), IntToFloat(Random(360)+1)));

           if (sSpawnScript != "")
           {
               // Stagger running this a bit, because large amounts of creature randomisation may cause server lag in places
               DelayCommand(0.3 * nSpawn, ExecuteScript(sSpawnScript, oCreature));
           }

// Store the creature so it can be deleted later.
           SetLocalObject(oArea, "random"+IntToString(nTarget)+"_creature"+IntToString(nTotalSpawnsOfThisTarget), oCreature);
           nTotalSpawnsOfThisTarget++;
      }
}

void main()
{
     string sResRef = GetResRef(OBJECT_SELF);

     int iRows = GetAreaSize(AREA_WIDTH, OBJECT_SELF);
     int iColumns = GetAreaSize(AREA_HEIGHT, OBJECT_SELF);
     //int bInstance = GetLocalInt(OBJECT_SELF, "instance");

// ==============================
// Treasures
// ==============================
// clean up old treasures
    int nOldTreasure;
    int nNumOld = GetLocalInt(OBJECT_SELF, "num_spawned_treasures");
    for (nOldTreasure = 0; nOldTreasure < nNumOld; nOldTreasure++)
        DestroyObject(GetLocalObject(OBJECT_SELF, "treasure"+IntToString(nOldTreasure)));
     DeleteLocalInt(OBJECT_SELF, "num_spawned_treasures");

     int nTargetGold = GetLocalInt(OBJECT_SELF, "target_placeable_gold");
     int iCR = GetLocalInt(OBJECT_SELF, "cr");
     string sACR = IntToString(iCR);
    object oModule = GetModule();
     int nLowGold = GetLocalInt(oModule, "placeable_value_low_" + sACR);
     int nMedGold = GetLocalInt(oModule, "placeable_value_medium_" + sACR);
     int nHighGold = GetLocalInt(oModule, "placeable_value_high_" + sACR);
     
     json jHigh = GetLocalJson(OBJECT_SELF, "high_treasures");
     json jMed = GetLocalJson(OBJECT_SELF, "med_treasures");
     json jLow =  GetLocalJson(OBJECT_SELF, "low_treasures");

     int nTreasures = GetLocalInt(OBJECT_SELF, "treasures");
     int nTreasureIndex;
     int nArrIndex;
     SendDebugMessage(GetTag(OBJECT_SELF) + ": placeable value target = " + IntToString(nTargetGold), TRUE);
     if (nTreasures > 0)
     {
        while (nTargetGold > 0)
        {
            json jTypes = JsonArray();
            if (JsonGetLength(jHigh) > 0 && CanSpendGoldOnPlaceable(nTargetGold, nHighGold))
            {
                jTypes = JsonArrayInsert(jTypes, JsonInt(2));
            }
            if (JsonGetLength(jMed) > 0 && CanSpendGoldOnPlaceable(nTargetGold, nMedGold))
            {
                jTypes = JsonArrayInsert(jTypes, JsonInt(1));
            }
            if (JsonGetLength(jLow) > 0 && CanSpendGoldOnPlaceable(nTargetGold, nLowGold))
            {
                jTypes = JsonArrayInsert(jTypes, JsonInt(0));
            }
            if (JsonGetLength(jTypes) == 0) { break; }
            int nType = JsonGetInt(JsonArrayGet(jTypes, Random(JsonGetLength(jTypes))));
            
            if (nType == 0)
            {
                nArrIndex = Random(JsonGetLength(jLow));
                nTreasureIndex = JsonGetInt(JsonArrayGet(jLow, nArrIndex));
                SpawnTreasureIndex(nTreasureIndex);
                jLow = JsonArrayDel(jLow, nArrIndex);
                nTargetGold -= nLowGold;
            }
            else if (nType == 1)
            {
                nArrIndex = Random(JsonGetLength(jMed));
                nTreasureIndex = JsonGetInt(JsonArrayGet(jMed, nArrIndex));
                SpawnTreasureIndex(nTreasureIndex);
                jMed = JsonArrayDel(jMed, nArrIndex);
                nTargetGold -= nMedGold;
            }
            else if (nType == 2)
            {
                nArrIndex = Random(JsonGetLength(jHigh));
                nTreasureIndex = JsonGetInt(JsonArrayGet(jHigh, nArrIndex));
                SpawnTreasureIndex(nTreasureIndex);
                jHigh = JsonArrayDel(jHigh, nArrIndex);
                nTargetGold -= nHighGold;
            }
        }
     }
     
     SendDebugMessage(GetTag(OBJECT_SELF) + ": placeable gold left after spawning: " + IntToString(nTargetGold), TRUE);

     json jKeepTreasures = GetLocalJson(OBJECT_SELF, "keep_treasures");
     int nNumKeep = JsonGetLength(jKeepTreasures);
     int i;
     for (i=0; i<nNumKeep; i++)
     {
         nTreasureIndex = JsonGetInt(JsonArrayGet(jKeepTreasures, i));
         SpawnTreasureIndex(nTreasureIndex);
     }
     




// ==============================
// Events
// ==============================
// clean up old events
    int nOldEvent;
    for (nOldEvent = 0; nOldEvent < 20; nOldEvent++)
        DestroyObject(GetObjectByTag(sResRef+"_event", nOldEvent));

    // Event stores: currently the only sources of stores in refreshing areas is from the
    // random event merchant
    // Might not always be the case, though...
    // In any case, accumulating useless stores won't be doing the
    // server's memory usage over long uptimes any good...
    int nStoreIndex;
    object oOldStore;
    for (nStoreIndex=0; nStoreIndex < 10; nStoreIndex++)
    {
        string sVar = "event_store" + IntToString(nStoreIndex);
        oOldStore = GetLocalObject(OBJECT_SELF, sVar);
        if (GetIsObjectValid(oOldStore))
        {
            SendDebugMessage("Destroying event store " + GetResRef(oOldStore) + " at var " + sVar);
            DestroyObject(oOldStore);
        }
    }

// 50% chance of an event, unless overridden
    int nEventSpawns = GetLocalInt(OBJECT_SELF, "event_spawn_points");
    int nEventChance = GetLocalInt(OBJECT_SELF, "event_chance");
    if (nEventChance <= 0)
    {
        nEventChance = 50;
    }
    if (nEventSpawns > 0 && Random(100) < nEventChance)
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


     int nTrapChance = (iRows*iColumns)/12;
// cap the density of traps
     if (nTrapChance >= 30) nTrapChance = 30;

     if (GetLocalInt(OBJECT_SELF, "less_traps") == 1)
        nTrapChance = nTrapChance/3;

     int bTrapped = GetLocalInt(OBJECT_SELF, "trapped");

     if (bTrapped == 1)
     {
        int nTrapChance = (iRows*iColumns)/12;

        object oTrap, oTrapWP;

        int nTrapSpawns = GetLocalInt(OBJECT_SELF, "trap_spawns");

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

     //if (bInstance == 1)
     //{

        int nDoors = GetLocalInt(OBJECT_SELF, "doors");
        object oDoor, oTransitionDoor;


        for (i = 1; i <= nDoors; i++)
        {
            oDoor = GetLocalObject(OBJECT_SELF, "door"+IntToString(i));

// close all doors
            AssignCommand(oDoor, ActionCloseDoor(oDoor));

            oTransitionDoor = GetTransitionTarget(oDoor);

            if (GetIsObjectValid(oTransitionDoor) && GetObjectType(oTransitionDoor) == OBJECT_TYPE_DOOR)
            {
                AssignCommand(oTransitionDoor, ActionCloseDoor(oTransitionDoor));
            }

            if (bTrapped == 1 && d100() <= nTrapChance)
            {
                CreateTrapOnObject(DetermineTrap(iCR), oDoor, STANDARD_FACTION_HOSTILE, "on_trap_disarm");
                TrapLogic(oDoor);
            }

// lock door if set
            if (GetLocalInt(OBJECT_SELF, "door_locked"+IntToString(i)) == 1)
            {
                SetLocked(oDoor, TRUE);
            }
        }
    //}




// ==============================
// Hand-placed creatures
// ==============================

    //if (bInstance == 1)
    //{
// clean up old creatures
        int nOldCreature;
        object oOldCreature;
        for (nOldCreature = 0; nOldCreature < 200; nOldCreature++)
         {
            oOldCreature = GetLocalObject(OBJECT_SELF, "creature"+IntToString(nOldCreature));

// do not clean up creatures that have a PC master
            if (GetIsObjectValid(oOldCreature) && GetLocalString(oOldCreature, "master") == "")
            {
                // This might allow new creatures to spawn directly on top of the old ones
                // without it, they get offset a bit
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectCutsceneGhost(), oOldCreature, 6.0);
                DestroyObject(oOldCreature);
                // Remove from the quest npc list on the area
                RemoveLocalListItem(OBJECT_SELF, "quest_npcs", ObjectToString(oOldCreature));
            }
         }
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

                // Add to quest npc list if required
                int nFaction = NWNX_Creature_GetFaction(oCreature);
                if (GetPlotFlag(oCreature) || GetImmortal(oCreature) || nFaction == STANDARD_FACTION_COMMONER || nFaction == STANDARD_FACTION_DEFENDER || nFaction == STANDARD_FACTION_MERCHANT)
                {
                    string sQuest = GetLocalString(oCreature, "quest1");
                    if (sQuest != "")
                    {
                        AddLocalListItem(OBJECT_SELF, "quest_npcs", ObjectToString(oCreature));
                    }
                }
            }
         }
     //}

// ==============================
// Hand-placed respawnable placeables
// ==============================

    //if (bInstance == 1)
    //{
// clean up old placeables
        int nOldPlaceable;
        object oOldPlaceable;
        for (nOldPlaceable = 0; nOldPlaceable < 200; nOldPlaceable++)
         {
            oOldPlaceable = GetLocalObject(OBJECT_SELF, "placeable"+IntToString(nOldPlaceable));

            if (GetIsObjectValid(oOldCreature) && GetLocalString(oOldCreature, "master") == "")
            {
                DestroyObject(oOldPlaceable);
            }
         }
         int nPlaceables = GetLocalInt(OBJECT_SELF, "placeables");

         if (nPlaceables > 0)
         {
            object oPlaceable;
            vector vPlaceablePosition;
            location lPlaceableLocation;

            int i;
            for (i = 1; i <= nPlaceables; i++)
            {
                vPlaceablePosition = Vector(GetLocalFloat(OBJECT_SELF, "placeable_x"+IntToString(i)), GetLocalFloat(OBJECT_SELF, "placeable_y"+IntToString(i)), GetLocalFloat(OBJECT_SELF, "placeable_z"+IntToString(i)));
                lPlaceableLocation = Location(OBJECT_SELF, vPlaceablePosition, GetLocalFloat(OBJECT_SELF, "placeable_o"+IntToString(i)));
                oPlaceable = CreateObject(OBJECT_TYPE_PLACEABLE, GetLocalString(OBJECT_SELF, "placeable_resref"+IntToString(i)), lPlaceableLocation);

                // store the Placeable so it can deleted later on refresh
                SetLocalObject(OBJECT_SELF, "placeable"+IntToString(i), oPlaceable);
            }
         }
     //}

// ==============================
// Random Creature Spawns
// ==============================
     string sEncounter;
     int nRandomSpawnPointTotal;
     //int i;
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
