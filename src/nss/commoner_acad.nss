#include "inc_commoner"

void main()
{
    struct CommonerSettings sSettings;

    sSettings.NumberOfCommonersDuringDay = 2;
    sSettings.NumberOfCommonersDuringNight = 2;
    sSettings.NumberOfCommonersDuringRain = 2;
    sSettings.CommonerResRef = "student";
    sSettings.CommonerTag = "AMBIENT_STUDENT";
    sSettings.WaypointTag = "WP_STUDENT";
    SpawnAndUpdateCommoners(sSettings);

    // The SpawnAndUpdateCommoners function can be called multiple times with
    // different settings. Just make sure the CommonerTag is set to something
    // different (otherwise the script will get confused).
    sSettings.NumberOfCommonersDuringDay = 1;
    sSettings.NumberOfCommonersDuringNight = 1;
    sSettings.NumberOfCommonersDuringRain = 1;
    sSettings.CommonerResRef = "militia";
    sSettings.CommonerTag = "AMBIENT_MILITIA";
    sSettings.WaypointTag = "WP_MILITIA";
    sSettings.MinSpawnDelay = MILITIA_MIN_SPAWN_DELAY;
    sSettings.MaxSpawnDelay = MILITIA_MAX_SPAWN_DELAY;
    SpawnAndUpdateCommoners(sSettings);
}
