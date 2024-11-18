#include "inc_follower"
#include "nw_i0_generic"

void main()
{

    object oPC = GetPCSpeaker();

    SetFollowerMaster(OBJECT_SELF, oPC);

    SetAssociateState(NW_ASC_USE_RANGED_WEAPON, GetLocalInt(OBJECT_SELF, "range"));
    ClearAllActions();
    AssignCommand(OBJECT_SELF, ActionEquipMostDamagingMelee());
}
