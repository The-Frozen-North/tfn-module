#include "inc_rand_equip"
#include "inc_rand_feat"
#include "inc_rand_appear"

void main()
{
    RandomiseGenderAndAppearance(OBJECT_SELF);
    RandomiseCreatureSoundset_Average(OBJECT_SELF);
    SetRandomFeatWeight(OBJECT_SELF, FEAT_KNOCKDOWN, 8);
    SetRandomFeatWeight(OBJECT_SELF, FEAT_WEAPON_PROFICIENCY_EXOTIC, 5);
    AddRandomFeats(OBJECT_SELF, RAND_FEAT_LIST_FIGHTER_BONUS, 2);
    AddRandomFeats(OBJECT_SELF, RAND_FEAT_LIST_RANDOM, 2);
    // We do like swords.
    SetRandomEquipWeaponTypeWeight(OBJECT_SELF, BASE_ITEM_GREATSWORD, 5);
    SetRandomEquipWeaponTypeWeight(OBJECT_SELF, BASE_ITEM_BASTARDSWORD, 5);
    SetRandomEquipWeaponTypeWeight(OBJECT_SELF, BASE_ITEM_LONGSWORD, 5);
    struct RandomWeaponResults rwr = RollRandomWeaponTypesForCreature(OBJECT_SELF);
    object oMain = TryEquippingRandomItemOfTier(rwr.nMainHand, 3, 1, OBJECT_SELF, INVENTORY_SLOT_RIGHTHAND);
    TryEquippingRandomItemOfTier(rwr.nOffHand, 3, 1, OBJECT_SELF, INVENTORY_SLOT_LEFTHAND);
    TryEquippingRandomApparelOfTier(3, 2, OBJECT_SELF);
    if (!GetLocalInt(oMain, "unique"))
    {
        IPSafeAddItemProperty(oMain, ItemPropertyOnHitProps(IP_CONST_ONHIT_ITEMPOISON, IP_CONST_ONHIT_SAVEDC_14, IP_CONST_POISON_1D2_STRDAMAGE));
    }
}
