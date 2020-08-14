#include "inc_commoner"

void main()
{
    struct CommonerSettings sSettings;
    sSettings.NumberOfCommonersDuringDay = 3;
    sSettings.NumberOfCommonersDuringNight = 2;
    sSettings.NumberOfCommonersDuringRain = 1;
    sSettings.CommonerResRef = "commoner";
    sSettings.CommonerTag = "AMBIENT_COMMONER";
    sSettings.WaypointTag = "WP_COMMONER";
    sSettings.MinSpawnDelay = COMMONER_MIN_SPAWN_DELAY;
    sSettings.MaxSpawnDelay = COMMONER_MAX_SPAWN_DELAY;
    SpawnAndUpdateCommoners(sSettings);


    sSettings.NumberOfCommonersDuringDay = 2;
    sSettings.NumberOfCommonersDuringNight = 1;
    sSettings.NumberOfCommonersDuringRain = 1;
    sSettings.CommonerResRef = "nwguard";
    sSettings.CommonerTag = "AMBIENT_NWGUARD";
    sSettings.WaypointTag = "WP_NWGUARD";
    sSettings.MinSpawnDelay = GUARD_MIN_SPAWN_DELAY;
    sSettings.MaxSpawnDelay = GUARD_MAX_SPAWN_DELAY;
    SpawnAndUpdateCommoners(sSettings);

    // The SpawnAndUpdateCommoners function can be called multiple times with
    // different settings. Just make sure the CommonerTag is set to something
    // different (otherwise the script will get confused).
    sSettings.NumberOfCommonersDuringDay = 3;
    sSettings.NumberOfCommonersDuringNight = 2;
    sSettings.NumberOfCommonersDuringRain = 1;
    sSettings.CommonerResRef = "militia";
    sSettings.CommonerTag = "AMBIENT_MILITIA";
    sSettings.WaypointTag = "WP_MILITIA";
    sSettings.MinSpawnDelay = MILITIA_MIN_SPAWN_DELAY;
    sSettings.MaxSpawnDelay = MILITIA_MAX_SPAWN_DELAY;
    SpawnAndUpdateCommoners(sSettings);
}
