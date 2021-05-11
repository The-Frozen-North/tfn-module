#include "nwnx_admin"
#include "nwnx_events"
#include "nwnx_object"

void main()
{
    object oObject = NWNX_Object_StringToObject(NWNX_Events_GetEventData("EXAMINEE_OBJECT_ID"));

    if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE && GetFactionEqual(oObject))
        NWNX_Administration_SetPlayOption(NWNX_ADMINISTRATION_OPTION_EXAMINE_EFFECTS, TRUE);
}
