#include "inc_debug"
#include "util_i_csvlists"

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

int GetIsHomelessInDistrict(string sPlayerCDKey, string sAreaTag)
{
    string sList = GetCampaignString("housing", sAreaTag);
    string sCDKey;
    SendDebugMessage(sList, TRUE);

    int i, nCount = CountList(sList);
    for (i = 0; i < nCount; i++)
    {
         sCDKey = GetCampaignString("housing", GetListItem(sList, i));

         SendDebugMessage(sAreaTag+" list"+IntToString(i)+" cd key "+sCDKey, TRUE);
// if there's a matching cd key, they aren't homeless in that district
         if (sCDKey != "" && sCDKey == sPlayerCDKey)
            return FALSE;
    }

    return TRUE;
}

// returns true if the PC is a homeless bum :P
// i.e he doesn't have a house in the beggar's nest, city core, docks, or blacklake
int GetIsPlayerHomeless(object oPC);
int GetIsPlayerHomeless(object oPC)
{
    string sPlayerCDKey = GetPCPublicCDKey(oPC);

    if (GetIsHomelessInDistrict(sPlayerCDKey, "begg") && GetIsHomelessInDistrict(sPlayerCDKey, "blak") && GetIsHomelessInDistrict(sPlayerCDKey, "dock") && GetIsHomelessInDistrict(sPlayerCDKey, "blak"))
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

    object oExteriorDoor = GetObjectByTag(sTag+"_exterior_door");
    SendDebugMessage(sTag+"_exterior_door found: "+IntToString(GetIsObjectValid(oExteriorDoor)), TRUE);

    while (GetIsObjectValid(oObject))
    {
        if (GetTag(oObject) == "interior_door")
        {
            SendDebugMessage("interior_door found", TRUE);

            SetTag(oObject, sTag+"_interior_door");

            SetTransitionTarget(oExteriorDoor, oObject);
            SetTransitionTarget(oObject, oExteriorDoor);
        }

        oObject = GetNextObjectInArea(oNewArea);
    }

    InitializeHouse(oNewArea);

    return oNewArea;
}


//void main() {}
