#include "inc_commoner"

void main()
{
    struct CommonerSettings sSettings;
    sSettings.NumberOfCommonersDuringDay = 3;
    sSettings.NumberOfCommonersDuringNight = 2;
    sSettings.NumberOfCommonersDuringRain = 1;
    sSettings.CommonerResRef = "villager";
    sSettings.CommonerTag = "AMBIENT_VILLAGER";
    sSettings.WaypointTag = "WP_VILLAGER";
    sSettings.MinSpawnDelay = COMMONER_MIN_SPAWN_DELAY;
    sSettings.MaxSpawnDelay = COMMONER_MAX_SPAWN_DELAY;
    SpawnAndUpdateCommoners(sSettings);

    sSettings.NumberOfCommonersDuringDay = 1;
    sSettings.NumberOfCommonersDuringNight = 1;
    sSettings.NumberOfCommonersDuringRain = 1;
    sSettings.CommonerResRef = "sailor";
    sSettings.CommonerTag = "AMBIENT_SAILOR";
    sSettings.WaypointTag = "WP_SAILOR";
    sSettings.MinSpawnDelay = COMMONER_MIN_SPAWN_DELAY;
    sSettings.MaxSpawnDelay = COMMONER_MAX_SPAWN_DELAY;
    SpawnAndUpdateCommoners(sSettings);


    sSettings.NumberOfCommonersDuringDay = 2;
    sSettings.NumberOfCommonersDuringNight = 1;
    sSettings.NumberOfCommonersDuringRain = 1;
    sSettings.CommonerResRef = "guard";
    sSettings.CommonerTag = "AMBIENT_GUARD";
    sSettings.WaypointTag = "WP_GUARD";
    sSettings.MinSpawnDelay = GUARD_MIN_SPAWN_DELAY;
    sSettings.MaxSpawnDelay = GUARD_MAX_SPAWN_DELAY;
    SpawnAndUpdateCommoners(sSettings);
}
