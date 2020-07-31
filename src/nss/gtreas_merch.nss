#include "inc_debug"

void main()
{
    object oStore;
    location lLocation = Location(GetObjectByTag("_BASE"), Vector(1.0, 1.0, 1.0), 0.0);

    int i;
    for (i = 1; i < 25; i++)
    {
        oStore = CreateObject(OBJECT_TYPE_STORE, "merchant"+IntToString(i), lLocation);

        ExecuteScript(""+GetTag(oStore), oStore);
    }
    SetLocalInt(GetModule(), "treasure_ready", 1);
    SendDebugMessage("Merchants finished", TRUE);
}
