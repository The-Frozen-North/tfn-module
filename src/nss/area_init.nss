#include "inc_debug"
#include "util_i_csvlists"
#include "nwnx_area"
#include "nwnx_object"
#include "nwnx_creature"
#include "nw_inc_gff"
#include "inc_loot"

void MakeBook(object oObject)
{
    string sDescription = GetLocalString(oObject, "description");

    object oExamine = CreateObject(OBJECT_TYPE_PLACEABLE, "invisiblebook", GetLocation(oObject));
    SetName(oExamine, " ");
    SetDescription(oExamine, GetDescription(oObject));

// set a description on the book itself, to avoid players examining it to read it instead of "using" the book
    if (sDescription == "") sDescription = "Bound in leather, this tome looks well worn, and the writing on the cover has already started to fade.";
    SetDescription(oObject, sDescription);

    SetLocalObject(oObject, "examine", oExamine);
    SetPlotFlag(oObject, TRUE);
}

vector StringToVector(string sVector)
{
    vector vVector;

    int nLength = GetStringLength(sVector);

    if(nLength > 0)
    {
        int nPos, nCount;

        nPos = FindSubString(sVector, "#X#") + 3;
        nCount = FindSubString(GetSubString(sVector, nPos, nLength - nPos), "#");
        vVector.x = StringToFloat(GetSubString(sVector, nPos, nCount));

        nPos = FindSubString(sVector, "#Y#") + 3;
        nCount = FindSubString(GetSubString(sVector, nPos, nLength - nPos), "#");
        vVector.y = StringToFloat(GetSubString(sVector, nPos, nCount));

        nPos = FindSubString(sVector, "#Z#") + 3;
        nCount = FindSubString(GetSubString(sVector, nPos, nLength - nPos), "#");
        vVector.z = StringToFloat(GetSubString(sVector, nPos, nCount));
    }

    return vVector;
}

void main()
{
       object oArea = OBJECT_SELF;

// set the tag to be the resref in case I forget to put it
       string sResRef = GetResRef(oArea);
       SetTag(oArea, sResRef);

// never re-initialize an area
       if (GetLocalInt(oArea, "initialized") == 1) return;

// never do this for system areas, which always start with an underscore
       if (GetStringLeft(sResRef, 1) == "_") return;

       if (!GetIsAreaInterior(oArea))
       {
            if (NWNX_Area_GetWeatherChance(oArea, NWNX_AREA_WEATHER_CHANCE_SNOW) > 75)
            {
                SetSkyBox(SKYBOX_WINTER_CLEAR, oArea);
            }
            else
            {
                SetSkyBox(SKYBOX_GRASS_CLEAR, oArea);
            }
       }

       string sName = GetName(oArea);

        if (GetLocalString(oArea, "climate") == "")
       {
           string sTilesetResRef = GetTilesetResRef(oArea);

           if (FindSubString(sName, "Neverwinter") > -1)
           {
               SetLocalString(oArea, "climate", "moderate");
           }
           else if (FindSubString(sName, "Port Llast") > -1)
           {
               SetLocalString(oArea, "climate", "highland");
           }
           else if (FindSubString(sName, "Luskan") > -1 || sTilesetResRef == TILESET_RESREF_RURAL_WINTER || sTilesetResRef == TILESET_RESREF_FROZEN_WASTES || sTilesetResRef == TILESET_RESREF_RURAL_WINTER_FACELIFT)
           {
               SetLocalString(oArea, "climate", "polar");
           }
           else if (sTilesetResRef == TILESET_RESREF_DESERT)
           {
               SetLocalString(oArea, "climate", "desert");
           }
       }

       string sClimate = GetLocalString(oArea, "climate");
       if (GetLocalString(oArea, "climate") != "")
       {
           if (sClimate == "moderate")
           {
               NWNX_Area_SetWindPower(oArea, 1);
           }
           else if (sClimate == "highland")
           {
               NWNX_Area_SetWindPower(oArea, 2);
           }
           else if (sClimate == "polar")
           {
               NWNX_Area_SetWindPower(oArea, 2);
           }
           else if (sClimate == "desert")
           {
               NWNX_Area_SetWindPower(oArea, 0);
           }
            else if (sClimate == "jungle")
           {
               NWNX_Area_SetWindPower(oArea, 0);
           }
       }

       NWNX_Area_SetFogClipDistance(oArea, 90.0);


//==========================================
// COUNT RANDOM SPAWN TYPES IN AREA
//==========================================
       string sList, sListUnique;

       int nTarget;
// get the total amount of random spawns in the area
       for (nTarget = 1; nTarget < 10; nTarget++)
       {
           string sTarget = "random"+IntToString(nTarget);

           json jEncounter = TemplateToJson(GetLocalString(oArea, sTarget), RESTYPE_UTE);

           sList = "";
           sListUnique = "";

           if (jEncounter != JsonNull())
           {
                json jCreatureList = GffGetList(jEncounter, "CreatureList");
                int nTotal = JsonGetLength(jCreatureList);

                int nDifficulty = JsonGetInt(GffGetInt(jEncounter, "DifficultyIndex"));
                int nUniqueChance = 5;
                switch (nDifficulty)
                {
                     case 0: nUniqueChance = 5; break;  //very easy
                     case 1: nUniqueChance = 10; break; //easy
                     case 2: nUniqueChance = 15; break; //normal
                     case 3: nUniqueChance = 20; break; //hard
                     case 4: nUniqueChance = 25; break; //impossible
                }
                WriteTimestampedLogEntry("encounter difficulty: "+IntToString(nDifficulty));
                WriteTimestampedLogEntry("unique chance: "+IntToString(nUniqueChance));

                int nCreature;
                for (nCreature = 0; nCreature < nTotal; nCreature++)
                {
                      string sCreatureResRef = JsonGetString(GffGetResRef(JsonArrayGet(jCreatureList, nCreature), "ResRef"));
                      int nUnique = JsonGetInt(GffGetByte(JsonArrayGet(jCreatureList, nCreature), "SingleSpawn"));

                      if (nUnique == 1)
                      {
                            sListUnique = AddListItem(sListUnique, sCreatureResRef, TRUE);
                      }
                      else
                      {
                            sList = AddListItem(sList, sCreatureResRef, TRUE);
                      }
                }

                WriteTimestampedLogEntry(sTarget+"_list_unique "+sListUnique);
                WriteTimestampedLogEntry(sTarget+"_list "+sList);

                SetLocalString(oArea, sTarget+"_list_unique", sListUnique);
                SetLocalString(oArea, sTarget+"_list", sList);
                SetLocalInt(oArea, sTarget+"_unique_chance", nUniqueChance);
           }
       }

//==========================================
// COUNT RANDOM EVENT TYPES IN AREA
//==========================================

// up to 9 supported
       int nEventCount = 0;
       while (nEventCount < 9)
       {
           if (GetLocalString(oArea, "event"+IntToString(nEventCount+1)) == "") break;
           nEventCount = nEventCount + 1;
       }
       SetLocalInt(oArea, "events", nEventCount);

//==========================================
// DEFAULT AREA SCRIPTS
//==========================================

// Set some special area scripts
       SetEventScript(oArea, EVENT_SCRIPT_AREA_ON_HEARTBEAT, "area_hb");
       SetEventScript(oArea, EVENT_SCRIPT_AREA_ON_ENTER, "area_enter");
       SetEventScript(oArea, EVENT_SCRIPT_AREA_ON_EXIT, "area_exit");

//==========================================
// OBJECT LOOP
//==========================================

// Define the variables we need for the loop.
       string sTag, sQuest, sQuestName, sSpawnTarget;
       int nTreasures = 0;
       int nEventSpawns = 0;
       int nCreatures, nPlaceables = 0;
       int nDoors = 0;
       object oObject = GetFirstObjectInArea(oArea);
       int nType, nQuestLoop, nSpawnCount;
       //int bInstance = GetLocalInt(oArea, "instance");
       vector vTreasureVector, vCreatureVector, vPlaceableVector;
       float fTreasureOrientation;
       object oModule = GetModule();
       
       int nLowTreasure = 0;
       int nMediumTreasure = 0;
       int nHighTreasure = 0;
       int nLowNonKeepTreasure = 0;
       int nMediumNonKeepTreasure = 0;
       int nHighNonKeepTreasure = 0;
       json jNonKeepLowTreasure = JsonArray();
       json jNonKeepMedTreasure = JsonArray();
       json jNonKeepHighTreasure = JsonArray();
       
       int nACR = GetLocalInt(oArea, "cr");
       string sACR = IntToString(nACR);
       float fAreaSize = IntToFloat(GetAreaSize(AREA_HEIGHT, oArea)*GetAreaSize(AREA_WIDTH, oArea));
       int nTargetPlaceableGold = GetAreaTargetPlaceableLootValue(oArea);
       int nLowGold = GetLocalInt(oModule, "placeable_value_low_" + sACR);
       int nMedGold = GetLocalInt(oModule, "placeable_value_medium_" + sACR);
       int nHighGold = GetLocalInt(oModule, "placeable_value_high_" + sACR);
       json jKeepTreasures = JsonArray();
       
       int nThisTreasureGold;

// Loop through all objects in the area and do something special with them
       while (GetIsObjectValid(oObject))
       {
               nType = GetObjectType(oObject);

// tag merchants/quest NPCs that are plot/immortal as dm_immune
// these types should never be skipped
                if (nType == OBJECT_TYPE_CREATURE)
                {
                   int bQuestNPC = 0;
                   for (nQuestLoop = 1; nQuestLoop < 20; nQuestLoop++)
                   {
                        sQuest = GetLocalString(oObject, "quest"+IntToString(nQuestLoop));
                        sQuestName = GetSubString(sQuest, 3, 27);


                        if (GetStringLeft(sQuestName, 2) == "q_")
                        {
                            SetLocalString(oModule, "quests", AddListItem(GetLocalString(oModule, "quests"), sQuestName, TRUE));
                            bQuestNPC = 1;

                        }
                        else if (GetStringLeft(sQuestName, 2) == "b_")
                        {
                            SetLocalString(oModule, "bounties", AddListItem(GetLocalString(oModule, "bounties"), sQuestName, TRUE));
                            bQuestNPC = 1;
                        }
                   }

                   // Maintain a list of NPCs on the area too
                   // This is needed to know what to check for questgiver highlights without having to
                   // iterate over everything in the area more times
                   if (bQuestNPC)
                   {
                       // Don't mess with enemies
                       int nFaction = NWNX_Creature_GetFaction(oObject);
                       if (GetPlotFlag(oObject) || GetImmortal(oObject) || nFaction == STANDARD_FACTION_COMMONER || nFaction == STANDARD_FACTION_DEFENDER || nFaction == STANDARD_FACTION_MERCHANT)
                       {
                           SetLocalString(oArea, "quest_npcs", AddListItem(GetLocalString(oArea, "quest_npcs"), ObjectToString(oObject), TRUE));
                       }
                   }

                   if ( (GetLocalString(oObject, "quest1") != "" || GetLocalString(oObject, "merchant") != "") && (GetPlotFlag(oObject) || GetImmortal(oObject)) )
                          SetLocalInt(oObject, "dm_immune", 1);

                   // always skip immortals. assume they are special NPCs that are not instances
                   if (GetImmortal(oObject))
                   {
                       oObject = GetNextObjectInArea(oArea);
                       continue;
                   }

                   // always skip henchman
                   if (GetStringLeft(GetResRef(oObject), 4) == "hen_")
                   {
                       oObject = GetNextObjectInArea(oArea);
                       continue;
                   }
               }

               if (GetLocalInt(oObject, "skip") == 1)
               {
                   oObject = GetNextObjectInArea(oArea);
                   continue;
               }

               switch (nType)
               {
// Count event waypoints for use later.
                 case OBJECT_TYPE_WAYPOINT:
                       if (GetResRef(oObject) == "_wp_event")
                       {
                           nEventSpawns = nEventSpawns + 1;
                           SetTag(oObject, sResRef+"WP_EVENT"+IntToString(nEventSpawns));
                       }
                 break;
                 case OBJECT_TYPE_DOOR:
                    SetEventScript(oObject, EVENT_SCRIPT_DOOR_ON_OPEN, "door_open");
                    SetEventScript(oObject, EVENT_SCRIPT_DOOR_ON_CLOSE, "door_close");
                    if (GetEventScript(oObject, EVENT_SCRIPT_DOOR_ON_FAIL_TO_OPEN) != "")
                    {
                        SetLocalString(oObject, "onfailtoopen_script", GetEventScript(oObject, EVENT_SCRIPT_DOOR_ON_FAIL_TO_OPEN));
                    }
                    SetEventScript(oObject, EVENT_SCRIPT_DOOR_ON_FAIL_TO_OPEN, "door_failopen");
// nullify this, doors with an on click script do not function
                    SetEventScript(oObject, EVENT_SCRIPT_DOOR_ON_CLICKED, "");

// all doors are plot
                    SetPlotFlag(oObject, TRUE);

                 if (GetStringLeft(GetResRef(oObject), 5) != "_home")
                 {

// instance doors get new scriptz and added to collection of doors
                    //if (bInstance == 1)
                    //{
                    // every area is instanced now!
                        SetEventScript(oObject, EVENT_SCRIPT_DOOR_ON_UNLOCK, "unlock");
                        SetEventScript(oObject, EVENT_SCRIPT_DOOR_ON_MELEE_ATTACKED, "bash_lock");
                        nDoors = nDoors + 1;
                        if (GetLocked(oObject)) SetLocalInt(oArea, "door_locked"+IntToString(nDoors), 1);
                        SetLocalObject(oArea, "door"+IntToString(nDoors), oObject);
                    //}
                 }
                 break;
                 case OBJECT_TYPE_CREATURE:
                     if (GetStringLeft(GetResRef(oObject), 6) == "random")
                     {
                        sSpawnTarget = "random"+GetSubString(GetResRef(oObject), 6, 1);
                        nSpawnCount = GetLocalInt(oArea, sSpawnTarget+"_spawn_point_total")+1;
                        SetLocalInt(oArea, sSpawnTarget+"_spawn_point_total", nSpawnCount);
                        SetLocalLocation(oArea, sSpawnTarget+"_spawn_point"+IntToString(nSpawnCount), GetLocation(oObject));
                        DestroyObject(oObject);
                     }
                     //else if (bInstance == 1)
                     else {
                          nCreatures = nCreatures + 1;

                          vCreatureVector = GetPosition(oObject);

                          SetLocalString(oArea, "creature_resref"+IntToString(nCreatures), GetResRef(oObject));
                          SetLocalFloat(oArea, "creature_x"+IntToString(nCreatures), vCreatureVector.x);
                          SetLocalFloat(oArea, "creature_y"+IntToString(nCreatures), vCreatureVector.y);
                          SetLocalFloat(oArea, "creature_z"+IntToString(nCreatures), vCreatureVector.z);
                          SetLocalFloat(oArea, "creature_o"+IntToString(nCreatures), GetFacing(oObject));

                          DestroyObject(oObject);
                     }
                 break;
                 case OBJECT_TYPE_PLACEABLE:
// these are dynamic placeables that respawn when an area is refreshed
                   if (GetStringLeft(GetResRef(oObject), 4) == "plx_")
                   {
                          nPlaceables = nPlaceables + 1;

                          vPlaceableVector = GetPosition(oObject);

                          SetLocalString(oArea, "placeable_resref"+IntToString(nPlaceables), GetResRef(oObject));
                          SetLocalFloat(oArea, "placeable_x"+IntToString(nPlaceables), vPlaceableVector.x);
                          SetLocalFloat(oArea, "placeable_y"+IntToString(nPlaceables), vPlaceableVector.y);
                          SetLocalFloat(oArea, "placeable_z"+IntToString(nPlaceables), vPlaceableVector.z);
                          SetLocalFloat(oArea, "placeable_o"+IntToString(nPlaceables), GetFacing(oObject));

                          DestroyObject(oObject);
                   }
// any object has its items removed and converted to static
                   else if (GetHasInventory(oObject))
                   {
                          object oItem = GetFirstItemInInventory(oObject);
                          while (GetIsObjectValid(oItem))
                          {
                              DestroyObject(oItem);
                              oItem = GetNextItemInInventory(oObject);
                          }
                          NWNX_Object_SetHasInventory(oObject, FALSE);
                          NWNX_Object_SetPlaceableIsStatic(oObject, TRUE);
                          SetPlotFlag(oObject, TRUE);
                          NWNX_Object_SetDialogResref(oObject, "");
                   }
// If it is a treasure, count it, create the treasure WP, store the resref on it, then delete the treasure
                   //else if (bInstance == 1 && GetStringLeft(GetResRef(oObject), 6) == "treas_")
                   else if (GetStringLeft(GetResRef(oObject), 6) == "treas_")
                   {
                       nTreasures = nTreasures + 1;

                       vTreasureVector = GetPosition(oObject);

                       SetLocalString(oArea, "treasure_resref"+IntToString(nTreasures), GetResRef(oObject));
                       SetLocalFloat(oArea, "treasure_x"+IntToString(nTreasures), vTreasureVector.x);
                       SetLocalFloat(oArea, "treasure_y"+IntToString(nTreasures), vTreasureVector.y);
                       SetLocalFloat(oArea, "treasure_z"+IntToString(nTreasures), vTreasureVector.z);
                       SetLocalFloat(oArea, "treasure_o"+IntToString(nTreasures), GetFacing(oObject));
                       float fQualityMult = GetLocalFloat(oObject, "quality_mult");
                       string sTreasureTier = GetLocalString(oObject, "treasure");
                       if (sTreasureTier == "")
                       {
                           // Get as close as we can to these
                           if (GetLocalInt(oObject, "boss") + GetLocalInt(oObject, "semiboss"))
                           {
                               sTreasureTier = "high";
                           }
                       }
                       if (fQualityMult <= 0.0) {
                           if (sTreasureTier == "low") { fQualityMult = TREASURE_LOW_QUALITY; }
                           else if (sTreasureTier == "medium") { fQualityMult = TREASURE_MEDIUM_QUALITY; }
                           else if (sTreasureTier == "high") { fQualityMult = TREASURE_HIGH_QUALITY; }
                           else { fQualityMult = 1.0; }
                       }
                       SetLocalFloat(oArea, "treasure_quality_mult"+IntToString(nTreasures), fQualityMult);
                       float fQuantityMult = GetLocalFloat(oObject, "quantity_mult");
                       if (fQuantityMult <= 0.0) {
                           if (sTreasureTier == "low") { fQuantityMult = TREASURE_LOW_QUANTITY; }
                           else if (sTreasureTier == "medium") { fQuantityMult = TREASURE_MEDIUM_QUANTITY; }
                           else if (sTreasureTier == "high") { fQuantityMult = TREASURE_HIGH_QUANTITY; }
                           else { fQuantityMult = 1.0; }
                       }
                       if (sTreasureTier == "low")
                       {
                           nLowTreasure++;
                           if (!GetLocalInt(oObject, "keep"))
                           {
                               nLowNonKeepTreasure++;
                               jNonKeepLowTreasure = JsonArrayInsert(jNonKeepLowTreasure, JsonInt(nTreasures));
                           }
                           nThisTreasureGold = nLowGold;
                       }
                       else if (sTreasureTier == "medium")
                       {
                           nMediumTreasure++;
                           if (!GetLocalInt(oObject, "keep"))
                           {
                               nMediumNonKeepTreasure++;
                               jNonKeepMedTreasure = JsonArrayInsert(jNonKeepMedTreasure, JsonInt(nTreasures));
                           }
                           nThisTreasureGold = nMedGold;
                       }
                       else if (sTreasureTier == "high")
                       {
                           nHighTreasure++;
                           if (!GetLocalInt(oObject, "keep"))
                           {
                               nHighNonKeepTreasure++;
                               jNonKeepHighTreasure = JsonArrayInsert(jNonKeepHighTreasure, JsonInt(nTreasures));
                           }
                           nThisTreasureGold = nHighGold;
                       }
                       else
                       {
                           if (!GetLocalInt(oObject, "keep"))
                           {
                               WriteTimestampedLogEntry("Random placeable: " + GetName(oObject) + ", " + GetResRef(oObject) + " is missing \"treasure\" to denote its value and can't be spawned");
                           }
                           nThisTreasureGold = nMedGold;
                       }
                       SetLocalFloat(oArea, "treasure_quantity_mult"+IntToString(nTreasures), fQuantityMult);
// treasures tagged with keep is always guaranteed
                       if (GetLocalInt(oObject, "keep") == 1)
                       {
                           SetLocalInt(oArea, "treasure_keep"+IntToString(nTreasures), 1);
                           nTargetPlaceableGold = nTargetPlaceableGold - nThisTreasureGold;
                           jKeepTreasures = JsonArrayInsert(jKeepTreasures, JsonInt(nTreasures));
                       }

                        DestroyObject(oObject);
                   }
                   else if (GetTag(oObject) == "book")
                   {
                        DelayCommand(0.1, MakeBook(oObject));
                   }
// Otherwise, make it plot. It's likely a sign or a static item.
                   else
                   {
                        SetPlotFlag(oObject, TRUE);
                   }
                 break;
               }
           oObject = GetNextObjectInArea(oArea);
       }
       
      
       WriteTimestampedLogEntry("Area " + GetTag(oArea) + " has " + FloatToString(fAreaSize) + " total size");
       if (nLowTreasure > 0)
       {
        WriteTimestampedLogEntry("Area " + GetTag(oArea) + " has " + IntToString(nLowTreasure) + " low treasures, gold per treasure=" + IntToString(nLowGold));
       }
       if (nMediumTreasure > 0)
       {
        WriteTimestampedLogEntry("Area " + GetTag(oArea) + " has " + IntToString(nMediumTreasure) + " med treasures, gold per treasure=" + IntToString(nMedGold));
       }
       if (nHighTreasure > 0)
       {
        WriteTimestampedLogEntry("Area " + GetTag(oArea) + " has " + IntToString(nHighTreasure) + " high treasures, gold per treasure=" + IntToString(nHighGold));
       }
       int nMaxPlaceableGold = (nLowNonKeepTreasure * nLowGold) + (nMediumNonKeepTreasure * nMedGold) + (nHighNonKeepTreasure * nHighGold);
       if (nMaxPlaceableGold > 0)
       {
            float fPercent = 100.0 * IntToFloat(nMaxPlaceableGold)/IntToFloat(nTargetPlaceableGold);
            WriteTimestampedLogEntry("Area " + GetTag(oArea) + " has non-keep placeables that provide " + FloatToString(fPercent) + " percent of its target gold amount of " + IntToString(nTargetPlaceableGold));
            if (nHighTreasure > 0 && nHighGold > nTargetPlaceableGold)
            {
                WriteTimestampedLogEntry("Area " + GetTag(oArea) + " probably can't spawn its high placeables unless they are set to keep - high gold exceeds target (" + IntToString(nHighGold) + " vs " + IntToString(nTargetPlaceableGold));
            }
       }
       
       SetLocalInt(oArea, "target_placeable_gold", nTargetPlaceableGold);
       SetLocalJson(oArea, "high_treasures", jNonKeepHighTreasure);
       SetLocalJson(oArea, "med_treasures", jNonKeepMedTreasure);
       SetLocalJson(oArea, "low_treasures", jNonKeepLowTreasure);
       SetLocalJson(oArea, "keep_treasures", jKeepTreasures);

       SetLocalInt(oArea, "event_spawn_points", nEventSpawns);
       SetLocalInt(oArea, "treasures", nTreasures);
       SetLocalInt(oArea, "creatures", nCreatures);
       SetLocalInt(oArea, "placeables", nPlaceables);
       SetLocalInt(oArea, "doors", nDoors);

//==========================================
// LOAD SPAWNS
//==========================================

   location lSpawnLocation;


    string sTrapRow = GetCampaignString("spawns", sResRef+"_traps");
    int nTrapSpawnPoints = CountList(sTrapRow);

    if (nTrapSpawnPoints > 0)
    {
        SetLocalInt(oArea, "trap_spawns", nTrapSpawnPoints);

        int i;
        for (i = 0; i < nTrapSpawnPoints; i++)
        {
             lSpawnLocation = Location(oArea, StringToVector(GetListItem(sTrapRow, i)), 0.0);

             CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", lSpawnLocation, FALSE, sResRef+"_trap_spawn_point"+IntToString(i+1));
        }
        SendDebugMessage(sResRef+" loaded trap spawn points: "+IntToString(nTrapSpawnPoints), TRUE);
    }

//==========================================
// SET AREA AS INITIALIZED
//==========================================
    string sScript = GetLocalString(oArea, "init_script");
    if (sScript != "") ExecuteScript(sScript, oArea);


    if (nEventSpawns > 0) SendDebugMessage(sResRef+" event spawn points: "+IntToString(nEventSpawns), TRUE);

    if (nDoors > 0) SendDebugMessage(sResRef+" doors: "+IntToString(nDoors), TRUE);
    if (nTreasures > 0) SendDebugMessage(sResRef+" treasures found: "+IntToString(nTreasures), TRUE);
    if (nCreatures > 0) SendDebugMessage(sResRef+" creatures: "+IntToString(nCreatures), TRUE);
    if (nPlaceables > 0) SendDebugMessage(sResRef+" dynamic placeables: "+IntToString(nPlaceables), TRUE);

    // we will refresh it once so there's spawns
    ExecuteScript("area_refresh", oArea);

    SendDebugMessage("initialized "+sResRef, TRUE);
    SetLocalInt(oArea, "initialized", 1);
}

