#include "inc_debug"
#include "util_i_csvlists"
#include "nwnx_object"
#include "inc_ctoken"
#include "nwnx_area"
#include "x0_i0_position"
#include "nwnx_item"
#include "inc_general"

const string MODULE_HOME_TAG_SUFFIX = "_home_tag";

//const int MAX_PETS_SLUM_HOUSE = 2;
//const int MAX_PETS_NORMAL_HOUSE = 3;
//const int MAX_PETS_RICH_HOUSE = 4;

const int MAX_PETS = 3;

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
    object oObject = GetFirstObjectInArea(oArea);
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

string GetHomeTagByCDKey(string sPlayerCDKey);
string GetHomeTagByCDKey(string sPlayerCDKey)
{
    object oModule = GetModule();
    
    // get the cached home tag if present
    string sModuleLocal = GetLocalString(GetModule(), sPlayerCDKey+MODULE_HOME_TAG_SUFFIX);

    // this won't be retrieved for the first time, but on any subsequent try if they have a home
    if (sModuleLocal != "")
    {
        return sModuleLocal;
    }
    
    if (GetHomeTagInDistrict(sPlayerCDKey, "begg") != "")
    {
        // cache the result
        SetLocalString(oModule, sPlayerCDKey+MODULE_HOME_TAG_SUFFIX, GetHomeTagInDistrict(sPlayerCDKey, "begg"));
        return GetHomeTagInDistrict(sPlayerCDKey, "begg");
    }
    else if (GetHomeTagInDistrict(sPlayerCDKey, "core") != "")
    {
        SetLocalString(oModule, sPlayerCDKey+MODULE_HOME_TAG_SUFFIX, GetHomeTagInDistrict(sPlayerCDKey, "core"));
        return GetHomeTagInDistrict(sPlayerCDKey, "core");
    }
    else if (GetHomeTagInDistrict(sPlayerCDKey, "dock") != "")
    {
        SetLocalString(oModule, sPlayerCDKey+MODULE_HOME_TAG_SUFFIX, GetHomeTagInDistrict(sPlayerCDKey, "dock"));
        return GetHomeTagInDistrict(sPlayerCDKey, "dock");
    }
    else if (GetHomeTagInDistrict(sPlayerCDKey, "blak") != "")
    {
        SetLocalString(oModule, sPlayerCDKey+MODULE_HOME_TAG_SUFFIX, GetHomeTagInDistrict(sPlayerCDKey, "blak"));
        return GetHomeTagInDistrict(sPlayerCDKey, "blak");
    }
    else
    {
        // if for some reason this fails, just delete the stored home tag
        DeleteLocalString(oModule, sPlayerCDKey+MODULE_HOME_TAG_SUFFIX);
        return "";
    }
}

string GetHomeTag(object oPC);
string GetHomeTag(object oPC)
{
    string sPlayerCDKey = GetPCPublicCDKey(oPC);

    return GetHomeTagByCDKey(sPlayerCDKey);
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

int GetAvailablePetSlot(object oPC)
{
    // player's housing DB
    string sDB = GetPCPublicCDKey(oPC);
    
    if (GetCampaignString(sDB, "pet1_resref") == "") return 1;
    if (GetCampaignString(sDB, "pet2_resref") == "") return 2;
    if (GetCampaignString(sDB, "pet3_resref") == "") return 3;

    // all slots full
    return -1;
}

// TODO: Spawn at saved location vs static waypoints
void SpawnPet(string sCDKey, int nTarget, object oArea)
{
    // invalid slot, do nothing
    if (nTarget == -1) return;

    string sTarget = IntToString(nTarget);

    string sTag = sCDKey+"_pet"+sTarget;

    // failsafe in case the same pet was spawned
    if (GetIsObjectValid(GetObjectByTag(sTag))) return;

    string sName = GetCampaignString(sCDKey, "pet"+sTarget+"_name");
    string sResRef = GetCampaignString(sCDKey, "pet"+sTarget+"_resref");
    string sPortraitResRef = GetCampaignString(sCDKey, "pet"+sTarget+"_portrait_resref");
    int nTailModel = GetCampaignInt(sCDKey, "pet"+sTarget+"_tail_model");
    int nAppearanceType = GetCampaignInt(sCDKey, "pet"+sTarget+"_appearance_type");
    //location lLocation = GetCampaignLocation(sCDKey, "pet"+sTarget+"_location");
    
    location lLocation = GetLocation(GetNearestObjectByTag("PET_WP"+sTarget, GetFirstObjectInArea(oArea, OBJECT_TYPE_DOOR)));

    object oPet = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lLocation, FALSE, sTag);

    SetCreatureAppearanceType(oPet, nAppearanceType);
    
    if (nTailModel > 0)
    {
        SetCreatureTailType(nTailModel, oPet);
    }

    SetPortraitResRef(oPet, sPortraitResRef);
    SetName(oPet, sName);

    SetImmortal(oPet, TRUE);

    SetLocalInt(oPet, "target", nTarget);
    SetLocalString(oPet, "cd_key", sCDKey);
}

void SpawnPets(string sCDKey, object oArea)
{
    SpawnPet(sCDKey, 1, oArea);
    SpawnPet(sCDKey, 2, oArea);
    SpawnPet(sCDKey, 3, oArea);
}

void AdoptPet(object oPC, object oPet)
{
    // despite what you see in real life, hobos do not get pets!
    if (GetIsPlayerHomeless(oPC)) return; 

    int nTarget = GetAvailablePetSlot(oPC);

    // invalid slot or too many pets, do nothing
    if (nTarget == -1) return;

    string sTarget = IntToString(nTarget);

    // player's housing DB
    string sDB = GetPCPublicCDKey(oPC);

    SetCampaignString(sDB, "pet"+sTarget+"_name", GetName(oPet));
    SetCampaignString(sDB, "pet"+sTarget+"_resref", GetResRef(oPet));
    SetCampaignString(sDB, "pet"+sTarget+"_portrait_resref", GetPortraitResRef(oPet));
    SetCampaignInt(sDB, "pet"+sTarget+"_tail_model", GetCreatureTailType(oPet));
    SetCampaignInt(sDB, "pet"+sTarget+"_appearance_type", GetAppearanceType(oPet));
    //SetCampaignLocation(sDB, "pet"+sTarget+"_location", GetLocation(oPet));

    SpawnPet(sDB, nTarget, GetObjectByTag(GetHomeTag(oPC)));
}

void AbandonPet(object oPC, object oPet)
{
    string sDB = GetPCPublicCDKey(oPC);

    int nTarget = GetLocalInt(oPet, "target");
    string sTarget = IntToString(nTarget);

    DeleteCampaignVariable(sDB, "pet"+sTarget+"_name");
    DeleteCampaignVariable(sDB, "pet"+sTarget+"_resref");
    DeleteCampaignVariable(sDB, "pet"+sTarget+"_portrait_resref");
    DeleteCampaignVariable(sDB, "pet"+sTarget+"_tail_model");
    DeleteCampaignVariable(sDB, "pet"+sTarget+"_appearance_type");
    DeleteCampaignVariable(sDB, "pet"+sTarget+"_location");

    AssignCommand(oPet, ActionMoveToObject(GetNearestObject(OBJECT_TYPE_DOOR)));
    DestroyObject(oPet, 10.0);
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

    string sCDKey = GetHouseCDKey(sTag);

    if (sCDKey == "")
    {
        SetName(oDoor, "Vacant Home "+sCoordinates);
    }
    else
    {
        SetName(oDoor, "Home ("+GetHousePlayerName(sTag)+")");
        SpawnPets(sCDKey, oArea);
    }
}


void ClearHouseOwnership(object oDoor, object oPC);
void ClearHouseOwnership(object oDoor, object oPC)
{
    // delete the module cache for the home tag
    DeleteLocalString(GetModule(), GetPCPublicCDKey(oPC)+MODULE_HOME_TAG_SUFFIX);
    
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

// we only have a template for houses facing north, this inits houses in the other directions
// sType can be rich, norm, and slum
void CreateHouseTemplatesInCardinalDirections(string sType);
void CreateHouseTemplatesInCardinalDirections(string sType)
{
    object oEastHouse = CreateArea("_home"+sType, "_home"+sType+"_east", "z_Home"+sType+"East");
    NWNX_Area_RotateArea(oEastHouse, 1);
    //OrientPlaceables(oEastHouse);
    // you MUST set a delay when rotating areas, or the doors will be screwed up!
    DelayCommand(1.0, NWNX_Area_RotateArea(oEastHouse, 1));
    //DelayCommand(2.0, OrientPlaceables(oEastHouse));

    object oSouthHouse = CreateArea("_home"+sType, "_home"+sType+"_south", "z_Home"+sType+"South");
    NWNX_Area_RotateArea(oSouthHouse, 2);
    //OrientPlaceables(oSouthHouse);
    DelayCommand(1.0, NWNX_Area_RotateArea(oSouthHouse, 2));
    //DelayCommand(2.0, OrientPlaceables(oSouthHouse));

    object oWestHouse = CreateArea("_home"+sType, "_home"+sType+"_west", "z_Home"+sType+"West");
    NWNX_Area_RotateArea(oWestHouse, 3);
    //OrientPlaceables(oWestHouse);
    DelayCommand(1.0, NWNX_Area_RotateArea(oWestHouse, 3));
    //DelayCommand(2.0, OrientPlaceables(oWestHouse));
}

/*
void RotateTemplateHouse(string sType)
{
    NWNX_Area_RotateArea(GetObjectByTag("_home"+sType+"_east"), 1);
    NWNX_Area_RotateArea(GetObjectByTag("_home"+sType+"_south"), 1);
    NWNX_Area_RotateArea(GetObjectByTag("_home"+sType+"_west"), 1);
}

void RotateTemplateHouses()
{
    RotateTemplateHouse("rich");
    RotateTemplateHouse("norm");
    RotateTemplateHouse("slum");
}
*/

// creates houses in all cardinal directions, this is required and should be called when the module is loaded BEFORE houses are seeded
void CreateHouseTemplatesInAllCardinalDirections();
void CreateHouseTemplatesInAllCardinalDirections()
{
    CreateHouseTemplatesInCardinalDirections("rich");
    CreateHouseTemplatesInCardinalDirections("norm");
    CreateHouseTemplatesInCardinalDirections("slum");
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
    //SendDebugMessage(sTag+" orientation: "+FloatToString(fOrientation), TRUE);
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
    else if ((fOrientation > -5.0 && fOrientation < 5.0) || fOrientation == 360.0)
    {
        sFacing = "west";
    }
    else
    {
        SendDebugMessage("Invalid orientation for "+sTag+": "+FloatToString(fOrientation), TRUE);
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

    object oTemplateArea = GetObjectByTag("_home"+sDoorTag+"_"+sFacing);
    object oNewArea = CopyArea(oTemplateArea, sTag);
    SetLocalInt(oNewArea, "playerhouse", 1);

    //SendDebugMessage("_home"+sDoorTag+"_"+sFacing+" created: "+IntToString(GetIsObjectValid(oNewArea)), TRUE);
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

void InitializeHouses(string sArea)
{
    object oArea = GetObjectByTag(sArea);

    object oDoor = GetFirstObjectInArea(oArea);
    string sResRef, sCoordinates, sTag;
    vector vVector;

    string sList;

    while (GetIsObjectValid(oDoor))
    {
        sResRef = GetResRef(oDoor);

        if (GetObjectType(oDoor) == OBJECT_TYPE_DOOR && GetStringLeft(sResRef, 5) == "_home")
        {
            vVector = GetPosition(oDoor);
            sCoordinates = IntToString(FloatToInt(vVector.x))+IntToString(FloatToInt(vVector.y));
            // use the x and y coordinates to determine the unique location of a door
            // it's okay to convert it from a float to int as we don't need/want the decimals

            sTag = GetTag(oArea)+"_"+GetTag(oDoor)+sCoordinates;

            sList = AddListItem(sList, sTag, TRUE);

            SetTag(oDoor, sTag+"_exterior_door");

            SetLocalString(oDoor, "coordinates", sCoordinates);
            SetLocalString(oDoor, "area", sTag);

            InstanceHouseArea(sCoordinates, sTag, GetFacing(oDoor));
        }

        oDoor = GetNextObjectInArea(oArea);
    }

    SetCampaignString("housing", sArea, sList);
}

void CleanupPlaceable(object oObject);
void CleanupPlaceable(object oObject)
{
    SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_USED, "");
    SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_CLOSED, "");
    SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_DAMAGED, "");
    SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_DEATH, "");
    SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_DISARM, "");
    SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_HEARTBEAT, "");
    SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_LEFT_CLICK, "");
    SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_MELEEATTACKED, "");
    SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_SPELLCASTAT, "");
    SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_OPEN, "");
    SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_TRAPTRIGGERED, "");
    SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_DIALOGUE, "");

    SetPlotFlag(oObject, TRUE);
    NWNX_Object_SetPlaceableIsStatic(oObject, FALSE);
    NWNX_Object_SetHasInventory(oObject, FALSE);

    NWNX_Object_SetDialogResref(oObject, "");

    SetTag(oObject, "null_tag");
}

void BuyPlaceable(object oPlaceable, object oPC, int bCost = TRUE);
void BuyPlaceable(object oPlaceable, object oPC, int bCost = TRUE)
{
    int nCost = GetMaxHitPoints(oPlaceable); // we store the cost of the placeable in the max hit points field, don't ask

//  only allow the player to buy the placeable if they have enough gold
    if (bCost && GetGold(oPC) < nCost) return;

    /*
    string sResRef = "placeable_small";
    int nAppearance = GetAppearanceType(oPlaceable);

    string sSound = Get2DAString("placeables", "SoundAppType", nAppearance);

    // these placeables are categorized as having large sounds like generic_wood_large, we can consider these placeables to be large
    if (sSound == "13" || // crate_large
        sSound == "15" || // chest_large
        sSound == "16" || // drawer
        sSound == "17" || // generic_wood_small, combat dummy
        sSound == "18" || // generic_wood_large
        sSound == "20" || // generic_stone_large
        sSound == "22" || // generic_metal_large
        sSound == "32" || // stone_water
        sSound == "26") // stone_object_large
    {
        sResRef = "placeable_large";
    }
    */

    int nAppearance = GetAppearanceType(oPlaceable);
    string sResRef = "placeable";

    object oItem = CreateItemOnObject(sResRef, oPC);

    PlaySound("it_genericsmall");

    // if you are buying it for the first time, set a UUID for the database
    if (bCost)
    {
        SetLocalString(oItem, "uuid", GetRandomUUID());
        TakeGoldFromCreature(nCost, oPC, TRUE);
        IncrementPlayerStatistic(oPC, "gold_spent_from_buying", nCost);
    }
    else
    { // otherwise, assume you are retrieving a placeable and use the stored UUID
        SetLocalString(oItem, "uuid", GetLocalString(oPlaceable, "uuid"));
    }

    NWNX_Item_SetAddGoldPieceValue(oItem, nCost);

    string sName = GetName(oPlaceable);
    SetName(oItem, "Placeable: "+sName);

    SetLocalInt(oItem, "appearance_type", nAppearance);
    SetLocalString(oItem, "description", GetDescription(oPlaceable));
    SetLocalString(oItem, "name", sName);
}

void PlaceableMovingSound(object oPlaceable);
void PlaceableMovingSound(object oPlaceable)
{
    int nAppearance = GetAppearanceType(oPlaceable);

    string sSound = "cb_ht_fleshleth";

    int nSound = StringToInt(Get2DAString("placeables", "SoundAppType", nAppearance));

    string sSoundType = Get2DAString("placeableobjsnds", "ArmorType", nSound);

    if (sSoundType == "wood")
    {
        sSound = "cb_ht_fleshwood";
    }
    else if (sSoundType == "stone")
    {
        sSound = "cb_ht_fleshston";
    }
    else if (sSoundType == "plate")
    {
        sSound = "cb_ht_fleshplat";
    }

    //AssignCommand(oPlaceable, PlaySound(sSound+IntToString(d2())));
    PlaySound(sSound+IntToString(d2()));
}

void InitPlaceablesTable();
void InitPlaceablesTable()
{
    sqlquery sql = SqlPrepareQueryCampaign("house_placeables",
        "CREATE TABLE IF NOT EXISTS placeables (" +
        "uuid TEXT NOT NULL UNIQUE, " +
        "appearance_type INTEGER NOT NULL, " +
        "cd_key TEXT NOT NULL, " +
        "position TEXT NOT NULL, " +
        "facing INTEGER NOT NULL, " +
        "name TEXT, " +
        "description TEXT, " +
        "type INTEGER, " +
        "animation_state INTEGER " +
        ");");
    SqlStep(sql);
    SqlResetQuery(sql);
}

void BindPlaceableForSQL(object oPlaceable, vector vPosition, float fFacing, sqlquery sql)
{
    SqlBindInt(sql, "@appearance_type", GetAppearanceType(oPlaceable));
    SqlBindVector(sql, "@position", vPosition);
    SqlBindInt(sql, "@facing", FloatToInt(fFacing));
    SqlBindString(sql, "@name", GetName(oPlaceable));
    SqlBindString(sql, "@description", GetDescription(oPlaceable));
}

void UpdatePlaceable(object oPlaceable, object oPC, vector vPosition, float fFacing, string sUUID)
{
    /* REEEEEEEEEEEE THIS DOESNT WORK
    sqlquery sql = SqlPrepareQueryCampaign("house_placeables",
        "UPDATE placeables " +
        "SET appearance_type = @appearance_type, position = @position, facing = @facing, name = @name, description = @description " +
        "WHERE uuid = @uuid;");
    */
    sqlquery delete_sql = SqlPrepareQueryCampaign("house_placeables", "DELETE FROM placeables WHERE uuid = @uuid");
    SqlBindString(delete_sql, "@uuid", sUUID);
    SqlStep(delete_sql);

    sqlquery sql = SqlPrepareQueryCampaign("house_placeables",
    "INSERT INTO placeables " +
    "(uuid, appearance_type, cd_key, position, facing, name, description, type) " +
    "VALUES (@uuid, @appearance_type, @cd_key, @position, @facing, @name, @description, @type);" +
    "DELETE FROM placeables WHERE uuid = @uuid");
    BindPlaceableForSQL(oPlaceable, vPosition, fFacing, sql);
    SqlBindString(sql, "@cd_key", GetPCPublicCDKey(oPC)); 
    SqlBindString(sql, "@uuid", sUUID);
    SqlStep(sql);
}

object CopyPlaceable(string sName, string sDescription, string sType, location lLocation, int nAppearanceType, string sUUID);
object CopyPlaceable(string sName, string sDescription, string sType, location lLocation, int nAppearanceType, string sUUID)
{
    object oPlaceableToCopy = GetObjectByTag("_Placeable"+IntToString(nAppearanceType));

    object oPlaceable = CopyObject(oPlaceableToCopy, lLocation, OBJECT_INVALID, "_HomePlaceable");

    if (!GetIsObjectValid(oPlaceable)) return OBJECT_INVALID;

    CleanupPlaceable(oPlaceable);

    SetTag(oPlaceable, "_HomePlaceable");
    SetUseableFlag(oPlaceable, FALSE);

    SetLocalInt(oPlaceable, "appearance_type", nAppearanceType);
    SetLocalString(oPlaceable, "description", sDescription);
    SetLocalString(oPlaceable, "name", sName);
    SetLocalString(oPlaceable, "type", sType);
    SetLocalString(oPlaceable, "uuid", sUUID);

    AssignCommand(oPlaceable, ActionPlayAnimation(ANIMATION_PLACEABLE_CLOSE));
    AssignCommand(oPlaceable, ActionPlayAnimation(ANIMATION_PLACEABLE_ACTIVATE));

    PlaceableMovingSound(oPlaceable);

    SetName(oPlaceable, sName);
    SetDescription(oPlaceable, sDescription);

    return oPlaceable;
}

void RemovePlaceable(object oPC, object oPlaceable);
void RemovePlaceable(object oPC, object oPlaceable)
{
    BuyPlaceable(oPlaceable, oPC, FALSE);

    sqlquery sql = SqlPrepareQueryCampaign("house_placeables", "DELETE FROM placeables WHERE uuid = @uuid");
    SqlBindString(sql, "@uuid", GetLocalString(oPlaceable, "uuid"));
    SqlStep(sql);

    DestroyObject(oPlaceable);
}

void LoadAllHousePlaceables()
{
    sqlquery sql = SqlPrepareQueryCampaign("house_placeables", "SELECT " +
    "uuid, appearance_type, cd_key, position, facing, name, description, type FROM placeables;");
    while (SqlStep(sql))
    {
        string sUUID = SqlGetString(sql, 0);
        int nAppearanceType = SqlGetInt(sql, 1);
        string sAreaTag = GetHomeTagByCDKey(SqlGetString(sql, 2));
        vector vPosition = SqlGetVector(sql, 3);
        float fFacing = IntToFloat(SqlGetInt(sql, 4));
        string sName = SqlGetString(sql, 5);
        string sDescription = SqlGetString(sql, 6);

        object oArea = GetObjectByTag(sAreaTag);

        location lLoc = Location(oArea, vPosition, fFacing);

        CopyPlaceable(sName, sDescription, "", lLoc, nAppearanceType, sUUID);
    }
}


int IsInOwnHome(object oPC);
int IsInOwnHome(object oPC)
{
    return GetHomeTag(oPC) == GetTag(GetArea(oPC));
}

void InitializeAllHouses()
{
    InitializeHouses("begg");
    InitializeHouses("dock");
    InitializeHouses("blak");
    InitializeHouses("core");

    LoadAllHousePlaceables();

    SetLocalInt(GetModule(), "houses_initialized", TRUE);
}
