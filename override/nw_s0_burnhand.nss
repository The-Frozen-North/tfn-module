//::///////////////////////////////////////////////
//:: Burning Hands
//:: NW_S0_BurnHand
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// A thin sheet of searing flame shoots from your
// outspread fingertips. You must hold your hands
// with your thumbs touching and your fingers spread
// The sheet of flame is about as thick as your thumbs.
// Any creature in the area of the flames suffers
// 1d4 points of fire damage per your caster level
// (maximum 5d4).
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: April 5, 2001
//:://////////////////////////////////////////////
//:: Last Updated On: April 5th, 2001
//:: VFX Pass By: Preston W, On: June 20, 2001
//:: Update Pass By: Preston W, On: July 23, 2001
/*
Patch 1.70

- area of effect size prolonged to 11.0 to match the distance of the cone usage/visual
- cone could in certain circumstances affect caster
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageCap = 5;
    spell.DamageType = DAMAGE_TYPE_FIRE;
    spell.Range = 11.0;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }


    //Declare major variables
    spellsDeclareMajorVariables();
    float fDist;
    int nCasterLevel = spell.Level;
    int nDamage;
    effect eFire;
    //Declare and assign personal impact visual effect.
    effect eVis = EffectVisualEffect(VFX_IMP_FLAME_S);
    //Limit Maximum caster level to keep damage to spell specifications.
    if (nCasterLevel > spell.DamageCap)
    {
        nCasterLevel = spell.DamageCap;
    }
    //Declare the spell shape, size and the location.  Capture the first target object in the shape.
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPELLCONE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);

    //Cycle through the targets within the spell shape until an invalid object is captured.
    while(GetIsObjectValid(oTarget))
    {
        if (oTarget != spell.Caster && spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            //Signal spell cast at event to fire.
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            //Calculate the delay time on the application of effects based on the distance
            //between the caster and the target
            fDist = GetDistanceBetween(spell.Caster, oTarget)/20;
            //Make SR check, and appropriate saving throw.
            if(!MyResistSpell(spell.Caster, oTarget, fDist))
            {
                nDamage = MaximizeOrEmpower(4,nCasterLevel,spell.Meta);
                //Run the damage through the various reflex save and evasion feats
                nDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, spell.DC, spell.SavingThrow, SAVING_THROW_TYPE_FIRE, spell.Caster);
                if(nDamage > 0)
                {
                    eFire = EffectDamage(nDamage, spell.DamageType);
                    // Apply effects to the currently selected target.
                    DelayCommand(fDist, ApplyEffectToObject(DURATION_TYPE_INSTANT, eFire, oTarget));
                    DelayCommand(fDist, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                }
            }
        }
        //Select the next target within the spell shape.
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPELLCONE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }
}
