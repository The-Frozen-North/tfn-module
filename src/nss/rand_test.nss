#include "inc_rand_equip"
#include "inc_rand_feat"
#include "inc_rand_spell"
#include "inc_rand_appear"
#include "inc_debug"

// normally you'd use the constant in inc_rand_spell but with so many this takes a lot of time
// so just do one for the sake of examples
const int NUM_SPELLBOOKS = 1;

void main()
{
    if (!GetIsDevServer())
    {
        DestroyObject(OBJECT_SELF);
        return;
    }
    RandomiseGenderAndAppearance(OBJECT_SELF);
    RandomiseCreatureSoundset_Average(OBJECT_SELF);
    AddRandomFeats(OBJECT_SELF, RAND_FEAT_LIST_CASTER, 5);
    struct RandomWeaponResults rwr = RollRandomWeaponTypesForCreature(OBJECT_SELF);
    object oMain = TryEquippingRandomItemOfTier(rwr.nMainHand, 5, 100, OBJECT_SELF, INVENTORY_SLOT_RIGHTHAND);
    TryEquippingRandomItemOfTier(rwr.nOffHand, 5, 100, OBJECT_SELF, INVENTORY_SLOT_LEFTHAND);
    TryEquippingRandomApparelOfTier(5, 100, OBJECT_SELF);
    // This script is shared amongst the different creatures, detect which class this needs to run for
    int nCastClass;
    if (GetLevelByClass(CLASS_TYPE_SORCERER, OBJECT_SELF))
    {
        nCastClass = CLASS_TYPE_SORCERER;
    }
    else if (GetLevelByClass(CLASS_TYPE_WIZARD, OBJECT_SELF))
    {
        nCastClass = CLASS_TYPE_WIZARD;
    }
    else if (GetLevelByClass(CLASS_TYPE_CLERIC, OBJECT_SELF))
    {
        nCastClass = CLASS_TYPE_CLERIC;
    }
    else if (GetLevelByClass(CLASS_TYPE_DRUID, OBJECT_SELF))
    {
        nCastClass = CLASS_TYPE_DRUID;
    }
    else
    {
        return;
    }
    if (nCastClass != CLASS_TYPE_WIZARD && nCastClass != CLASS_TYPE_SORCERER)
    {
        TryEquippingRandomArmorOfTier(8, 5, 100, OBJECT_SELF);
    }
    else
    {
        TryEquippingRandomArmorOfTier(0, 5, 100, OBJECT_SELF);
    }
    if (SeedingSpellbooks(nCastClass, OBJECT_SELF))
    {
        int i;
        if (nCastClass == CLASS_TYPE_WIZARD || nCastClass == CLASS_TYPE_SORCERER)
        {
            for (i=0; i<NUM_SPELLBOOKS; i++)
            {
                RandomSpellbookPopulate(RAND_SPELL_ARCANE_EVOKER_SINGLE_TARGET, OBJECT_SELF, nCastClass);
            }
            for (i=0; i<NUM_SPELLBOOKS; i++)
            {
                RandomSpellbookPopulate(RAND_SPELL_ARCANE_EVOKER_AOE, OBJECT_SELF, nCastClass);
            }
            for (i=0; i<NUM_SPELLBOOKS; i++)
            {
                RandomSpellbookPopulate(RAND_SPELL_ARCANE_SINGLE_TARGET_BALANCED, OBJECT_SELF, nCastClass);
            }
            for (i=0; i<NUM_SPELLBOOKS; i++)
            {
                RandomSpellbookPopulate(RAND_SPELL_ARCANE_CONTROLLER, OBJECT_SELF, nCastClass);
            }
        }
        else
        {
            for (i=0; i<NUM_SPELLBOOKS; i++)
            {
                RandomSpellbookPopulate(RAND_SPELL_DIVINE_EVOKER, OBJECT_SELF, nCastClass);
            }
            for (i=0; i<NUM_SPELLBOOKS; i++)
            {
                RandomSpellbookPopulate(RAND_SPELL_DIVINE_BUFF_ATTACKS, OBJECT_SELF, nCastClass);
            }
            for (i=0; i<NUM_SPELLBOOKS; i++)
            {
                RandomSpellbookPopulate(RAND_SPELL_DIVINE_CONTROLLER, OBJECT_SELF, nCastClass);
            }
            for (i=0; i<NUM_SPELLBOOKS; i++)
            {
                RandomSpellbookPopulate(RAND_SPELL_DIVINE_SINGLE_TARGET_BALANCED, OBJECT_SELF, nCastClass);
            }
            for (i=0; i<NUM_SPELLBOOKS; i++)
            {
                RandomSpellbookPopulate(RAND_SPELL_DIVINE_HEALER, OBJECT_SELF, nCastClass);
            }
        }
        SeedingSpellbooksComplete(OBJECT_SELF);
    }
    else
    {
        if (nCastClass == CLASS_TYPE_WIZARD || nCastClass == CLASS_TYPE_SORCERER)
        {
            int nIndex = Random(NUM_SPELLBOOKS*4);
            LoadSpellbook(nCastClass, OBJECT_SELF, nIndex);
            if (nIndex < NUM_SPELLBOOKS) { SetName(OBJECT_SELF, "Evoker Single Target"); }
            else if (nIndex < NUM_SPELLBOOKS*2) { SetName(OBJECT_SELF, "Evoker AoE"); }
            else if (nIndex < NUM_SPELLBOOKS*3) { SetName(OBJECT_SELF, "Balanced"); }
            else { SetName(OBJECT_SELF, "Controller"); }
        }
        else
        {
            int nIndex = Random(NUM_SPELLBOOKS*5);
            LoadSpellbook(nCastClass, OBJECT_SELF, nIndex);
            if (nIndex < NUM_SPELLBOOKS) { SetName(OBJECT_SELF, "Evoker"); }
            else if (nIndex < NUM_SPELLBOOKS*2) { SetName(OBJECT_SELF, "Attacker"); }
            else if (nIndex < NUM_SPELLBOOKS*3) { SetName(OBJECT_SELF, "Controller"); }
            else if (nIndex < NUM_SPELLBOOKS*4) { SetName(OBJECT_SELF, "Balanced"); }
            else { SetName(OBJECT_SELF, "Healer"); }
        }
    }
}
