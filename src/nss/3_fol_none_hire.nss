#include "1_inc_follower"
#include "nw_i0_generic"

void main()
{

    object oPC = GetPCSpeaker();
    if (GetFollowerCount(oPC) == 0)
    {
        SetFollowerMaster(OBJECT_SELF, oPC);

        SetAssociateState(NW_ASC_USE_RANGED_WEAPON, FALSE);
        ClearAllActions();
        AssignCommand(OBJECT_SELF, ActionEquipMostDamagingMelee());
    }
}
