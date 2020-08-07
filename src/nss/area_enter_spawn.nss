#include "inc_debug"
#include "inc_horse"

void main()
{
       object oPC = GetEnteringObject();

// only trigger this for PCs
       if (!GetIsPC(oPC)) return;

       ExecuteScript("area_enter", OBJECT_SELF);
       ExecuteScript("area_do_spawns", OBJECT_SELF);
       SetEventScript(OBJECT_SELF, EVENT_SCRIPT_AREA_ON_ENTER, "area_enter");
}

