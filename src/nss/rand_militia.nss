#include "nwnx_creature"
#include "inc_rand_equip"
#include "inc_rand_appear"

void main()
{
    RandomiseGenderAndAppearance();
    RandomiseCreatureSoundset_Average();
    int nRoll = Random(100);
    int nWeaponType = BASE_ITEM_SHORTSWORD;
    if (nRoll < 40)
    {
        nWeaponType = BASE_ITEM_CLUB;
    }
    else if (nRoll < 45)
    {
        nWeaponType = BASE_ITEM_HANDAXE;
    }
    else if (nRoll < 55)
    {
        nWeaponType = BASE_ITEM_LIGHTMACE;
    }
    else if (nRoll < 60)
    {
        nWeaponType = BASE_ITEM_SICKLE;
    }
    // 10% chance to go to t2 (high quality), 1% to roll a unique...
    object oMain = TryEquippingRandomItemOfTier(nWeaponType, 1 + (d10() == 10), 1, OBJECT_SELF, INVENTORY_SLOT_RIGHTHAND);
}
