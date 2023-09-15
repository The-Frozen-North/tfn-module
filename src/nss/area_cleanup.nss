#include "inc_trap"
#include "inc_general"
#include "util_i_csvlists"
#include "inc_lock"

void CleanupRandomSpawns(object oArea, int nTarget)
{
      string sResRef = GetResRef(oArea);
      int nMax = 100;

// Destroy all stored creatures.
// typically done on a refresh
      int i;
      for (i = 1; i <= nMax; i++)
      {
        DestroyObject(GetLocalObject(oArea, "random"+IntToString(nTarget)+"_creature"+IntToString(i)));
      }
}

void main()
{
    string sResRef = GetResRef(OBJECT_SELF);
    int iCR = GetLocalInt(OBJECT_SELF, "cr");

// clean up old treasures
    int nOldTreasure;
    int nNumOld = GetLocalInt(OBJECT_SELF, "num_spawned_treasures");
    for (nOldTreasure = 0; nOldTreasure < nNumOld; nOldTreasure++)
    {
        DestroyObject(GetLocalObject(OBJECT_SELF, "treasure"+IntToString(nOldTreasure)));
    }
    DeleteLocalInt(OBJECT_SELF, "num_spawned_treasures");

// clean up old events
    int nOldEvent;
    for (nOldEvent = 0; nOldEvent < 20; nOldEvent++)
    {
        DestroyObject(GetObjectByTag(sResRef+"_event", nOldEvent));
    }

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

// clean up old placeables
        int nOldPlaceable;
        object oOldPlaceable;
        for (nOldPlaceable = 0; nOldPlaceable < 200; nOldPlaceable++)
         {
            oOldPlaceable = GetLocalObject(OBJECT_SELF, "placeable"+IntToString(nOldPlaceable));

            if (GetIsObjectValid(oOldPlaceable) && GetLocalString(oOldPlaceable, "master") == "")
            {
                object oItem = GetFirstItemInInventory(oOldPlaceable);

                // clear all items on destruction
                while (GetIsObjectValid(oItem))
                {
                    DestroyObject(oItem);
                    oItem = GetNextItemInInventory(oOldPlaceable);
                }
                
                DestroyObject(oOldPlaceable);
            }
         }

// clean up old creatures
        int nOldCreature;
        object oOldCreature;
        for (nOldCreature = 0; nOldCreature < 200; nOldCreature++)
         {
            oOldCreature = GetLocalObject(OBJECT_SELF, "creature"+IntToString(nOldCreature));

// do not clean up creatures that have a PC master as they may be associates / followers
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

        int iRows = GetAreaSize(AREA_WIDTH, OBJECT_SELF);
        int iColumns = GetAreaSize(AREA_HEIGHT, OBJECT_SELF);
        int nTrapChance = (iRows*iColumns)/12;
    // cap the density of traps
         if (nTrapChance >= 30) nTrapChance = 30;

         if (GetLocalInt(OBJECT_SELF, "less_traps") == 1)
         {
            nTrapChance = nTrapChance/3;
         }

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
                    oTrap = CreateTrapAtLocation(DetermineTrap(iCR),GetLocation(oTrapWP), 2.5+(IntToFloat(Random(10)+1)/10.0), "", STANDARD_FACTION_HOSTILE, "on_trap_disarm");
                    TrapLogic(oTrap);

    // store the trap so it can deleted later on refresh
                    SetLocalObject(oTrapWP, "trap", oTrap);
                }
            }
        }

        int nDoors = GetLocalInt(OBJECT_SELF, "doors");
        object oDoor, oTransitionDoor;

        int i;
        for (i = 1; i <= nDoors; i++)
        {
            oDoor = GetLocalObject(OBJECT_SELF, "door"+IntToString(i));

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

            if (GetLocalInt(OBJECT_SELF, "door_locked"+IntToString(i)) == 1)
            {
                // if a key is not required to it, calculate the lock on this door
                if (GetLockKeyRequired(oDoor))
                {
                    SetLocked(oDoor, TRUE);
                }
                else
                {
                    GenerateLockOnObject(oDoor);
                }
            }
        }


     string sEncounter;
     for (i = 1; i < 10; i++)
     {
        sEncounter = GetLocalString(OBJECT_SELF, "random"+IntToString(i));
        if (sEncounter == "") continue;

        CleanupRandomSpawns(OBJECT_SELF, i);
     }
     
     string sScript = GetLocalString(OBJECT_SELF, "clean_script");
     if (sScript != "")
     {
         ExecuteScript(sScript, OBJECT_SELF);
     }
     
     SetLocalInt(OBJECT_SELF, "cleaned_time", SQLite_GetTimeStamp());
}
