#include "inc_debug"
#include "util_i_csvlists"

string VectorToString(vector vVector)
{
    return "#X#" + FloatToString(vVector.x, 0, 5) +
           "#Y#" + FloatToString(vVector.y, 0, 5) +
           "#Z#" + FloatToString(vVector.z, 0, 5) + "#";
}

void main()
{
       object oArea = OBJECT_SELF;
       string sResRef = GetResRef(oArea);
       SetTag(oArea, sResRef);

//===========================================================
// LOOP THROUGH EACH TILE, CREATING SPAWN POINTS
//===========================================================
       int i;


       int iRows = GetAreaSize(AREA_WIDTH, oArea);
       int iColumns = GetAreaSize(AREA_HEIGHT, oArea);

       int iXAxis, iYAxis;
       float fYAxis, fXAxis, fDistanceFromDoor, fDistanceBetweenPoints, fX, fY;
       location lTile, lValidator;
       object oValidator, oDoor;
       vector vTile, vValidator;

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

                lValidator = GetLocation(oValidator);

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

// we don't want spawns too close to a door. also, make sure the spot and the creature are around the same position
// using the Distance Between Two Points Formula:
                fX = vTile.x - vValidator.x;
                fY = vTile.y - vValidator.y;
                fDistanceBetweenPoints = sqrt((fX*fX) + (fY*fY));
                if (fDistanceBetweenPoints < 0.0) fDistanceBetweenPoints = 999.0;

                if (fDistanceFromDoor >= 3.0 && fDistanceBetweenPoints <= 2.0 && vValidator.z > -2.0)
                {
                    if (bTrapped)
                    {
                        SetCampaignString("spawns", sResRef+"_traps", AddListItem(GetCampaignString("spawns", sResRef+"_traps"), VectorToString(vValidator)));
                    }
                }

                DestroyObject(oValidator);
            }
        }

//==========================================
// SET AREA AS INITIALIZED
//==========================================
       string sScript = GetLocalString(oArea, "init_script");
       if (sScript != "") ExecuteScript(sScript, oArea);


       int nTraps = CountList(GetCampaignString("spawns", sResRef+"_traps"));
       if (nTraps > 0) SendDebugMessage(sResRef+" trap spawn points: "+IntToString(nTraps), TRUE);
       int nRandomSpawnPoints;
       for (i = 1; i < 10; i++)
       {
            nRandomSpawnPoints = CountList(GetCampaignString("spawns", sResRef+"_spawn"+IntToString(i)));
            if (nRandomSpawnPoints > 0) SendDebugMessage(sResRef+" random"+IntToString(i)+" spawn points: "+IntToString(nRandomSpawnPoints), TRUE);
       }

       SendDebugMessage("seeded "+sResRef, TRUE);
}

