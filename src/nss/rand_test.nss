#include "inc_rand_equip"
#include "inc_rand_feat"
#include "inc_rand_spell"

void main()
{
    AddRandomFeats(OBJECT_SELF, RAND_FEAT_LIST_CASTER, 5);
    struct RandomWeaponResults rwr = RollRandomWeaponTypesForCreature(OBJECT_SELF);
    object oMain = TryEquippingRandomItemOfTier(rwr.nMainHand, 5, 100, OBJECT_SELF, INVENTORY_SLOT_RIGHTHAND);
    TryEquippingRandomItemOfTier(rwr.nOffHand, 5, 100, OBJECT_SELF, INVENTORY_SLOT_LEFTHAND);
    TryEquippingRandomApparelOfTier(5, 100, OBJECT_SELF);
    if (SeedingSpellbooks(CLASS_TYPE_WIZARD, OBJECT_SELF))
    {
        int i;
        for (i=0; i<RAND_SPELL_NUM_SPELLBOOKS; i++)
        {
            RandomSpellbookPopulate(RAND_SPELL_ARCANE_EVOKER_SINGLE_TARGET, OBJECT_SELF, CLASS_TYPE_WIZARD);
        }
        SeedingSpellbooksComplete(OBJECT_SELF);
    }
    else
    {
        LoadSpellbook(CLASS_TYPE_WIZARD, OBJECT_SELF);
    }
}
