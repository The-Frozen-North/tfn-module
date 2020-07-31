#include "inc_respawn"

void CreateObjectRandom(int nObjectType, string sTemplate, location lLocation, int iRandom)
{
    object oNewObject = CreateObject(nObjectType, sTemplate, lLocation);
    SetLocalInt(oNewObject, "random_spawn", iRandom);
}

void main()
{
     int iRandom = GetLocalInt(OBJECT_SELF, "random_spawn");
     if (iRandom == 0) return;

     string sRef = SpawnRef(OBJECT_SELF, GetArea(OBJECT_SELF), iRandom);
     location lLocation = GetLocation(OBJECT_SELF);
     int nObjectType = GetObjectType(OBJECT_SELF);

     DestroyObject(OBJECT_SELF);
     AssignCommand(GetModule(), DelayCommand(3.0, CreateObjectRandom(nObjectType, sRef, lLocation, iRandom)));
}
