#include "inc_rand_equip"
#include "inc_rand_feat"
#include "inc_rand_spell"

void main()
{
    AddRandomFeats(OBJECT_SELF, RAND_FEAT_LIST_CASTER, 2);
    struct RandomWeaponResults rwr = RollRandomWeaponTypesForCreature(OBJECT_SELF);
    object oMain = TryEquippingRandomItemOfTier(rwr.nMainHand, 3, 2, OBJECT_SELF, INVENTORY_SLOT_RIGHTHAND);
    TryEquippingRandomItemOfTier(rwr.nOffHand, 3, 2, OBJECT_SELF, INVENTORY_SLOT_LEFTHAND);
    TryEquippingRandomArmorOfTier(0, 3, 100, OBJECT_SELF);
    TryEquippingRandomApparelOfTier(3, 2, OBJECT_SELF);
    if (SeedingSpellbooks(CLASS_TYPE_WIZARD, OBJECT_SELF))
    {
        SetRandomSpellWeight(OBJECT_SELF, SPELL_NEGATIVE_ENERGY_RAY, 10);
        SetRandomSpellWeight(OBJECT_SELF, SPELL_NEGATIVE_ENERGY_BURST, 14);
        SetRandomSpellWeight(OBJECT_SELF, SPELL_DEATH_ARMOR, 8);
        SetRandomSpellWeight(OBJECT_SELF, SPELL_STONE_BONES, 8);
        int i;
        for (i=0; i<RAND_SPELL_NUM_SPELLBOOKS; i++)
        {
            SetRandomSpellWeight(OBJECT_SELF, SPELL_ICE_DAGGER, d2() - 1);
            SetRandomSpellWeight(OBJECT_SELF, SPELL_MAGIC_MISSILE, d2() - 1);
            SetRandomSpellWeight(OBJECT_SELF, SPELL_HORIZIKAULS_BOOM, d2() - 1);
            RandomSpellbookPopulate(RAND_SPELL_ARCANE_EVOKER_SINGLE_TARGET, OBJECT_SELF, CLASS_TYPE_WIZARD);
        }
        SeedingSpellbooksComplete(OBJECT_SELF);
    }
    else
    {
        LoadSpellbook(CLASS_TYPE_WIZARD, OBJECT_SELF);
    }
}
