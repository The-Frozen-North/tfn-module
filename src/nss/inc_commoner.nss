//::///////////////////////////////////////////////
//:: inc_commoner
//:: inc_commoner.nss
//:: Copyright (c) 2018 Rarosu
//:://////////////////////////////////////////////
/*

    Ambient Commoners Script Library

    This script library allows you to spawn NPCs that walk from a source
    location to a target location. The script only requires some settings
    and to be called in the heartbeat script of the areas you want it working
    in. When set up, NPCs will spawn and despawn automatically.

    For simple use, see example below. For more advanced use, see example
    module that is distributed with this script library.

    Example of usage:

    // Heartbeat script of area.
    #include "inc_commoner"

    void main()
    {
        struct CommonerSettings settings;
        settings.NumberOfCommonersDuringDay = 5;
        settings.NumberOfCommonersDuringNight = 1;
        settings.NumberOfCommonersDuringRain = 1;
        settings.CommonerResRefPrefix = "mycommoner";
        settings.NumberOfCommonerTemplates = 4;
        settings.RandomizeClothing = TRUE;
        settings.ClothingResRefPrefix = "myclothing";
        settings.NumberOfClothingTemplates = 3;
        settings.CommonerTag = "Commoner";
        settings.CommonerName = "City Dweller";
        settings.WaypointTag = "WP_COMMONER";
        settings.MinSpawnDelay = 2.0f;
        settings.MaxSpawnDelay = 30.0f;
        settings.StationaryCommoners = FALSE;
        settings.MaxWalkTime = 30.0f;

        SpawnAndUpdateCommoners(settings);
    }



    == CHANGELOG ==

    2018-07-14:
        + Added MaxWalkTime to allow commoners to walk longer distances.
        + Fixed issue with too many commoners spawning during nighttime.

    2018-03-24:
        + Added stationary commoners.

    2018-03-03:
        + Initial release.
*/
//:://////////////////////////////////////////////
//:: Created By: Rarosu
//:: Created On: 2018
//:://////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Structures
////////////////////////////////////////////////////////////////////////////////

// Use this struct to customize the behavior of the spawning commoners.
// To use, in your heartbeat script, do this:
//
//     struct CommonerSettings settings;
//     settings.NumberOfCommonersDuringDay = 4;
//     settings.CommonerResRefPrefix = "mycommoner";
//     // etc. set whatever values you want to change, otherwise reasonable defaults will be used.
//
//     // To then use those settings:
//     SpawnAndUpdateCommoners(settings);
//
//
struct CommonerSettings
{
    // The maximum number of commoners to spawn during daytime.
    int NumberOfCommonersDuringDay;

    // The maximum number of commoners to spawn during nighttime.
    int NumberOfCommonersDuringNight;

    // The maximum number of commoners to spawn during rain and snow.
    // This will not spawn more than NumberOfCommonersDuringDay or
    // NumberOfCommonersDuringNight.
    int NumberOfCommonersDuringRain;

    // The tag to assign to the commoners that are spawned (the tag in the template is ignored).
    // If you call SpawnAndUpdateCommoners multiple times for an area with different settings,
    // make sure you use different tags.
    string CommonerTag;

    // The base ResRef of the commoners to spawn, e.g. "commoner" will spawn
    // creatures with ResRef "commoner001", "commoner002", etc.
    string CommonerResRef;

    // The tag used to identify the waypoints the commoners will be spawning at and moving
    // between.
    string WaypointTag;

    // The minimum delay to wait after the heartbeat event notices a commoner missing
    // until it spawns a new one.
    float MinSpawnDelay;

    // The maximum delay to wait after the heartbeat event notices a commoner missing
    // until it spawns a new one.
    float MaxSpawnDelay;

    // Set to TRUE to make the spawned commoners should stay where they spawn.
    // If FALSE, they will move to another waypoint in the area and disappear.
    int StationaryCommoners;

    // If spawned commoners are not stationary (i.e. they are walking to a destination)
    // this is the maximum time they will be walking before teleporting to their destination.
    // To avoid the commoners getting stuck forever. Default 30.0 seconds.
    float MaxWalkTime;
};

////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////

// The ResRef prefix to use if the CommonerResRefPrefix is empty in the settings.
const string COMMONER_DEFAULT_RESREF = "commoner";

// The tag to set on spawned commoners if CommonerTag is empty in the settings.
const string COMMONER_DEFAULT_TAG = "Commoner";

// If WaypointTag is not set in the settings, the script will look for waypoints
// with this tag to spawn commoners at and move them between.
const string COMMONER_DEFAULT_WAYPOINT_TAG = "WP_COMMONER";

// The default delay to use between spawning commoners if the values in the settings
// are invalid. The values are considered invalid if both of them are zero or the max
// delay is less than the min delay.
const float COMMONER_DEFAULT_MIN_SPAWN_DELAY = 15.0;
const float COMMONER_DEFAULT_MAX_SPAWN_DELAY = 60.0;

const float COMMONER_MIN_SPAWN_DELAY = 20.0;
const float COMMONER_MAX_SPAWN_DELAY = 60.0;

const float MILITIA_MIN_SPAWN_DELAY = 15.0;
const float MILITIA_MAX_SPAWN_DELAY = 80.0;

const float GUARD_MIN_SPAWN_DELAY = 15.0;
const float GUARD_MAX_SPAWN_DELAY = 60.0;

////////////////////////////////////////////////////////////////////////////////
// Function definitions
////////////////////////////////////////////////////////////////////////////////

// Call this in the OnHeartbeat script of your area. This will keep the area
// populated with commoners if there are players inside of it and clean up
// the area otherwise.
void SpawnAndUpdateCommoners(struct CommonerSettings sSettings, object oArea = OBJECT_SELF);

// Call this whenever your commoners are interrupted and you want them to resume
// what they were doing. For instance, call this after a conversation with the
// commoners have concluded.
void ResumeCommonerBehavior(object oCommoner = OBJECT_SELF);

////////////////////////////////////////////////////////////////////////////////
// Function implementations
////////////////////////////////////////////////////////////////////////////////

void Debug(string s)
{
    SendMessageToPC(GetFirstPC(), s);
    WriteTimestampedLogEntry(s);
}

int Min(int a, int b)
{
    return a < b ? a : b;
}

float GetRandomFloat(float min, float max)
{
    float precision = 10.0f;
    int iMin = FloatToInt(min * precision);
    int iMax = FloatToInt(max * precision);
    int iRandom = Random(iMax - iMin) + iMin;

    return IntToFloat(iRandom) / precision;
}

int GetNumberOfCommonersWaitingToSpawn(object oArea, string sCommonerTag)
{
    return GetLocalInt(oArea, "CommonersWaitingToSpawn_" + sCommonerTag);
}

void SetNumberOfCommonersWaitingToSpawn(object oArea, string sCommonerTag, int value)
{
    if (value < 0)
        value = 0;
    SetLocalInt(oArea, "CommonersWaitingToSpawn_" + sCommonerTag, value);
}

int GetNumberOfObjectsInAreaByTag(object oObjectInArea, string sTag)
{
    int nNth = 1;
    object oObj = GetNearestObjectByTag(sTag, oObjectInArea, nNth);
    while (oObj != OBJECT_INVALID)
    {
        nNth++;
        oObj = GetNearestObjectByTag(sTag, oObjectInArea, nNth);
    }

    return nNth - 1;
}

int GetMaxNumberOfCommoners(object oArea, struct CommonerSettings sSettings)
{
    int nMax = sSettings.NumberOfCommonersDuringDay;

    if (GetIsNight())
    {
        nMax = sSettings.NumberOfCommonersDuringNight;
    }

    int iWeather = GetWeather(oArea);
    if (iWeather == WEATHER_RAIN || iWeather == WEATHER_SNOW)
    {
        nMax = Min(nMax, sSettings.NumberOfCommonersDuringRain);
    }

    return nMax;
}

void MakeCommonerWalk(object oCommoner, object oOriginWP, int nNumberOfWaypoints, struct CommonerSettings sSettings)
{
    object oTargetWP = GetNearestObjectByTag(sSettings.WaypointTag, oOriginWP, Random(nNumberOfWaypoints - 1) + 1);
    if (oTargetWP == OBJECT_INVALID || oTargetWP == oOriginWP)
    {
        return;
    }

    SetLocalObject(oCommoner, "CommonerTargetWaypoint", oTargetWP);
    AssignCommand(oCommoner, ActionForceMoveToObject(oTargetWP, FALSE, 1.0f, sSettings.MaxWalkTime));
    AssignCommand(oCommoner, ActionDoCommand(DestroyObject(oCommoner)));
}

void SpawnCommoner(object oArea, struct CommonerSettings sSettings)
{
    object oObjectInArea = GetFirstObjectInArea(oArea);

    // Check if a commoner should spawn, and if so, update the number of commoners waiting to spawn.
    int nNumberOfCommonersWaitingToSpawn = GetNumberOfCommonersWaitingToSpawn(oArea, sSettings.CommonerTag);
    SetNumberOfCommonersWaitingToSpawn(oArea, sSettings.CommonerTag, nNumberOfCommonersWaitingToSpawn - 1);

    // Find out where to spawn the commoner.
    int nNumberOfWaypoints = GetNumberOfObjectsInAreaByTag(oObjectInArea, sSettings.WaypointTag);
    object oOriginWP = GetNearestObjectByTag(sSettings.WaypointTag, oObjectInArea, Random(nNumberOfWaypoints) + 1);

    if (oOriginWP == OBJECT_INVALID)
    {
        return;
    }

    string sResRef = sSettings.CommonerResRef;
    object oCommoner = CreateObject(OBJECT_TYPE_CREATURE, sResRef, GetLocation(oOriginWP), FALSE, sSettings.CommonerTag);

    SetEventScript(oCommoner, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "ai_on_conversec");
    DeleteLocalInt(oCommoner, "respawn");
    SetLocalString(oCommoner, "heartbeat_script", "ai_commoner");
    SetLocalInt(oCommoner, "ambient", 1);

    if (!sSettings.StationaryCommoners)
    {
        // Optionally make the commoner walk to a destination.
        MakeCommonerWalk(oCommoner, oOriginWP, nNumberOfWaypoints, sSettings);
    }
}

void DelayAndSpawnCommoner(object oArea, struct CommonerSettings sSettings)
{
    float fDelay = GetRandomFloat(sSettings.MinSpawnDelay, sSettings.MaxSpawnDelay);
    DelayCommand(fDelay, SpawnCommoner(oArea, sSettings));
}

struct CommonerSettings SanitizeSettings(struct CommonerSettings sSettings)
{
    if (sSettings.CommonerTag == "")
        sSettings.CommonerTag = COMMONER_DEFAULT_TAG;
    if (sSettings.WaypointTag == "")
        sSettings.WaypointTag = COMMONER_DEFAULT_WAYPOINT_TAG;

    float fEpsilon = 0.0001f;
    if (sSettings.MinSpawnDelay <= fEpsilon && sSettings.MaxSpawnDelay <= fEpsilon ||
        sSettings.MaxSpawnDelay < sSettings.MinSpawnDelay)
    {
        sSettings.MinSpawnDelay = COMMONER_DEFAULT_MIN_SPAWN_DELAY;
        sSettings.MaxSpawnDelay = COMMONER_DEFAULT_MAX_SPAWN_DELAY;
    }

// if they don't get there in this time frame, something is seriously wrong so destroy them
    if (sSettings.MaxWalkTime < 300.0)
        sSettings.MaxWalkTime = 300.0;

    // Have at least one commoner during day if all max values are set to 0.
    if (sSettings.NumberOfCommonersDuringDay == 0 &&
        sSettings.NumberOfCommonersDuringNight == 0 &&
        sSettings.NumberOfCommonersDuringRain == 0)
    {
        sSettings.NumberOfCommonersDuringDay = 1;
    }

    return sSettings;
}

void SpawnAndUpdateCommoners(struct CommonerSettings sSettings, object oArea = OBJECT_SELF)
{
    sSettings = SanitizeSettings(sSettings);

    object oObjectInArea = GetFirstObjectInArea(oArea);

    int nMaxNumberOfCommoners = GetMaxNumberOfCommoners(oArea, sSettings);
    int nNumberOfCommoners = GetNumberOfObjectsInAreaByTag(oObjectInArea, sSettings.CommonerTag);
    int nNumberOfCommonersWaitingToSpawn = GetNumberOfCommonersWaitingToSpawn(oArea, sSettings.CommonerTag);

    while (nNumberOfCommoners + nNumberOfCommonersWaitingToSpawn < nMaxNumberOfCommoners)
    {
        DelayAndSpawnCommoner(oArea, sSettings);

        nNumberOfCommonersWaitingToSpawn++;
        SetNumberOfCommonersWaitingToSpawn(oArea, sSettings.CommonerTag, nNumberOfCommonersWaitingToSpawn);
    }
}

void ResumeCommonerBehavior(object oCommoner = OBJECT_SELF)
{
    object oDestination = GetLocalObject(oCommoner, "CommonerTargetWaypoint");
    if (oDestination == OBJECT_INVALID)
    {
        return;
    }

    AssignCommand(oCommoner, ActionForceMoveToObject(oDestination));
    AssignCommand(oCommoner, ActionDoCommand(DestroyObject(oCommoner)));
}

////////////////////////////////////////////////////////////////////////////////
// For compilation
////////////////////////////////////////////////////////////////////////////////
//void main() {}


