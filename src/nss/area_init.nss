#include "inc_trap"
#include "inc_loot"
#include "inc_debug"
#include "nwnx_object"

float GetMaxHeight(object oTrigger)
{
    float fMaxHeight = 3.5;
    switch (GetLocalInt(oTrigger, "elevation"))
    {
        case 1: fMaxHeight = 7.0; break;
        case 2: fMaxHeight = 10.5; break;
    }

    return fMaxHeight;
}

string ChooseSpawnRef(object oArea, int nTarget)
{
    string sTarget = "random"+IntToString(nTarget)+"_spawn";

    int nRandom = GetLocalInt(oArea, sTarget+"_total");

// choose a random a random spawn
    return GetLocalString(oArea, sTarget+IntToString(Random(nRandom)+1));
}

void CreateSpawns(object oArea, int nSpawnPoints, int nTarget)
{
      if (nSpawnPoints == 0) return;

      string sResRef = GetResRef(oArea);

      int nTotalSpawns = (nSpawnPoints/5) + (Random(nSpawnPoints/8));

      float fDensityMod = GetLocalFloat(oArea, "creature_density_mod");
      if (fDensityMod > 0.0) nTotalSpawns = FloatToInt(IntToFloat(nTotalSpawns)*fDensityMod);

      float fTargetDensityMod = GetLocalFloat(oArea, "random"+IntToString(nTarget)+"_density_mod");
      if (fTargetDensityMod > 0.0) nTotalSpawns = FloatToInt(IntToFloat(nTotalSpawns)*fTargetDensityMod);

      location lSpawnLocation;
      object oSpawn;
      int nSpawn;
      string sSpawnPoint;

      for (nSpawn = 0; nSpawn <= nTotalSpawns; nSpawn++)
      {
           sSpawnPoint = sResRef+"random"+IntToString(nTarget)+"_spawn_point"+IntToString(Random(nSpawnPoints)+1);
           oSpawn = GetObjectByTag(sSpawnPoint);

           CreateObject(OBJECT_TYPE_CREATURE, ChooseSpawnRef(oArea, nTarget), Location(oArea, GetPosition(oSpawn), IntToFloat(Random(360)+1)));
      }
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


//==========================================
// COUNT RANDOM SPAWN TYPES IN AREA
//==========================================

       int nCount, nTarget;
       string sTarget;
// get the total amount of random spawns in the area
       for (nTarget = 1; nTarget < 4; nTarget++)
       {
           nCount = 0;
           sTarget = "random"+IntToString(nTarget)+"_spawn";

// up to 24 supported
           while (nCount < 25)
           {
                if (GetLocalString(oArea, sTarget+IntToString(nCount+1)) == "") break;
                nCount = nCount + 1;
           }
// store the count. this will be used to pull random types of spawns
           SetLocalInt(oArea, sTarget+"_total", nCount);
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

//==========================================
// DEFAULT AREA SCRIPTS
//==========================================

// Set some special area scripts
       SetEventScript(oArea, EVENT_SCRIPT_AREA_ON_HEARTBEAT, "area_hb");
       SetEventScript(oArea, EVENT_SCRIPT_AREA_ON_ENTER, "area_enter");

//==========================================
// OBJECT LOOP
//==========================================

// Define the variables we need for the loop.
       string sTag;
       int nTreasures = 0;
       int nEventSpawns = 0;
       object oObject = GetFirstObjectInArea(oArea);
       int nType;
       object oTransitionTarget;
// Loop through all objects in the area and do something special with them
       while (GetIsObjectValid(oObject))
       {
           nType = GetObjectType(oObject);

               switch (nType)
               {
               // the transition target must be stored as a variable or it might break
                 case OBJECT_TYPE_WAYPOINT:
                       if (GetResRef(oObject) == "_wp_event")
                       {
                           nEventSpawns = nEventSpawns + 1;
                           SetTag(oObject, sResRef+"WP_EVENT"+IntToString(nEventSpawns));
                       }
                 break;
// the transition target must be stored as a variable or it might break
                 case OBJECT_TYPE_TRIGGER:
                       oTransitionTarget = GetTransitionTarget(oObject);
                       sTag = GetTag(oObject);
                       if (GetIsObjectValid(oTransitionTarget))
                       {
                           SetLocalString(oObject, "TRANSITION_TARGET", GetTag(oTransitionTarget));
                       }
// add the resref to a spawn trigger tag
                       else if (GetStringLeft(GetResRef(oObject), 11) == "trig_random")
                       {
                           SetTag(oObject, sResRef+sTag);
                       }

                 break;
                 case OBJECT_TYPE_DOOR:
                    SetEventScript(oObject, EVENT_SCRIPT_DOOR_ON_UNLOCK, "unlock");
// plot doors with an un-openable key cannot be bashed
                    if (GetLocked(oObject) && !(GetPlotFlag(oObject) && GetLockKeyRequired(oObject) && GetLockKeyTag(oObject) == ""))
                    {
                        SetEventScript(oObject, EVENT_SCRIPT_DOOR_ON_MELEE_ATTACKED, "bash_lock");
                    }
                   SetEventScript(oObject, EVENT_SCRIPT_DOOR_ON_CLICKED, "");
                 break;
                 case OBJECT_TYPE_PLACEABLE:
                   SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_UNLOCK, "unlock");
                   if (GetLocalInt(oObject, "skip") != 1)
                   {
// any object with an inventory is removed, including it's items
                       if (GetHasInventory(oObject))
                       {
                             object oItem = GetFirstItemInInventory(oObject);
                             while (GetIsObjectValid(oItem))
                             {
                                 DestroyObject(oItem);
                                 oItem = GetNextItemInInventory(oObject);
                             }
                             DestroyObject(oObject);
                       }
// If it is a treasure, count it for the formula.
                       else if (GetStringLeft(GetResRef(oObject), 6) == "treas_")
                       {
                            nTreasures = nTreasures + 1;
                       }
// Otherwise, make it plot. It's likely a sign or a static item.
                       else
                       {
                           SetPlotFlag(oObject, TRUE);
                       }
                   }
                 break;
               }
           oObject = GetNextObjectInArea(oArea);
       }

//==========================================
// TREASURE LOOP
//==========================================

// We need to loop through all the objects again
// And apply the correct density of treasures


// determine how dense an area should be in regards to treasures
       float fAreaSize = IntToFloat(GetAreaSize(AREA_HEIGHT, oArea)*GetAreaSize(AREA_WIDTH, oArea));

// increase these to DECREASE the proportion of creatures/treasure to the area
// higher number = less
       float fTreasureFactor = 175.0;

       float fNoTreasureMod = GetLocalFloat(oArea, "no_treasure_mod");
       if (fNoTreasureMod > 0.0) fTreasureFactor = fTreasureFactor*fNoTreasureMod;

       int nNoTreasureChance;
       if (nTreasures == 0 || fAreaSize == 0.0)
       {
           nNoTreasureChance = 0;
       }
       else
       {
           nNoTreasureChance = FloatToInt((IntToFloat(nTreasures)/fAreaSize)*fTreasureFactor);
       }

       oObject = GetFirstObjectInArea(oArea);

       while (GetIsObjectValid(oObject))
       {
           if (GetLocalInt(oObject, "skip") != 1 && GetObjectType(oObject) == OBJECT_TYPE_PLACEABLE && GetStringLeft(GetResRef(oObject), 6) == "treas_" && d100() <= nNoTreasureChance) DestroyObject(oObject);

           oObject = GetNextObjectInArea(oArea);
       }

//===========================================================
// LOOP THROUGH EACH TILE, CREATING TRAPS AND SPAWN POINTS
//===========================================================

       int iCR = GetLocalInt(oArea, "cr");
       int bTrapped = GetLocalInt(oArea, "trapped");

       int iRows = GetAreaSize(AREA_WIDTH, oArea);
       int iColumns = GetAreaSize(AREA_HEIGHT, oArea);

       int nTrapChance = (iRows*iColumns)/12;
       int nCreatureSpawns1 = 0;
       int nCreatureSpawns2 = 0;
       int nCreatureSpawns3 = 0;
       int nSpawns = 0;

       int nMaxTriggers = 1;

// cap the density
       if (nTrapChance >= 40) nTrapChance = 30;

       int iXAxis;
       int iYAxis;
       float fYAxis, fXAxis, fDistanceFromDoor;
       location lTile;
       object oValidator, oTrap, oDoor;
       vector vTile, vValidator;

       int bCreatureSpawnNotFound = TRUE;

       object oTrigger;
       int i;

// use this to get the center of a tile
       float fMultiplier = 5.0;

       for (iXAxis = 0; iXAxis < iRows; iXAxis++)
       {
            float fXAxis = fMultiplier+(IntToFloat(iXAxis)*fMultiplier*2.0);
            for (iYAxis = 0; iYAxis < iColumns; iYAxis++)
            {
                fYAxis = fMultiplier+(IntToFloat(iYAxis)*fMultiplier*2.0);

                lTile = Location(oArea, Vector(fXAxis, fYAxis, 0.0), 0.0);

// we will spawn a creature at the exact location to check if it is in the proper spot
                oValidator = CreateObject(OBJECT_TYPE_CREATURE, "_area_validator", lTile);

                vTile = GetPositionFromLocation(lTile);
                vValidator = GetPosition(oValidator);

                oDoor = GetNearestObjectToLocation(OBJECT_TYPE_DOOR,lTile);
                if (GetIsObjectValid(oDoor))
                {
                    fDistanceFromDoor = GetDistanceBetweenLocations(GetLocation(GetNearestObjectToLocation(OBJECT_TYPE_DOOR,lTile)), lTile);
                }
                else
                {
                    fDistanceFromDoor = 999.0;
                }

// we don't want spawns too close to a door. also, make sure the spot and creature position matches
                if (fDistanceFromDoor >= 3.0 && vTile.x == vValidator.x && vTile.y == vValidator.y)
                {
                    if (GetLocalInt(GetModule(), "debug_verbose") == 1) CreateObject(OBJECT_TYPE_PLACEABLE, "plc_magicred", lTile);

                    nSpawns = nSpawns + 1;

                    bCreatureSpawnNotFound = TRUE;

// check if this is within a proper spawn trigger, and if so increment the count for that particular spawn
// if we already found a spawn point, we won't do the others, in order of 1, 2, and 3
                    for (i = 0; bCreatureSpawnNotFound && i <= nMaxTriggers; i++)
                    {
                        oTrigger = GetObjectByTag(sResRef+"e0_random1_spawn", i);
                        if (GetIsObjectValid(oTrigger) && NWNX_Object_GetPositionIsInTrigger(oTrigger, vTile) && (vValidator.z <= GetMaxHeight(oTrigger)))
                        {
                            bCreatureSpawnNotFound = FALSE;
                            nCreatureSpawns1 = nCreatureSpawns1 + 1;
                            CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", lTile, FALSE, sResRef+"random1_spawn_point"+IntToString(nCreatureSpawns1));
                            break;
                        }
                    }

                    for (i = 0; bCreatureSpawnNotFound && i <= nMaxTriggers; i++)
                    {
                        oTrigger = GetObjectByTag(sResRef+"e1_random1_spawn", i);
                        if (GetIsObjectValid(oTrigger) && NWNX_Object_GetPositionIsInTrigger(oTrigger, vTile) && (vValidator.z <= GetMaxHeight(oTrigger)))
                        {
                            bCreatureSpawnNotFound = FALSE;
                            nCreatureSpawns1 = nCreatureSpawns1 + 1;
                            CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", lTile, FALSE, sResRef+"random1_spawn_point"+IntToString(nCreatureSpawns1));
                            break;
                        }
                    }

                    for (i = 0; bCreatureSpawnNotFound && i <= nMaxTriggers; i++)
                    {
                        oTrigger = GetObjectByTag(sResRef+"e2_random1_spawn", i);
                        if (GetIsObjectValid(oTrigger) && NWNX_Object_GetPositionIsInTrigger(oTrigger, vTile) && (vValidator.z <= GetMaxHeight(oTrigger)))
                        {
                            bCreatureSpawnNotFound = FALSE;
                            nCreatureSpawns1 = nCreatureSpawns1 + 1;
                            CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", lTile, FALSE, sResRef+"random1_spawn_point"+IntToString(nCreatureSpawns1));
                            break;
                        }
                    }
// same for spawn 2
                    for (i = 0; bCreatureSpawnNotFound && i <= nMaxTriggers; i++)
                    {
                        oTrigger = GetObjectByTag(sResRef+"e0_random2_spawn", i);
                        if (GetIsObjectValid(oTrigger) && NWNX_Object_GetPositionIsInTrigger(oTrigger, vTile) && (vValidator.z <= GetMaxHeight(oTrigger)))
                        {
                            bCreatureSpawnNotFound = FALSE;
                            nCreatureSpawns2 = nCreatureSpawns2 + 1;
                            CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", lTile, FALSE, sResRef+"random2_spawn_point"+IntToString(nCreatureSpawns2));
                            break;
                        }
                    }

                    for (i = 0; bCreatureSpawnNotFound && i <= nMaxTriggers; i++)
                    {
                        oTrigger = GetObjectByTag(sResRef+"e1_random2_spawn", i);
                        if (GetIsObjectValid(oTrigger) && NWNX_Object_GetPositionIsInTrigger(oTrigger, vTile) && (vValidator.z <= GetMaxHeight(oTrigger)))
                        {
                            bCreatureSpawnNotFound = FALSE;
                            nCreatureSpawns2 = nCreatureSpawns2 + 1;
                            CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", lTile, FALSE, sResRef+"random2_spawn_point"+IntToString(nCreatureSpawns2));
                            break;
                        }
                    }

                    for (i = 0; bCreatureSpawnNotFound && i <= nMaxTriggers; i++)
                    {
                        oTrigger = GetObjectByTag(sResRef+"e2_random2_spawn", i);
                        if (GetIsObjectValid(oTrigger) && NWNX_Object_GetPositionIsInTrigger(oTrigger, vTile) && (vValidator.z <= GetMaxHeight(oTrigger)))
                        {
                            bCreatureSpawnNotFound = FALSE;
                            nCreatureSpawns2 = nCreatureSpawns2 + 1;
                            CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", lTile, FALSE, sResRef+"random2_spawn_point"+IntToString(nCreatureSpawns2));
                            break;
                        }
                    }
// same for spawn 3
                    for (i = 0; bCreatureSpawnNotFound && i <= nMaxTriggers; i++)
                    {
                        oTrigger = GetObjectByTag(sResRef+"e0_random3_spawn", i);
                        if (GetIsObjectValid(oTrigger) && NWNX_Object_GetPositionIsInTrigger(oTrigger, vTile) && (vValidator.z <= GetMaxHeight(oTrigger)))
                        {
                            bCreatureSpawnNotFound = FALSE;
                            nCreatureSpawns3 = nCreatureSpawns3 + 1;
                            CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", lTile, FALSE, sResRef+"random3_spawn_point"+IntToString(nCreatureSpawns3));
                            break;
                        }
                    }

                    for (i = 0; bCreatureSpawnNotFound && i <= nMaxTriggers; i++)
                    {
                        oTrigger = GetObjectByTag(sResRef+"e1_random3_spawn", i);
                        if (GetIsObjectValid(oTrigger) && NWNX_Object_GetPositionIsInTrigger(oTrigger, vTile) && (vValidator.z <= GetMaxHeight(oTrigger)))
                        {
                            bCreatureSpawnNotFound = FALSE;
                            nCreatureSpawns3 = nCreatureSpawns3 + 1;
                            CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", lTile, FALSE, sResRef+"random3_spawn_point"+IntToString(nCreatureSpawns3));
                            break;
                        }
                    }

                    for (i = 0; bCreatureSpawnNotFound && i <= nMaxTriggers; i++)
                    {
                        oTrigger = GetObjectByTag(sResRef+"e2_random3_spawn", i);
                        if (GetIsObjectValid(oTrigger) && NWNX_Object_GetPositionIsInTrigger(oTrigger, vTile) && (vValidator.z <= GetMaxHeight(oTrigger)))
                        {
                            bCreatureSpawnNotFound = FALSE;
                            nCreatureSpawns3 = nCreatureSpawns3 + 1;
                            CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", lTile, FALSE, sResRef+"random3_spawn_point"+IntToString(nCreatureSpawns3));
                            break;
                        }
                    }

// determine if there should be a trap
                    if (bTrapped == 1 && d100() <= nTrapChance)
                    {
                        oTrap = CreateTrapAtLocation(DetermineTrap(iCR), lTile, 2.5+(IntToFloat(Random(10)+1)/10.0));
                        TrapLogic(oTrap);
                    }
                }
// destroy the object we used to see if it is a valid location
                DestroyObject(oValidator);
            }
        }

//==========================================
// CREATE CREATURE SPAWNS
//==========================================
        SendDebugMessage(sResRef+" total spawns : "+IntToString(nSpawns), TRUE);
        SendDebugMessage(sResRef+" total spawns1 : "+IntToString(nCreatureSpawns1), TRUE);
        SendDebugMessage(sResRef+" total spawns2 : "+IntToString(nCreatureSpawns2), TRUE);
        SendDebugMessage(sResRef+" total spawns3 : "+IntToString(nCreatureSpawns3), TRUE);

        CreateSpawns(oArea, nCreatureSpawns1, 1);
        CreateSpawns(oArea, nCreatureSpawns2, 2);
        CreateSpawns(oArea, nCreatureSpawns3, 3);

//==========================================
// CREATE EVENT
//==========================================

// 25% chance of an event
        SendDebugMessage(sResRef+" event spawns : "+IntToString(nEventSpawns), TRUE);
        if (nEventSpawns > 0 && d3() == 1)
        {
            int nEventNum = Random(nEventCount)+1;
            string sEvent = GetLocalString(oArea, "event"+IntToString(nEventNum));
            string sEventWP = sResRef+"WP_EVENT"+IntToString(Random(nEventSpawns)+1);
            object oEventWP = GetObjectByTag(sEventWP);

            SendDebugMessage(sResRef+" chosen event num : "+IntToString(nEventNum), TRUE);
            SendDebugMessage(sResRef+" chosen event : "+sEvent, TRUE);
            SendDebugMessage(sResRef+" event WP : "+sEventWP, TRUE);
            SendDebugMessage(sResRef+" event WP exists : "+IntToString(GetIsObjectValid(oEventWP)), TRUE);


            ExecuteScript(sEvent, oEventWP);
        }

//==========================================
// SET AREA AS INITIALIZED
//==========================================
       string sScript = GetLocalString(oArea, "init_script");
       if (sScript != "") ExecuteScript(sScript, oArea);

       SendDebugMessage("initialized "+sResRef, TRUE);
       SetLocalInt(oArea, "initialized", 1);
}

