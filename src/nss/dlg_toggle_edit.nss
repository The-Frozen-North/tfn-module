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
            if (GetLocalInt(oArea, "edit") == 1)
            {
                SetHomeEditMode(oArea, FALSE);
                NuiDestroy(oPC, NuiGetEventWindow());
                FloatingTextStringOnCreature("Placeable editing disabled.", oPC, FALSE);
            }
            else
            {
                SetHomeEditMode(oArea, TRUE);
                FloatingTextStringOnCreature("Placeable editing enabled.", oPC, FALSE);
            }
        }
        else
        {
            FloatingTextStringOnCreature("This house does not belong to you.", oPC, FALSE);
        }
    }
}
