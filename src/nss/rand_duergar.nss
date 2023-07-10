#include "inc_rand_equip"
#include "inc_rand_feat"
#include "inc_rand_spell"

void main()
{
    TryEquippingRandomApparelOfTier(3, 4, OBJECT_SELF);
    if (GetLevelByClass(CLASS_TYPE_CLERIC))
    {
        AddRandomFeats(OBJECT_SELF, RAND_FEAT_LIST_CASTER, 3);
        if (SeedingSpellbooks(CLASS_TYPE_CLERIC, OBJECT_SELF))
        {
            SetRandomDomainWeight(OBJECT_SELF, DOMAIN_EARTH, 5);
            SetRandomDomainWeight(OBJECT_SELF, DOMAIN_AIR, -1);
            SetRandomDomainWeight(OBJECT_SELF, DOMAIN_GOOD, -1);
            SetRandomDomainWeight(OBJECT_SELF, DOMAIN_PLANT, -1);
            SetRandomDomainWeight(OBJECT_SELF, DOMAIN_SUN, -1);
            int i;
            for (i=0; i<RAND_SPELL_NUM_SPELLBOOKS; i++)
            {
                RandomSpellbookPopulate(RAND_SPELL_DIVINE_SINGLE_TARGET_BALANCED, OBJECT_SELF, CLASS_TYPE_CLERIC);
            }
            SeedingSpellbooksComplete(OBJECT_SELF);
        }
        else
        {
            LoadSpellbook(CLASS_TYPE_CLERIC, OBJECT_SELF);
        }
    }
    else if (GetLevelByClass(CLASS_TYPE_WIZARD))
    {
        AddRandomFeats(OBJECT_SELF, RAND_FEAT_LIST_CASTER, 3);
        TryEquippingRandomArmorOfTier(0, 2, 100, OBJECT_SELF);
        if (SeedingSpellbooks(CLASS_TYPE_WIZARD, OBJECT_SELF))
        {
            int i;
            for (i=0; i<RAND_SPELL_NUM_SPELLBOOKS; i++)
            {
                RandomSpellbookPopulate(RAND_SPELL_ARCANE_CONTROLLER, OBJECT_SELF, CLASS_TYPE_WIZARD);
            }
            SeedingSpellbooksComplete(OBJECT_SELF);
        }
        else
        {
            LoadSpellbook(CLASS_TYPE_WIZARD, OBJECT_SELF);
        }
    }
    
    if (!GetLevelByClass(CLASS_TYPE_WIZARD))
    {
        if (GetResRef(OBJECT_SELF) != "duergar_skirmish")
        {
            SetRandomEquipWeaponTypeWeight(OBJECT_SELF, BASE_ITEM_BATTLEAXE, 15);
            SetRandomEquipWeaponTypeWeight(OBJECT_SELF, BASE_ITEM_BASTARDSWORD, 8);
            SetRandomEquipWeaponTypeWeight(OBJECT_SELF, BASE_ITEM_WARHAMMER, 15);
            SetRandomEquipWeaponTypeWeight(OBJECT_SELF, BASE_ITEM_DWARVENWARAXE, 15);
            SetRandomEquipWeaponTypeWeight(OBJECT_SELF, BASE_ITEM_GREATAXE, 10);
            if (Random(100) < 90)
            {
                SetLocalInt(OBJECT_SELF, RAND_EQUIP_FORCE_SHIELD, 1);
            }
            struct RandomWeaponResults rwr = RollRandomWeaponTypesForCreature(OBJECT_SELF);
            // These had mixed +1/+2 items before
            object oMain = TryEquippingRandomItemOfTier(rwr.nMainHand, 3 + (Random(100) < 20), 2, OBJECT_SELF, INVENTORY_SLOT_RIGHTHAND);
            TryEquippingRandomItemOfTier(rwr.nOffHand, 3 + (Random(100) < 20), 2, OBJECT_SELF, INVENTORY_SLOT_LEFTHAND);
            FixWeaponSpecificFeats(OBJECT_SELF);
        }
    }
}
