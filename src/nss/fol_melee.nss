#include "x0_inc_henai"

void main()
{
    SetAssociateState(NW_ASC_USE_RANGED_WEAPON, FALSE);
    ClearAllActions();
    AssignCommand(OBJECT_SELF, ActionEquipMostDamagingMelee());
}
