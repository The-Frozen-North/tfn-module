#include "inc_debug"
#include "util_i_csvlists"
#include "nwnx_area"

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

       if (!GetIsAreaInterior(oArea)) SetSkyBox(SKYBOX_GRASS_CLEAR, oArea);

       NWNX_Area_SetFogClipDistance(oArea, 90.0);


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
       string sTag, sQuest, sQuestName;
       int nTreasures = 0;
       int nEventSpawns = 0;
       int nCreatures = 0;
       int nDoors = 0;
       object oObject = GetFirstObjectInArea(oArea);
       int nType, nQuestLoop;
       int bInstance = GetLocalInt(oArea, "instance");
       vector vTreasureVector, vCreatureVector;
       float fTreasureOrientation;
       object oModule = GetModule();

// Loop through all objects in the area and do something special with them
       while (GetIsObjectValid(oObject))
       {
               nType = GetObjectType(oObject);

// tag merchants/quest NPCs that are plot/immortal as dm_immune
// these types should never be skipped
                if (nType == OBJECT_TYPE_CREATURE)
                {
                   for (nQuestLoop = 1; nQuestLoop < 10; nQuestLoop++)
                   {
                        sQuest = GetLocalString(oObject, "quest"+IntToString(nQuestLoop));
                        sQuestName = GetSubString(sQuest, 3, 27);

                        if (GetStringLeft(sQuestName, 2) == "q_")
                        {
                            SetLocalString(oModule, "quests", AddListItem(GetLocalString(oModule, "quests"), sQuestName, TRUE));
                        }
                        else if (GetStringLeft(sQuestName, 2) == "b_")
                        {
                            SetLocalString(oModule, "bounties", AddListItem(GetLocalString(oModule, "bounties"), sQuestName, TRUE));
                        }
                   }

                   if ( (GetLocalString(oObject, "quest1") != "" || GetLocalString(oObject, "merchant") != "") && (GetPlotFlag(oObject) || GetImmortal(oObject)) )
                          SetLocalInt(oObject, "dm_immune", 1);
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
                        if (GetLocked(oObject)) SetLocalInt(oArea, "door_locked"+IntToString(nDoors), 1);
                        SetLocalObject(oArea, "door"+IntToString(nDoors), oObject);
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

//==========================================
// LOAD SPAWNS
//==========================================

   string sRow;
   int nRandomSpawnPoints, nSpawnTarget;

   location lSpawnLocation;

   for (nSpawnTarget = 1; nSpawnTarget < 10; nSpawnTarget++)
   {
        sRow = GetCampaignString("spawns", sResRef+"_spawn"+IntToString(nSpawnTarget));
        nRandomSpawnPoints = CountList(sRow);

        if (nRandomSpawnPoints > 0)
        {
            SetLocalInt(oArea, "random"+IntToString(nSpawnTarget)+"_spawn_point_total", nRandomSpawnPoints);

            int i;
            for (i = 0; i < nRandomSpawnPoints; i++)
            {
                 lSpawnLocation = Location(oArea, StringToVector(GetListItem(sRow, i)), IntToFloat(Random(360)+1));
                 //if (GetLocalInt(GetModule(), "dev") == 1) CreateObject(OBJECT_TYPE_PLACEABLE, "plc_solblue", lSpawnLocation);

                 CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", lSpawnLocation, FALSE, sResRef+"_random"+IntToString(nSpawnTarget)+"_spawn_point"+IntToString(i+1));
            }
            SendDebugMessage(sResRef+" loaded random"+IntToString(nSpawnTarget)+" spawn points: "+IntToString(nRandomSpawnPoints), TRUE);
        }
   }

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

    // we will refresh it once so there's spawns
    ExecuteScript("area_refresh", oArea);

    SendDebugMessage("initialized "+sResRef, TRUE);
    SetLocalInt(oArea, "initialized", 1);
}

