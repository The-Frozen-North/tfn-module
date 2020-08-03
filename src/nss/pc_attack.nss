#include "nwnx_damage"
#include "inc_horse"

void main()
{
    struct NWNX_Damage_AttackEventData data;

    // Get all the data of the damage event
    data = NWNX_Damage_GetAttackEventData();

    if (GetIsMounted(OBJECT_SELF))
    {
        if (GetWeaponRanged(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, OBJECT_SELF)) && !GetHasFeat(FEAT_MOUNTED_ARCHERY, OBJECT_SELF))
        {
            data.iAttackResult = 4;
            NWNX_Damage_SetAttackEventData(data);
            FloatingTextStringOnCreature("*You need the Mounted Archery feat to use range attacks while mounted.*", OBJECT_SELF);
        }
        else if (!GetHasFeat(FEAT_MOUNTED_COMBAT, OBJECT_SELF))
        {
            data.iAttackResult = 4;
            NWNX_Damage_SetAttackEventData(data);
            FloatingTextStringOnCreature("*You need the Mounted Combat feat to attack while mounted.*", OBJECT_SELF);
        }
    }
}
