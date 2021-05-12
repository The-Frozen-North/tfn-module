#include "inc_hai_equip"


void main()
{
    int bShowStatus = GetLocalInt(OBJECT_SELF, sHenchShowWeaponStatus);
    if (bShowStatus)
    {
        DeleteLocalInt(OBJECT_SELF, sHenchShowWeaponStatus);
    }
    if (!HenchEquipAppropriateWeapons(OBJECT_INVALID, -5., bShowStatus, GetHasEffect(EFFECT_TYPE_POLYMORPH)))
    {
        ActionDoCommand(ActionContinueEquip(OBJECT_INVALID, bShowStatus, 2));
    }
}

