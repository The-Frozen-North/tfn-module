#include "nwnx_events"
#include "nwnx_object"

void main()
{
    object oTrap = NWNX_Object_StringToObject(NWNX_Events_GetEventData("TRAP_OBJECT_ID"));


// skip the trap enter event if it has a local int and the object entering isnt a PC, AND if the master isnt a PC
    if (!GetIsPC(OBJECT_SELF) && !GetIsPC(GetMaster()) && GetLocalInt(oTrap, "trap_dc") > 0)
    {
        NWNX_Events_SkipEvent();
    }
}
