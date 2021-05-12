#include "x0_inc_henai"

void main()
{
    SetAssociateState(NW_ASC_USE_RANGED_WEAPON, TRUE);
    ClearAllActions();
    AssignCommand(OBJECT_SELF, ActionEquipMostDamagingRanged());
}
