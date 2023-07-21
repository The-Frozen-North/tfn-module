//#include "nwnx_player"
#include "inc_housing"

void main()
{
    object oPC = GetLastUsedBy();

    if (GetIsPC(oPC))
    {
        object oArea = GetArea(OBJECT_SELF);
        if (IsInOwnHome(oPC))
        {
            int bUseable = FALSE;
            string sScript = "";
            if (GetLocalInt(oArea, "edit") == 1)
            {
                DeleteLocalInt(oArea, "edit");
                NuiDestroy(oPC, NuiGetEventWindow());
                FloatingTextStringOnCreature("Placeable editing disabled.", oPC, FALSE);
            }
            else
            {
                SetLocalInt(oArea, "edit", 1);
                FloatingTextStringOnCreature("Placeable editing enabled.", oPC, FALSE);
                sScript = "placeable_edit";
                bUseable = TRUE;
            }

            int i;
            object oObject = GetNearestObjectByTag("_HomePlaceable");

            for (i = 1; i < 999; i++)
            {
                if (!GetIsObjectValid(oObject)) return;

                //NWNX_Player_SetPlaceableUsable(oPC, oObject, bUseable);
                SetUseableFlag(oObject, bUseable);
                SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_LEFT_CLICK, sScript);

                oObject = GetNearestObjectByTag("_HomePlaceable", OBJECT_SELF, i);
            }
        }
        else
        {
            FloatingTextStringOnCreature("This house does not belong to you.", oPC, FALSE);
        }
    }
}
