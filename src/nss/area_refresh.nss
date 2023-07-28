#include "inc_loot"
#include "inc_debug"
#include "util_i_csvlists"
#include "nwnx_object"
#include "inc_sqlite_time"

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

    //if (bInstance == 1)
    //{
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

    //if (bInstance == 1)
    //{
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
