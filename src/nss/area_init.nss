#include "inc_debug"
#include "nwnx_object"

void SetSpawnPoint(string sResRef, object oTable, int nTarget, location lLocation)
{
    object oTrigger;
    float fMaxHeight;
    vector vVector = GetPositionFromLocation(lLocation);
// loop through elevation 0, 1, and 2
    int i;
    for (i = 0; i < 3; i++)
    {
        oTrigger = GetObjectByTag(sResRef+"e"+IntToString(i)+"_random"+IntToString(nTarget)+"_spawn");

        fMaxHeight = 3.5;

        switch (GetLocalInt(oTrigger, "elevation"))
        {
            case 1: fMaxHeight = 7.0; break;
            case 2: fMaxHeight = 10.5; break;
        }

        if (GetIsObjectValid(oTrigger) && NWNX_Object_GetPositionIsInTrigger(oTrigger, vVector) && (vVector.z <= fMaxHeight))
        {
              int nSpawns = GetLocalInt(oTable, "random"+IntToString(nTarget)+"_spawn_point_total")+1;

              CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", lLocation, FALSE, sResRef+"_random"+IntToString(nTarget)+"_spawn_point"+IntToString(nSpawns));
              SetLocalInt(oTable, "random"+IntToString(nTarget)+"_spawn_point_total", nSpawns);
              break;
        }
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

       if (!GetIsAreaInterior(oArea)) SetSkyBox(SKYBOX_GRASS_CLEAR, oArea);


//==========================================
// COUNT RANDOM SPAWN TYPES IN AREA
//==========================================

       int nCount, nTarget;
       string sTarget;
// get the total amount of random spawns in the area
       for (nTarget = 1; nTarget < 10; nTarget++)
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
       string sTag;
       int nTreasures = 0;
       int nEventSpawns = 0;
       int nCreatures = 0;
       int nDoors = 0;
       object oObject = GetFirstObjectInArea(oArea);
       int nType;
       int bInstance = GetLocalInt(oArea, "instance");
       vector vTreasureVector, vCreatureVector;
       float fTreasureOrientation;

// Loop through all objects in the area and do something special with them
       while (GetIsObjectValid(oObject))
       {
           nType = GetObjectType(oObject);

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
                 case OBJECT_TYPE_TRIGGER:
// add the resref to a spawn trigger tag to work with the spawn system
                       if (GetStringLeft(GetResRef(oObject), 11) == "trig_random") SetTag(oObject, sResRef+GetTag(oObject));
                 break;
                 case OBJECT_TYPE_DOOR:
// nullify this, doors with an on click script do not function
                   SetEventScript(oObject, EVENT_SCRIPT_DOOR_ON_CLICKED, "");

// all doors are plot
                    SetPlotFlag(oObject, TRUE);

// instance doors get new scriptz and added to collection of doors
                    if (bInstance == 1)
                    {
                        SetEventScript(oObject, EVENT_SCRIPT_DOOR_ON_UNLOCK, "unlock");
                        SetEventScript(oObject, EVENT_SCRIPT_DOOR_ON_MELEE_ATTACKED, "bash_lock");
                        nDoors = nDoors + 1;
                        SetLocalObject(oArea, "door"+IntToString(nDoors), oObject);
                        if (GetLocked(oObject)) SetLocalInt(oArea, "door_locked"+IntToString(nDoors), 1);
                    }
                 break;
                 case OBJECT_TYPE_CREATURE:
                     if (bInstance == 1)
                     {
                          nCreatures = nCreatures + 1;

                          vCreatureVector = GetPosition(oObject);

                          SetLocalString(oArea, "creature_resref"+IntToString(nCreatures), GetResRef(oObject));
                          SetLocalFloat(oArea, "creature_x"+IntToString(nCreatures), vCreatureVector.x);
                          SetLocalFloat(oArea, "creature_y"+IntToString(nCreatures), vCreatureVector.y);
                          SetLocalFloat(oArea, "creature_z"+IntToString(nCreatures), vCreatureVector.z);
                          SetLocalFloat(oArea, "creature_o"+IntToString(nCreatures), GetFacing(oObject));

                          DestroyObject(oObject);
                     }
// tag merchants/quest NPCs that are plot/immortal as dm_immune
                     if ( (GetLocalString(oObject, "quest1") != "" || GetLocalString(oObject, "merchant") != "") && (GetPlotFlag(oObject) || GetImmortal(oObject)) )
                        SetLocalInt(oObject, "dm_immune", 1);
                 break;
                 case OBJECT_TYPE_PLACEABLE:
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
// If it is a treasure, count it, create the treasure WP, store the resref on it, then delete the treasure
                   else if (bInstance == 1 && GetStringLeft(GetResRef(oObject), 6) == "treas_")
                   {
                       nTreasures = nTreasures + 1;

                       vTreasureVector = GetPosition(oObject);

                       SetLocalString(oArea, "treasure_resref"+IntToString(nTreasures), GetResRef(oObject));
                       SetLocalFloat(oArea, "treasure_x"+IntToString(nTreasures), vTreasureVector.x);
                       SetLocalFloat(oArea, "treasure_y"+IntToString(nTreasures), vTreasureVector.y);
                       SetLocalFloat(oArea, "treasure_z"+IntToString(nTreasures), vTreasureVector.z);
                       SetLocalFloat(oArea, "treasure_o"+IntToString(nTreasures), GetFacing(oObject));
// treasures tagged with keep is always guaranteed
                       if (GetLocalInt(oObject, "keep") == 1) SetLocalInt(oArea, "treasure_keep"+IntToString(nTreasures), 1);

                        DestroyObject(oObject);
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

       SetLocalInt(oArea, "event_spawn_points", nEventSpawns);
       SetLocalInt(oArea, "treasures", nTreasures);
       SetLocalInt(oArea, "creatures", nCreatures);
       SetLocalInt(oArea, "doors", nDoors);

//===========================================================
// LOOP THROUGH EACH TILE, CREATING SPAWN POINTS
//===========================================================

       int iRows = GetAreaSize(AREA_WIDTH, oArea);
       int iColumns = GetAreaSize(AREA_HEIGHT, oArea);

       int nSpawns = 0;

       int iXAxis, iYAxis;
       float fYAxis, fXAxis, fDistanceFromDoor;
       location lTile;
       object oValidator, oDoor;
       vector vTile, vValidator;

       int i;

       int bTrapped = GetLocalInt(oArea, "trapped");

// use this to get the center of a tile
       float fMultiplier = 5.0;

// Loop through the X axis of an area
       for (iXAxis = 0; iXAxis < iRows; iXAxis++)
       {
            float fXAxis = fMultiplier+(IntToFloat(iXAxis)*fMultiplier*2.0);

// Loop through the Y axis of an area, following the previous X location
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
// in cases of a door not existing, just set the distance to a high number so it emulates not being close to a door
                    fDistanceFromDoor = 999.0;
                }

// we don't want spawns too close to a door. also, make sure the spot and creature position matches
                if (fDistanceFromDoor >= 3.0 && vTile.x == vValidator.x && vTile.y == vValidator.y)
                {
                    if (bTrapped)
                    {
                        nSpawns = nSpawns + 1;
                        CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", lTile, FALSE, sResRef+"_trap_spawn_point"+IntToString(nSpawns));
                    }

                    for (i = 1; i < 10; i++)
                    {
                        SetSpawnPoint(sResRef, oArea, i, lTile);
                    }
                }

                DestroyObject(oValidator);
            }
        }

        SetLocalInt(oArea, "trap_spawns", nSpawns);

//==========================================
// SET AREA AS INITIALIZED
//==========================================
       string sScript = GetLocalString(oArea, "init_script");
       if (sScript != "") ExecuteScript(sScript, oArea);


       if (nEventSpawns > 0) SendDebugMessage(sResRef+" event spawn points: "+IntToString(nEventSpawns), TRUE);
       if (nSpawns > 0) SendDebugMessage(sResRef+" trap spawn points: "+IntToString(nSpawns), TRUE);
       int nRandomSpawnPoints;
       for (i = 1; i < 10; i++)
       {
            nRandomSpawnPoints = GetLocalInt(oArea, "random"+IntToString(i)+"_spawn_point_total");
            if (nRandomSpawnPoints > 0) SendDebugMessage(sResRef+" random1 spawn points: "+IntToString(nRandomSpawnPoints), TRUE);
       }

       if (nDoors > 0) SendDebugMessage(sResRef+" doors: "+IntToString(nDoors), TRUE);
       if (nTreasures > 0) SendDebugMessage(sResRef+" treasures found: "+IntToString(nTreasures), TRUE);
       if (nCreatures > 0) SendDebugMessage(sResRef+" creatures: "+IntToString(nCreatures), TRUE);
       if (nSpawns > 0) SendDebugMessage(sResRef+" trap spawns: "+IntToString(nSpawns), TRUE);

// we will refresh it once so there's spawns
       ExecuteScript("area_refresh", oArea);

       SendDebugMessage("initialized "+sResRef, TRUE);
       SetLocalInt(oArea, "initialized", 1);
}

