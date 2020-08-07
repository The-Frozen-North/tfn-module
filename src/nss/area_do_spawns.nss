#include "inc_trap"
#include "inc_loot"
#include "inc_debug"
#include "nwnx_object"

string ChooseSpawnRef(object oArea, int nTarget)
{
    string sTarget = "random"+IntToString(nTarget)+"_spawn";

    int nRandom = GetLocalInt(oArea, sTarget+"_total");

// choose a random a random spawn
    return GetLocalString(oArea, sTarget+IntToString(Random(nRandom)+1));
}

void CreateSpawns(object oTable, object oArea, int nTarget, int nSpawnPoints)
{
      string sResRef = GetResRef(oArea);

      int nTotalSpawns = (nSpawnPoints/5) + (Random(nSpawnPoints/8));

      float fDensityMod = GetLocalFloat(oArea, "creature_density_mod");
      if (fDensityMod > 0.0) nTotalSpawns = FloatToInt(IntToFloat(nTotalSpawns)*fDensityMod);

      float fTargetDensityMod = GetLocalFloat(oArea, "random"+IntToString(nTarget)+"_density_mod");
      if (fTargetDensityMod > 0.0) nTotalSpawns = FloatToInt(IntToFloat(nTotalSpawns)*fTargetDensityMod);

      location lSpawnLocation;
      int nSpawn;
      string sSpawnPoint;
      float fSpawnX, fSpawnY, fSpawnZ;

      for (nSpawn = 1; nSpawn <= nTotalSpawns; nSpawn++)
      {
           sSpawnPoint = GetLocalString(oTable, "random"+IntToString(nTarget)+"_spawn_point"+IntToString(Random(nSpawnPoints)+1));

           fSpawnX = GetLocalFloat(oTable, sSpawnPoint+"x");
           fSpawnY = GetLocalFloat(oTable, sSpawnPoint+"y");
           fSpawnZ = GetLocalFloat(oTable, sSpawnPoint+"z");

           CreateObject(OBJECT_TYPE_CREATURE, ChooseSpawnRef(oArea, nTarget), Location(oArea, Vector(fSpawnX, fSpawnY, fSpawnZ), IntToFloat(Random(360)+1)));
      }
}

void main()
{
     object oArea = OBJECT_SELF;

// never do this if the spawns are already done
     if (GetLocalInt(oArea, "spawned") == 1) return;

     SetLocalInt(oArea, "spawned", 1);

     string sResRef = GetResRef(oArea);

     object oTable = GetObjectByTag(sResRef+"+_spawn_table");

// never do this if the spawn table isn't created
     if (!GetIsObjectValid(oTable)) return;

     int iCR = GetLocalInt(oArea, "cr");

     int iRows = GetAreaSize(AREA_WIDTH, oArea);
     int iColumns = GetAreaSize(AREA_HEIGHT, oArea);

     if (GetLocalInt(oArea, "trapped") == 1)
     {
        int nTrapChance = (iRows*iColumns)/12;

        location lTrapLocation;
        float fTrapX, fTrapY, fTrapZ;
        object oTrap;

        int nTrapSpawns = GetLocalInt(oTable, "trap_spawns");

// cap the density of traps
        if (nTrapChance >= 30) nTrapChance = 30;

        int i;
        for (i = 1; i <= nTrapSpawns; i++)
        {
            if (d100() <= nTrapChance)
            {
                fTrapX = GetLocalFloat(oTable, "spawn"+IntToString(i)+"x");
                fTrapY = GetLocalFloat(oTable, "spawn"+IntToString(i)+"y");
                fTrapZ = GetLocalFloat(oTable, "spawn"+IntToString(i)+"z");

                lTrapLocation = Location(oArea, Vector(fTrapX, fTrapY, fTrapZ), 0.0);

                oTrap = CreateTrapAtLocation(DetermineTrap(iCR), lTrapLocation, 2.5+(IntToFloat(Random(10)+1)/10.0));
                TrapLogic(oTrap);
            }
        }
     }

     int i;

     int nRandomSpawnTotal;
     for (i = 0; i < 10; i++)
     {
        int nRandomSpawnTotal = GetLocalInt(oArea, "random"+IntToString(i)+"_spawn_total");
        if (nRandomSpawnTotal == 0) continue;

        int nRandomSpawnPointTotal = GetLocalInt(oTable, "random"+IntToString(i)+"_spawn_point_total");
        if (nRandomSpawnPointTotal == 0) continue;

        SendDebugMessage(sResRef+" random"+IntToString(i)+"_spawn_point_total: "+IntToString(nRandomSpawnPointTotal), TRUE);

        CreateSpawns(oTable, oArea, i, nRandomSpawnPointTotal);
     }
}

