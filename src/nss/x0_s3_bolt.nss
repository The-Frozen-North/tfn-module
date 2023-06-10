//:://////////////////////////////////////////////////
//:: X0_S3_BOLT
/*
  Spell script.
  Launches a crossbow bolt at a single target, with
  increasing attack and damage penalties at higher levels.
 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 12/08/2002
//:://////////////////////////////////////////////////
/*
Patch 1.70

- totally reworked in order to actually do something
*/

#include "70_inc_spells"
#include "nw_i0_spells"

void main()
{
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

    int nEnemies;
    location lLoc = GetLocation(spell.Target);
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE,RADIUS_SIZE_COLOSSAL,lLoc,TRUE);
    while(GetIsObjectValid(oTarget))
    {
        if(!GetIsReactionTypeFriendly(oTarget, spell.Caster))
        {
            nEnemies++;
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE,RADIUS_SIZE_COLOSSAL,lLoc,TRUE);
    }

    int nExtraMissiles = nMissiles / nEnemies;

    if(nExtraMissiles < 1)
    {
        nExtraMissiles = 1;
    }

    // by default the Remainder will be 0 (if more than enough enemies for all the missiles)
    int i, nDamage, nRemainder = 0;

    if (nExtraMissiles >0)
        nRemainder = nMissiles % nEnemies;

    if (nEnemies > nMissiles)
        nEnemies = nMissiles;

    float fDelay;
    oTarget = GetFirstObjectInShape(SHAPE_SPHERE,RADIUS_SIZE_COLOSSAL,lLoc,TRUE);
    while(GetIsObjectValid(oTarget))
    {
        if(!GetIsReactionTypeFriendly(oTarget, spell.Caster))
        {
            for(i=1; i <= nExtraMissiles + nRemainder; i++)
            {
                fDelay = GetRandomDelay(0.0,0.5);
                // Fire another projectile at the target, but fakely
                DelayCommand(fDelay, ActionCastFakeSpellAtObject(SPELL_TRAP_BOLT, oTarget, PROJECTILE_PATH_TYPE_HOMING));
                nDamage = GetSavingThrowAdjustedDamage(d8(spell.Level),oTarget,spell.DC,SAVING_THROW_REFLEX,SAVING_THROW_TYPE_TRAP);
                if(nDamage > 0)
                {
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_PIERCING), oTarget));
                }
            }
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE,RADIUS_SIZE_COLOSSAL,lLoc,TRUE);
    }
}
