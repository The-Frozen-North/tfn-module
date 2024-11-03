#include "inc_general"

void CleanAndSpawnPetrified(string sCreature)
{
    string sResRef;
    int nNumSpawns = GetLocalInt(OBJECT_SELF, "num_petrified_creatures_per_type");
    if (nNumSpawns == 0) { nNumSpawns = 1; }

    if (sCreature == "DireWolf") { sResRef = "wolf_dire"; }
    else if (sCreature == "Bear") { sResRef = "bear_black"; }
    else if (sCreature == "Deer") { sResRef = "deer"; }
    else if (sCreature == "Smuggler") { sResRef = "smuggler_archer"; }
    else if (sCreature == "Badger") { sResRef = "badger"; }

    string sVar = "PetrifiedCreature_" + sCreature;
    int nCount = GetLocalInt(OBJECT_SELF, sVar + "_count");
    int i;
    for (i=0; i<nCount; i++)
    {
        object oPetrified = GetLocalObject(OBJECT_SELF, sVar + IntToString(i));
        if (GetIsObjectValid(oPetrified))
        {
            DestroyObject(oPetrified);
        }
        DeleteLocalObject(OBJECT_SELF, sVar + IntToString(i));
    }
    DeleteLocalInt(OBJECT_SELF, sVar + "_count");

    int nNumSpawnPoints = GetLocalInt(OBJECT_SELF, "petrified_Petrified" + sCreature);
    if (nNumSpawnPoints > 0)
    {
        int nChance = (1000*nNumSpawns)/nNumSpawnPoints;
        int nNumberSpawned = 0;
        for (i=0; i<nNumSpawnPoints; i++)
        {
            if (Random(1000) < nChance)
            {
                SetLocalInt(OBJECT_SELF, sVar + "_count", GetLocalInt(OBJECT_SELF, sVar + "_count") + 1);
                location lLoc = GetLocalLocation(OBJECT_SELF, "petrified_Petrified" + sCreature + IntToString(i));
                object oNew = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lLoc);
                SetLocalObject(OBJECT_SELF, "PetrifiedCreature_" + sCreature + IntToString(nNumberSpawned), oNew);
                nNumberSpawned++;
                SetDecorativePetrification(oNew);
            }
        }
    }
}

void main()
{
    CleanAndSpawnPetrified("DireWolf");
    CleanAndSpawnPetrified("Bear");
    CleanAndSpawnPetrified("Deer");
    CleanAndSpawnPetrified("Smuggler");
    CleanAndSpawnPetrified("Badger");
}
