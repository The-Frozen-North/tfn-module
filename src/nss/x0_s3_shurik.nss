//::///////////////////////////////////////////////////
//:: X0_S3_SHURIK
//:: Shoots a shuriken at the target.
//:: The shuriken animation effect is produced by the
//:: projectile settings in spells.2da; this impact script
//:: merely does the hit check and applies the damage.
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 11/14/2002
//::///////////////////////////////////////////////////
/*
Patch 1.70

- totally reworked in order to actually do something
*/

#include "70_inc_spells"
#include "nw_i0_spells"

void main()
{
    //Declare major variables
    spellsDeclareMajorVariables();

    // Determine the level-based changes
    int nMissiles;

    // Possible levels: 1, 4, 7, 11, 15
    if (spell.Level < 4) {
        nMissiles = 1;
    } else if (spell.Level < 7) {
        nMissiles = 2;
    } else if (spell.Level < 11) {
        nMissiles = 3;
    } else if (spell.Level < 15) {
        nMissiles = 4;
    } else {
        nMissiles = 5;
    }

    int nDamage = GetSavingThrowAdjustedDamage(d3(spell.Level), spell.Target, spell.DC+3, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_TRAP);
    if(nDamage > 0)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_PIERCING), spell.Target);
    }

    int i;
    float fDelay;
    for(i=1; i < nMissiles; i++)
    {
        fDelay = GetRandomDelay(0.0,0.5);
        // Fire another projectile at the target, but fakely
        DelayCommand(fDelay, ActionCastFakeSpellAtObject(SPELL_TRAP_DART, spell.Target, PROJECTILE_PATH_TYPE_HOMING));
        nDamage = GetSavingThrowAdjustedDamage(d4(spell.Level), spell.Target, spell.DC, SAVING_THROW_TYPE_TRAP);
        if(nDamage > 0)
        {
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_PIERCING), spell.Target));
        }
    }
}
