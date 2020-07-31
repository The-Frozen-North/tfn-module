#include "inc_commoner"

void main()
{
    struct CommonerSettings sSettings;
    sSettings.NumberOfCommonersDuringDay = 5;
    sSettings.NumberOfCommonersDuringNight = 3;
    sSettings.NumberOfCommonersDuringRain = 2;
    sSettings.CommonerResRef = "peasant";
    sSettings.CommonerTag = "AMBIENT_PEASANT";
    sSettings.WaypointTag = "WP_PEASANT";
    sSettings.MinSpawnDelay = COMMONER_MIN_SPAWN_DELAY;
    sSettings.MaxSpawnDelay = COMMONER_MAX_SPAWN_DELAY;
    SpawnAndUpdateCommoners(sSettings);


    sSettings.NumberOfCommonersDuringDay = 3;
    sSettings.NumberOfCommonersDuringNight = 3;
    sSettings.NumberOfCommonersDuringRain = 3;
    sSettings.CommonerResRef = "nwguard";
    sSettings.CommonerTag = "AMBIENT_NWGUARD";
    sSettings.WaypointTag = "WP_NWGUARD";
    sSettings.MinSpawnDelay = GUARD_MIN_SPAWN_DELAY;
    sSettings.MaxSpawnDelay = GUARD_MAX_SPAWN_DELAY;
    SpawnAndUpdateCommoners(sSettings);

    // The SpawnAndUpdateCommoners function can be called multiple times with
    // different settings. Just make sure the CommonerTag is set to something
    // different (otherwise the script will get confused).
    sSettings.NumberOfCommonersDuringDay = 2;
    sSettings.NumberOfCommonersDuringNight = 1;
    sSettings.NumberOfCommonersDuringRain = 1;
    sSettings.CommonerResRef = "nwknight";
    sSettings.CommonerTag = "AMBIENT_NWKNIGHT";
    sSettings.WaypointTag = "WP_NWKNIGHT";
    sSettings.MinSpawnDelay = MILITIA_MIN_SPAWN_DELAY;
    sSettings.MaxSpawnDelay = MILITIA_MAX_SPAWN_DELAY;
    SpawnAndUpdateCommoners(sSettings);
}
