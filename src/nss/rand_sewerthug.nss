#include "nwnx_creature"
#include "inc_rand_equip"
#include "inc_rand_appear"

// Users:
// Mugger (mugger) - dual short swords
// Ruffian (ruffian) - darts/dagger
// Thug (thug) - morningstar

// All lack exotic proficiency

void main()
{
    // These are non-dynamic appearances
    //RandomiseGenderAndAppearance();
    //RandomiseCreatureSoundset_Rough();
    string sResRef = GetResRef(OBJECT_SELF);
    struct RandomWeaponResults rwr;
    if (sResRef == "mugger")
    {
        SetRandomEquipWeaponTypeWeight(OBJECT_SELF, BASE_ITEM_SCIMITAR, 0);
        SetRandomEquipWeaponTypeWeight(OBJECT_SELF, BASE_ITEM_RAPIER, 0);
        SetRandomEquipWeaponTypeWeight(OBJECT_SELF, BASE_ITEM_WARHAMMER, 0);
        SetRandomEquipWeaponTypeWeight(OBJECT_SELF, BASE_ITEM_BATTLEAXE, 0);
        SetRandomEquipWeaponTypeWeight(OBJECT_SELF, BASE_ITEM_LONGSWORD, 0);
        rwr = RollRandomWeaponTypesForCreature(OBJECT_SELF);
    }
    else if (sResRef == "ruffian")
    {
        // I guess darts/dagger is okay
        return;
    }
    else if (sResRef == "thug")
    {
        // Don't make it pass 1d8, and don't increase AC more than it is already
        SetRandomEquipWeaponTypeWeight(OBJECT_SELF, BASE_ITEM_GREATSWORD, 0);
        SetRandomEquipWeaponTypeWeight(OBJECT_SELF, BASE_ITEM_GREATAXE, 0);
        SetRandomEquipWeaponTypeWeight(OBJECT_SELF, BASE_ITEM_HALBERD, 0);
        SetRandomEquipWeaponTypeWeight(OBJECT_SELF, BASE_ITEM_HEAVYFLAIL, 0);
        // High crit weapons will probably kill people in one hit, feels bad
        SetRandomEquipWeaponTypeWeight(OBJECT_SELF, BASE_ITEM_SCIMITAR, 0);
        SetRandomEquipWeaponTypeWeight(OBJECT_SELF, BASE_ITEM_RAPIER, 0);
        SetRandomEquipWeaponTypeWeight(OBJECT_SELF, BASE_ITEM_WARHAMMER, 0);
        SetRandomEquipWeaponTypeWeight(OBJECT_SELF, BASE_ITEM_BATTLEAXE, 0);
        SetRandomEquipWeaponTypeWeight(OBJECT_SELF, BASE_ITEM_LONGSWORD, 0);
        SetRandomEquipWeaponTypeWeight(OBJECT_SELF, BASE_ITEM_SHORTSPEAR, 0);
        rwr = RollRandomWeaponTypesForCreature(OBJECT_SELF);
        // No shields please
        rwr.nOffHand = BASE_ITEM_INVALID;
    }

    TryEquippingRandomItemOfTier(rwr.nMainHand, 1, 1, OBJECT_SELF, INVENTORY_SLOT_RIGHTHAND);
    TryEquippingRandomItemOfTier(rwr.nOffHand, 1, 1, OBJECT_SELF, INVENTORY_SLOT_LEFTHAND);
}
