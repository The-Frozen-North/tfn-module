#include "inc_debug"

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

//==========================================
// DEFAULT AREA SCRIPTS
//==========================================

// Set some special area scripts
       SetEventScript(oArea, EVENT_SCRIPT_AREA_ON_HEARTBEAT, "area_hb");
       SetEventScript(oArea, EVENT_SCRIPT_AREA_ON_ENTER, "area_enter_spawn");
       SetEventScript(oArea, EVENT_SCRIPT_AREA_ON_EXIT, "area_exit");

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
                       sTag = GetTag(oObject);

                       oTransitionTarget = GetTransitionTarget(oObject);
                       if (GetIsObjectValid(oTransitionTarget))
                       {
                           SetLocalString(oObject, "TRANSITION_TARGET", GetTag(oTransitionTarget));
                           SetEventScript(oObject, EVENT_SCRIPT_TRIGGER_ON_HEARTBEAT, "at_hb");
                       }
// add the resref to a spawn trigger tag
                       else if (GetStringLeft(GetResRef(oObject), 11) == "trig_random")
                       {
                           SetTag(oObject, sResRef+sTag);
                       }

                 break;
                 case OBJECT_TYPE_DOOR:
                    oTransitionTarget = GetTransitionTarget(oObject);
                    if (GetIsObjectValid(oTransitionTarget))
                    {
                        SetLocalString(oObject, "TRANSITION_TARGET", GetTag(oTransitionTarget));
                        SetEventScript(oObject, EVENT_SCRIPT_DOOR_ON_HEARTBEAT, "at_hb");
                    }

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

       if (!GetIsObjectValid(GetObjectByTag(sResRef+"+_spawn_table")))
       {
           SendDebugMessage(sResRef+" table not found, initializing spawns", TRUE);
           ExecuteScript("area_init_spawns", oArea);
       }

       SendDebugMessage("initialized "+sResRef, TRUE);
       SetLocalInt(oArea, "initialized", 1);
}

