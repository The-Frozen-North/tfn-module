#include "inc_rand_equip"
#include "inc_rand_feat"
#include "inc_rand_spell"

void main()
{
    AddRandomFeats(OBJECT_SELF, RAND_FEAT_LIST_CASTER, 2);
    struct RandomWeaponResults rwr = RollRandomWeaponTypesForCreature(OBJECT_SELF);
    object oMain = TryEquippingRandomItemOfTier(rwr.nMainHand, 3, 2, OBJECT_SELF, INVENTORY_SLOT_RIGHTHAND);
    TryEquippingRandomItemOfTier(rwr.nOffHand, 3, 2, OBJECT_SELF, INVENTORY_SLOT_LEFTHAND);
    TryEquippingRandomArmorOfTier(6 + Random(3), 3, 2, OBJECT_SELF);
    TryEquippingRandomApparelOfTier(3, 2, OBJECT_SELF);
    if (SeedingSpellbooks(CLASS_TYPE_CLERIC, OBJECT_SELF))
    {
		SetRandomDomainWeight(OBJECT_SELF, DOMAIN_DESTRUCTION, 4);
		SetRandomDomainWeight(OBJECT_SELF, DOMAIN_EVIL, 8);
		SetRandomDomainWeight(OBJECT_SELF, DOMAIN_MAGIC, 2);
		SetRandomDomainWeight(OBJECT_SELF, DOMAIN_SUN, -1);
        SetRandomSpellWeight(OBJECT_SELF, SPELL_NEGATIVE_ENERGY_RAY, 10);
        SetRandomSpellWeight(OBJECT_SELF, SPELL_NEGATIVE_ENERGY_BURST, 14);
        SetRandomSpellWeight(OBJECT_SELF, SPELL_ANIMATE_DEAD, 15);
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
