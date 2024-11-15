#include "inc_trap"
#include "inc_general"
#include "util_i_csvlists"
#include "inc_lock"
#include "inc_area"

void main()
{
    string sResRef = GetResRef(OBJECT_SELF);
    int iCR = GetLocalInt(OBJECT_SELF, "cr");
    
    ProcessAreaCleanupList(OBJECT_SELF);

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

            if (d100() <= nTrapChance)
            {
                oTrap = CreateTrapAtLocation(DetermineTrap(iCR),GetLocation(oTrapWP), 2.5+(IntToFloat(Random(10)+1)/10.0), "", STANDARD_FACTION_HOSTILE, "on_trap_disarm");
                AddObjectToAreaCleanupList(OBJECT_SELF, oTrap);
                TrapLogic(oTrap);
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

     
     string sScript = GetLocalString(OBJECT_SELF, "clean_script");
     if (sScript != "")
     {
         ExecuteScript(sScript, OBJECT_SELF);
     }
     
     SetLocalInt(OBJECT_SELF, "cleaned_time", SQLite_GetTimeStamp());
}
