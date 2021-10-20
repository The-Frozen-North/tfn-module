#include "inc_debug"
#include "util_i_csvlists"
#include "nwnx_object"



/* Declarations */
// Return iPinID of the first deleted map pin within the personal map pin array
int GetFirstDeletedMapPin(object oPC);

// Set a personal map pin on oPC. Returns iPinID.
// Defaults: GetArea(oPC) and fX/fY from GetPosition(oPC)
int SetMapPin(object oPC, string sPinText, float fX=-1.0, float fY=-1.0, object oArea=OBJECT_INVALID);

// Mark a map pin as deleted. Not a real delete to maintain the array
void DeleteMapPin(object oPC, int iPinID);

// Returns oArea from iPinID
object GetAreaOfMapPin(object oPC, int iPinID);

/* Implementation */
int GetFirstDeletedMapPin(object oPC)
{
   int i;
   int iPinID = 0;
   int iTotal = GetLocalInt(oPC, "NW_TOTAL_MAP_PINS");
   if(iTotal > 0) {
       for(i=1; i<=iTotal; i++) {
           if(GetLocalString(oPC, "NW_MAP_PIN_NTRY_" + IntToString(i)) == "DELETED") {
               iPinID = i;
               break;
           }
       }
   }
   return iPinID;
}

int SetMapPin(object oPC, string sPinText, float fX=-1.0, float fY=-1.0, object oArea=OBJECT_INVALID)
{
   // If oArea is not valid, we use the current area.
   // nope, we stop
   if(oArea == OBJECT_INVALID) {
        //oArea = GetArea(oPC);
        return FALSE;
   }
   // if fX and fY are both -1.0, we use the position of oPC
   // nope, we stop
   if(fX == -1.0 && fY == -1.0) {
       //vector vPos=GetPosition(oPC);
       //fX = vPos.x;
       //fY = vPos.y;
       return FALSE;
   }
   // Find out if we can reuse a deleted map pin
   int iUpdateDeleted = TRUE;
   int iPinID = 0;
   int iTotal = GetLocalInt(oPC, "NW_TOTAL_MAP_PINS");
   if(iTotal > 0) { iPinID = GetFirstDeletedMapPin(oPC); }
   // Otherwise use a new one
   if(iPinID == 0) { iPinID = iTotal + 1; iUpdateDeleted = FALSE; }
   // Set the pin
   string sPinID = IntToString(iPinID);
   SetLocalString(oPC, "NW_MAP_PIN_NTRY_" + sPinID, sPinText);
   SetLocalFloat(oPC, "NW_MAP_PIN_XPOS_" + sPinID, fX);
   SetLocalFloat(oPC, "NW_MAP_PIN_YPOS_" + sPinID, fY);
   SetLocalObject(oPC, "NW_MAP_PIN_AREA_" + sPinID, oArea);
   if(!iUpdateDeleted) { SetLocalInt(oPC, "NW_TOTAL_MAP_PINS", iPinID); }
   return iPinID;
}

void DeleteMapPin(object oPC, int iPinID)
{
   string sPinID = IntToString(iPinID);
   // Only mark as deleted if set
   if(GetLocalString(oPC, "NW_MAP_PIN_NTRY_" + sPinID) != "") {
       SetLocalString(oPC, "NW_MAP_PIN_NTRY_" + sPinID, "DELETED");
       SetLocalFloat(oPC, "NW_MAP_PIN_XPOS_" + sPinID, 0.0);
       SetLocalFloat(oPC, "NW_MAP_PIN_YPOS_" + sPinID, 0.0);
       SetLocalObject(oPC, "NW_MAP_PIN_AREA_" + sPinID, OBJECT_INVALID);
   }
}










// 1/SELL_HOUSE_LOSS_FACTOR = how much gold is lost from the buy price when selling a house
int SELL_HOUSE_LOSS_FACTOR = 5;


// destroys a house area
// fails if there is an item or creature in the area
// or if the regular DestroyArea call fails
int DestroyHouseArea(object oArea);
int DestroyHouseArea(object oArea)
{
    object oObject = GetFirstObjectInArea(oObject);
    int nObjectType;

    while (GetIsObjectValid(oObject))
    {
        nObjectType = GetObjectType(oObject);

        if (nObjectType == OBJECT_TYPE_ITEM || nObjectType == OBJECT_TYPE_CREATURE)
        {
            return FALSE; // do not destroy an area while there is a creature or item in it
        }

        oObject = GetNextObjectInArea(oArea);
    }

    return DestroyArea(oArea);
}

// Returns the CD key for the house with this tag
// "" on error
string GetHouseCDKey(string sTag);
string GetHouseCDKey(string sTag)
{
    return GetCampaignString("housing", sTag);
}

string GetHomeTagInDistrict(string sPlayerCDKey, string sAreaTag)
{
    string sList = GetCampaignString("housing", sAreaTag);
    string sListItem;
    string sCDKey;

    int i, nCount = CountList(sList);
    for (i = 0; i < nCount; i++)
    {
         sListItem = GetListItem(sList, i);
         sCDKey = GetCampaignString("housing", sListItem);

         if (sCDKey != "" && sCDKey == sPlayerCDKey)
            return sListItem;
    }

    return "";
}

string GetHomeTag(object oPC);
string GetHomeTag(object oPC)
{
    string sPlayerCDKey = GetPCPublicCDKey(oPC);

    if (GetHomeTagInDistrict(sPlayerCDKey, "begg") != "")
    {
        return GetHomeTagInDistrict(sPlayerCDKey, "begg");
    }
    else if (GetHomeTagInDistrict(sPlayerCDKey, "core") != "")
    {
        return GetHomeTagInDistrict(sPlayerCDKey, "core");
    }
    else if (GetHomeTagInDistrict(sPlayerCDKey, "dock") != "")
    {
        return GetHomeTagInDistrict(sPlayerCDKey, "dock");
    }
    else if (GetHomeTagInDistrict(sPlayerCDKey, "blak") != "")
    {
        return GetHomeTagInDistrict(sPlayerCDKey, "blak");
    }
    else
    {
        return "";
    }
}

// returns true if the PC is a homeless bum :P
// i.e he doesn't have a house in the beggar's nest, city core, docks, or blacklake
int GetIsPlayerHomeless(object oPC);
int GetIsPlayerHomeless(object oPC)
{
    if (GetHomeTag(oPC) == "")
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

// get the last player name for a house with this tag
string GetHousePlayerName(string sTag);
string GetHousePlayerName(string sTag)
{
    string sCDKey = GetHouseCDKey(sTag);

    if (sCDKey == "")
        return "";

    return GetCampaignString(sCDKey, "player_name");
}

// creates or deletes
void InitializeHouseMapPin(object oPC);
void InitializeHouseMapPin(object oPC)
{
   object oDoor = GetObjectByTag(GetHomeTag(oPC)+"_exterior_door");
   int nHouseMapPin = GetLocalInt(oPC, "house_map_pin");

   //SendDebugMessage("home tag: "+GetHomeTag(oPC), TRUE);
   //SendDebugMessage("home door exists: "+IntToString(GetIsObjectValid(oDoor)), TRUE);

   if (GetIsObjectValid(oDoor) && GetLocalString(oPC, "NW_MAP_PIN_NTRY_"+IntToString(nHouseMapPin)) != "Home")
   {
       vector vDoor = GetPosition(oDoor);

       SetLocalInt(oPC, "house_map_pin", SetMapPin(oPC, "Home", vDoor.x, vDoor.y, GetArea(oDoor)));
   }
   else
   {
       DeleteMapPin(oPC, nHouseMapPin);
   }
}


void InitializeHouse(object oArea)
{
    string sAreaTag = GetStringLeft(GetTag(oArea), 4);
    string sTag = GetTag(oArea);
    string sCoordinates = GetLocalString(oArea, "coordinates");

    string sAreaName;
    if (sAreaTag == "begg")
    {
        sAreaName = "Beggar's Nest";
    }
    else if (sAreaTag == "core")
    {
        sAreaName = "City Core";
    }
    else if (sAreaTag == "dock")
    {
        sAreaName = "Docks";
    }
    else if (sAreaTag == "blak")
    {
        sAreaName = "Blacklake";
    }

    string sName = "Neverwinter - "+sAreaName+" - House "+sCoordinates;

    string sPlayerName = GetHousePlayerName(sTag);
    if (sPlayerName != "")
    {
        sName = sName + " ("+sPlayerName+")";
    }
    SetName(oArea, sName);

    object oDoor = GetObjectByTag(sTag+"_exterior_door");
    if (GetHouseCDKey(sTag) == "")
    {
        SetName(oDoor, "Vacant Home "+sCoordinates);
    }
    else
    {
        SetName(oDoor, "Home ("+GetHousePlayerName(sTag)+")");
    }
}


void ClearHouseOwnership(object oDoor, object oPC);
void ClearHouseOwnership(object oDoor, object oPC)
{
    string sTag = GetLocalString(oDoor, "area");
    DeleteCampaignVariable("housing", sTag);
    FloatingTextStringOnCreature("You are no longer the owner of the house at "+GetName(GetArea(oDoor))+" "+GetLocalString(oDoor, "coordinates")+".", oPC, FALSE);
    InitializeHouse(GetObjectByTag(sTag));
}

int TakeHouseOwnership(object oPC, object oDoor);
int TakeHouseOwnership(object oPC, object oDoor)
{
    string sTag = GetLocalString(oDoor, "area");

    if (sTag == "")
    {
        SendDebugMessage("No tag for "+sTag, TRUE);
        return FALSE; // stop here, no tag
    }

    if (!GetIsPlayerHomeless(oPC))
    {
        SendDebugMessage("Player not homeless for "+sTag, TRUE);
        return FALSE; // stop here, player must be homeless
    }

    object oArea = GetObjectByTag(sTag);
    if (!GetIsObjectValid(oArea))
    {
        SendDebugMessage("Invalid area tag for "+sTag, TRUE);
        return FALSE; // stop here, cannot find area
    }

    SetCampaignString("housing", sTag, GetPCPublicCDKey(oPC));
    InitializeHouse(oArea);

    FloatingTextStringOnCreature("You are now the owner of the house at "+GetName(GetArea(oDoor))+" "+GetLocalString(oDoor, "coordinates")+"!", oPC, FALSE);
    return TRUE;
}

int GetHouseSellPrice(object oPC);
int GetHouseSellPrice(object oPC)
{
    int nGold = GetCampaignInt(GetPCPublicCDKey(oPC), "house_cost");

    if (nGold > 0)
    {
        nGold = nGold - (nGold/5);
    }
    else
    {
        nGold = 0;
    }

    return nGold;
}

object InstanceHouseArea(string sCoordinates, string sTag, float fOrientation);
object InstanceHouseArea(string sCoordinates, string sTag, float fOrientation)
{
    string sAreaTag = GetStringLeft(sTag, 4);
    string sDoorTag = GetSubString(sTag, 5, 4);

    object oAreaToDestroy = GetObjectByTag(sTag);
    //if (GetIsObjectValid(oAreaToDestroy) && DestroyHouseArea(oAreaToDestroy) < 1)
    //{
    //    SendDebugMessage("area could not be destroyed for "+sTag, TRUE);
    //    return OBJECT_INVALID; // stop here, the area already exists and it could not be destroyed
    //}

    if (GetIsObjectValid(oAreaToDestroy))
    {
        SendDebugMessage("area already exists for "+sTag, TRUE);
        return OBJECT_INVALID; // stop here, the area already exists
    }

    string sFacing;
    SendDebugMessage(sTag+" orientation: "+FloatToString(fOrientation), TRUE);
    if (fOrientation > 85.0 && fOrientation < 95.0)
    {
        sFacing = "south";
    }
    else if (fOrientation > 175.0 && fOrientation < 185.0)
    {
        sFacing = "east";
    }
    else if (fOrientation > 265.0 && fOrientation < 275.0)
    {
        sFacing = "north";
    }
    else if (fOrientation > -5.0 && fOrientation < 5.0)
    {
        sFacing = "west";
    }
    else
    {
        SendDebugMessage("Invalid orientation for "+sTag, TRUE);
        return OBJECT_INVALID; // stop here, the orientation is really wack
    }

    if (sDoorTag != "slum" && sDoorTag != "norm" && sDoorTag != "rich")
    {
        SendDebugMessage("Invalid template for "+sTag+" door tag: "+sDoorTag, TRUE);
        return OBJECT_INVALID; // stop here, invalid template
    }

    if (sAreaTag != "begg" && sAreaTag != "core" && sAreaTag != "dock" && sAreaTag != "blak")
    {
        SendDebugMessage("Invalid area tag for "+sTag, TRUE);
        return OBJECT_INVALID; // stop here, invalid area
    }

    object oArea = GetObjectByTag(sAreaTag);

    if (!GetIsObjectValid(oArea))
    {
        SendDebugMessage("Invalid area tag for "+sTag, TRUE);
        return OBJECT_INVALID; // stop here, cannot find area
    }

    object oNewArea = CreateArea("_home"+sDoorTag+"_"+sFacing, sTag);

    SendDebugMessage("_home"+sDoorTag+"_"+sFacing+" created: "+IntToString(GetIsObjectValid(oNewArea)), TRUE);
    SetLocalString(oNewArea, "coordinates", sCoordinates);
    object oObject = GetFirstObjectInArea(oNewArea);
    string sNewDoorTag;
    string sNewResRef;

    object oLevel1ToLevel2, oLevel2ToLevel1, oLevel2ToLevel3, oLevel3ToLevel2, oWaypoint;

    object oExteriorDoor = GetObjectByTag(sTag+"_exterior_door");
    SendDebugMessage(sTag+"_exterior_door found: "+IntToString(GetIsObjectValid(oExteriorDoor)), TRUE);

    while (GetIsObjectValid(oObject))
    {
        sNewResRef = GetResRef(oObject);
        sNewDoorTag = GetTag(oObject);
        if (sNewDoorTag == "interior_door")
        {
            //SendDebugMessage("interior_door found", TRUE);

            SetTag(oObject, sTag+"_interior_door");

            SetTransitionTarget(oExteriorDoor, oObject);
            SetTransitionTarget(oObject, oExteriorDoor);

            //oWaypoint = CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", GetLocation(oObject));
            //NWNX_Object_SetMapNote(oWaypoint, "Exit");
            //SetMapPinEnabled(oWaypoint, TRUE);
        }
        else if (sNewDoorTag == "level1_to_level2")
        {
            SetTag(oObject, sTag+"_level1_to_level2");
            oLevel1ToLevel2 = oObject;
        }
        else if (sNewDoorTag == "level2_to_level1")
        {
            SetTag(oObject, sTag+"_level2_to_level1");
            oLevel2ToLevel1 = oObject;
        }
        else if (sNewDoorTag == "level2_to_level3")
        {
            SetTag(oObject, sTag+"_level2_to_level3");
            oLevel2ToLevel3 = oObject;
        }
        else if (sNewDoorTag == "level3_to_level2")
        {
            SetTag(oObject, sTag+"_level3_to_level2");
            oLevel3ToLevel2 = oObject;
        }
        else if (GetStringLeft(sNewResRef, 7) == "storage" || GetStringLeft(sNewResRef, 12) == "gold_storage")
        {
            //oWaypoint = CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", GetLocation(oObject));
            //NWNX_Object_SetMapNote(oWaypoint, GetName(oObject));
            //SetMapPinEnabled(oWaypoint, TRUE);
        }

        oObject = GetNextObjectInArea(oNewArea);
    }

    if (GetIsObjectValid(oLevel1ToLevel2))
    {
        SetTransitionTarget(oLevel1ToLevel2, oLevel2ToLevel1);
        SetTransitionTarget(oLevel2ToLevel1, oLevel1ToLevel2);
    }

    if (GetIsObjectValid(oLevel2ToLevel3))
    {
        SetTransitionTarget(oLevel2ToLevel3, oLevel3ToLevel2);
        SetTransitionTarget(oLevel3ToLevel2, oLevel2ToLevel3);
    }

    InitializeHouse(oNewArea);

    return oNewArea;
}


//void main() {}
