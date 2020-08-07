#include "inc_debug"
#include "nwnx_object"


void main()
{
       object oArea = OBJECT_SELF;

       string sResRef = GetResRef(oArea);

// never do this if the spawn table is already created
       if (GetIsObjectValid(GetObjectByTag(sResRef+"+_spawn_table"))) return;

       object oTable = CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", Location(GetObjectByTag("_BASE"), Vector(1.0, 1.0, 1.0), 0.0), FALSE, sResRef+"+_spawn_table");

//==========================================
// COUNT RANDOM SPAWN TYPES IN AREA
//==========================================

       int nCount, nTarget, bSpawns;

       int bNoSpawns = FALSE;

       string sTarget;
// get the total amount of random spawns in the area
       for (nTarget = 1; nTarget < 9; nTarget++)
       {
           nCount = 0;
           sTarget = "random"+IntToString(nTarget)+"_spawn";

// up to 24 supported
           while (nCount < 25)
           {
                if (GetLocalString(oArea, sTarget+IntToString(nCount+1)) == "") break;

                bSpawns = TRUE;
                nCount = nCount + 1;
           }
// store the count. this will be used to pull random types of spawns
           SetLocalInt(oTable, sTarget+"_total", nCount);
        }

        int bTrapped = GetLocalInt(oArea, "trapped");

// no point in continuing if there are no spawns and no traps
        if (bNoSpawns && bTrapped == 0) return;

//===========================================================
// LOOP THROUGH EACH TILE, CREATING SPAWN POINTS
//===========================================================

       int iRows = GetAreaSize(AREA_WIDTH, oArea);
       int iColumns = GetAreaSize(AREA_HEIGHT, oArea);

       int nSpawns = 0;

       int iXAxis;
       int iYAxis;
       float fYAxis, fXAxis, fDistanceFromDoor;
       location lTile;
       object oValidator, oTrap, oDoor;
       vector vTile, vValidator;

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
                    nSpawns = nSpawns + 1;

                    SetLocalFloat(oTable, "spawn"+IntToString(nSpawns)+"x", vValidator.x);
                    SetLocalFloat(oTable, "spawn"+IntToString(nSpawns)+"y", vValidator.y);
                    SetLocalFloat(oTable, "spawn"+IntToString(nSpawns)+"z", vValidator.z);

                    SetLocalString(oValidator, "target_spawn", "spawn"+IntToString(nSpawns));

                }

                DelayCommand(0.000000001, ExecuteScript("area_set_spawn", oValidator));
            }
        }

        SetLocalInt(oTable, "trap_spawns", nSpawns);

}

