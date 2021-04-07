//::///////////////////////////////////////////////
//:: Flame Strike
//:: NW_S0_FlmStrike
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// A flame strike is a vertical column of divine fire
// roaring downward. The spell deals 1d6 points of
// damage per level, to a maximum of 15d6. Half the
// damage is fire damage, but the rest of the damage
// results directly from divine power and is therefore
// not subject to protection from elements (fire),
// fire shield (chill shield), etc.
*/
//:://////////////////////////////////////////////
//:: Created By: Noel Borstad
//:: Created On: Oct 19, 2000
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 20, 2001
//:: Update Pass By: Preston W, On: Aug 1, 2001
/*
Patch 1.72
- spell will no longer damage allies under high difficulty settings
Patch 1.70
- fixed special case when damage wasn't applied
- damage values were always even
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageCap = 15;
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_FIRE;
    spell.Range = RADIUS_SIZE_MEDIUM;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    object oTarget;
    int nCasterLvl = spell.Level;
    int nDamage, nDamage1, nDamage2;

    effect eStrike = EffectVisualEffect(VFX_IMP_DIVINE_STRIKE_FIRE);
    effect eVis = EffectVisualEffect(spell.DmgVfxS);
    effect eHoly;
    effect eFire;
    //Limit caster level for the purposes of determining damage.
    if (nCasterLvl > spell.DamageCap)
    {
        nCasterLvl = spell.DamageCap;
    }

    //Declare the spell shape, size and the location.  Capture the first target object in the shape.
    oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE|OBJECT_TYPE_PLACEABLE|OBJECT_TYPE_DOOR);
    //Apply the location impact visual to the caster location instead of caster target creature.
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eStrike, spell.Loc);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget))
    {
        if (spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            //Make SR check, and appropriate saving throw(s).
            if (!MyResistSpell(spell.Caster, oTarget, 0.6))
            {
                nDamage =  MaximizeOrEmpower(spell.Dice,nCasterLvl,spell.Meta);
                nDamage2 = 0;
                //Make a faction check so that only enemies receieve the full brunt of the damage.
                if (!spellsIsTarget(oTarget, SPELL_TARGET_ALLALLIES, spell.Caster))
                {
                    //Adjust the damage based on Reflex Save, Evasion and Improved Evasion
                    nDamage2 = GetSavingThrowAdjustedDamage(nDamage/2, oTarget, spell.DC, spell.SavingThrow, SAVING_THROW_TYPE_DIVINE, spell.Caster);
                    if(nDamage2 > 0)
                    {
                        eHoly =  EffectDamage(nDamage2,DAMAGE_TYPE_DIVINE);
                        DelayCommand(0.6, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHoly, oTarget));
                    }
                }
                nDamage1 = GetSavingThrowAdjustedDamage((nDamage+1)/2, oTarget, spell.DC, spell.SavingThrow, spell.SaveType, spell.Caster);
                if(nDamage1 > 0)
                {
                    eFire =  EffectDamage(nDamage1,spell.DamageType);
                    DelayCommand(0.6, ApplyEffectToObject(DURATION_TYPE_INSTANT, eFire, oTarget));
                }
                //If at least one of the save failed, apply fire visual effect.
                if(nDamage1+nDamage2 > 0)
                {
                    DelayCommand(0.6, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                }
            }
        }
        //Select the next target within the spell shape.
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE|OBJECT_TYPE_PLACEABLE|OBJECT_TYPE_DOOR);
    }
}
