#include "inc_rand_equip"
#include "inc_rand_feat"

void main()
{
    SetRandomEquipWeaponTypeWeight(OBJECT_SELF, BASE_ITEM_WHIP, 0);
    SetRandomEquipWeaponTypeWeight(OBJECT_SELF, BASE_ITEM_KAMA, 0);
    struct RandomWeaponResults rwr = RollRandomWeaponTypesForCreature(OBJECT_SELF);
    AddRandomFeats(OBJECT_SELF, RAND_FEAT_LIST_FIGHTER_BONUS, 4);
    int nRoll = d100();
    if (nRoll <= 10)
    {
        TryEquippingRandomItemOfTier(rwr.nMainHand, 5, 40, OBJECT_SELF, INVENTORY_SLOT_RIGHTHAND);
    }
    else if (nRoll <= 60)
    {
        TryEquippingRandomItemOfTier(rwr.nMainHand, 4, 30, OBJECT_SELF, INVENTORY_SLOT_RIGHTHAND);
    }
    else
    {
        TryEquippingRandomItemOfTier(rwr.nMainHand, 3, 20, OBJECT_SELF, INVENTORY_SLOT_RIGHTHAND);
    }
}
