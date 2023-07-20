#include "nwnx_object"

void main()
{
    object oObject = GetFirstObjectInArea(OBJECT_SELF, OBJECT_TYPE_PLACEABLE);

    while (GetIsObjectValid(oObject))
    {
        SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_USED, "");
        SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_CLOSED, "");
        SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_DAMAGED, "");
        SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_DEATH, "");
        SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_DISARM, "");
        SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_HEARTBEAT, "");
        SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_LEFT_CLICK, "converse_click");
        SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_MELEEATTACKED, "");
        SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_SPELLCASTAT, "");
        SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_OPEN, "");
        SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_TRAPTRIGGERED, "");
        SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_DIALOGUE, "");

        SetPlotFlag(oObject, TRUE);
        NWNX_Object_SetPlaceableIsStatic(oObject, FALSE);
        NWNX_Object_SetHasInventory(oObject, FALSE);
        SetUseableFlag(oObject, TRUE);
        NWNX_Object_SetDialogResref(oObject, "buy_furniture");


        oObject = GetNextObjectInArea(OBJECT_SELF, OBJECT_TYPE_PLACEABLE);
    }
}
