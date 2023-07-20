#include "nwnx_object"
#include "inc_housing"

void main()
{
    object oObject = GetFirstObjectInArea(OBJECT_SELF, OBJECT_TYPE_PLACEABLE);

    while (GetIsObjectValid(oObject))
    {
        CleanupPlaceable(oObject);

        SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_LEFT_CLICK, "converse_click");

        SetUseableFlag(oObject, TRUE);
        NWNX_Object_SetDialogResref(oObject, "buy_furniture");

        SetTag(oObject, "_Placeable"+IntToString(GetAppearanceType(oObject)));

        oObject = GetNextObjectInArea(OBJECT_SELF, OBJECT_TYPE_PLACEABLE);
    }
}
