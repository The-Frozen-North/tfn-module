#include "inc_debug"
#include "nwnx_object"

void SetSpawn(string sResRef, object oTable, string sTargetSpawn, int nTarget, vector vObject)
{
    object oTrigger;

    float fMaxHeight;

// loop through elevation 0, 1, and 2
    int i;
    for (i = 0; i < 3; i++)
    {
        oTrigger = GetObjectByTag(sResRef+"e"+IntToString(i)+"_random"+IntToString(nTarget)+"_spawn");

        fMaxHeight = 3.5;

        switch (GetLocalInt(oTrigger, "elevation"))
        {
            case 1: fMaxHeight = 7.0; break;
            case 2: fMaxHeight = 10.5; break;
        }

        if (GetIsObjectValid(oTrigger) && NWNX_Object_GetPositionIsInTrigger(oTrigger, vObject) && (vObject.z <= fMaxHeight))
        {
              int nSpawns = GetLocalInt(oTable, "random"+IntToString(nTarget)+"_spawn_point_total");
              SetLocalInt(oTable, "random"+IntToString(nTarget)+"_spawn_point_total", nSpawns+1);
              SetLocalString(oTable, "random"+IntToString(nTarget)+"_spawn_point"+IntToString(nSpawns+1), sTargetSpawn);

              //SendDebugMessage(sResRef+" random"+IntToString(nTarget)+"_spawn_point_total: "+IntToString(nSpawns+1), TRUE);
              //SendDebugMessage(sResRef+" random"+IntToString(nTarget)+"_spawn_point"+IntToString(nSpawns+1)+": "+sTargetSpawn, TRUE);
              break;
        }
    }
}

void main()
{
    object oArea = GetArea(OBJECT_SELF);
    string sTargetSpawn = GetLocalString(OBJECT_SELF, "target_spawn");

    if (sTargetSpawn != "")
    {
        string sResRef = GetResRef(oArea);
        object oTable = GetObjectByTag(sResRef+"+_spawn_table");
        vector vObject = GetPosition(OBJECT_SELF);

        SetSpawn(sResRef, oTable, sTargetSpawn, 1, vObject);
        SetSpawn(sResRef, oTable, sTargetSpawn, 2, vObject);
        SetSpawn(sResRef, oTable, sTargetSpawn, 3, vObject);
        SetSpawn(sResRef, oTable, sTargetSpawn, 4, vObject);
        SetSpawn(sResRef, oTable, sTargetSpawn, 5, vObject);
        SetSpawn(sResRef, oTable, sTargetSpawn, 6, vObject);
        SetSpawn(sResRef, oTable, sTargetSpawn, 7, vObject);
        SetSpawn(sResRef, oTable, sTargetSpawn, 8, vObject);
        SetSpawn(sResRef, oTable, sTargetSpawn, 9, vObject);
    }

    DestroyObject(OBJECT_SELF);
}

