#include "nwnx_object"

void main()
{
    object oWP = GetNearestObjectByTag("MeldanenPortalSpawn");
    object oPortal = CreateObject(OBJECT_TYPE_PLACEABLE, "portalblue", GetLocation(oWP));
    NWNX_Object_SetPlaceableIsStatic(oPortal, FALSE);
    SetPlotFlag(oPortal, TRUE);
    AssignCommand(GetModule(), DelayCommand(120.0, DestroyObject(oPortal)));
    SetEventScript(oPortal, EVENT_SCRIPT_PLACEABLE_ON_USED, "meldport_use");
}
