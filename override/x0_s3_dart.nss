//::///////////////////////////////////////////////////
//:: X0_S3_DART
//:: Shoots a dart at the target. The dart animation is produced
//:: by the projectile specifications for this spell in the
//:: spells.2da file, so this merely does a check for a hit
//:: and applies damage as appropriate.
//::
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

    int nDamage = GetSavingThrowAdjustedDamage(d4(spell.Level), spell.Target, spell.DC, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_TRAP);
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
