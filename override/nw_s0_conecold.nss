//::///////////////////////////////////////////////
//:: Cone of Cold
//:: NW_S0_ConeCold
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// Cone of cold creates an area of extreme cold,
// originating at your hand and extending outward
// in a cone. It drains heat, causing 1d6 points of
// cold damage per caster level (maximum 15d6).
*/
//:://////////////////////////////////////////////
//:: Created By: Noel Borstad
//:: Created On: 10/18/02000
//:://////////////////////////////////////////////
//:: Last Updated By: Aidan Scanlan On: April 11, 2001
//:: Update Pass By: Preston W, On: July 25, 2001
/*
Patch 1.70

- fixed self targetting which could happen in specific circumstances
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageCap = 15;
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_COLD;
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
    int nCasterLevel = spell.Level;
    int nDamage;
    float fDelay;
    effect eCold, eVis = EffectVisualEffect(spell.DmgVfxL);
    //Limit Caster level for the purposes of damage.
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
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            //Get the distance between the target and caster to delay the application of effects
            fDelay = GetDistanceBetween(spell.Caster, oTarget)/20.0;
            //Make SR check, and appropriate saving throw(s).
            if(!MyResistSpell(spell.Caster, oTarget, fDelay))
            {
                //Detemine damage
                nDamage = MaximizeOrEmpower(spell.Dice,nCasterLevel,spell.Meta);
                //Adjust damage according to Reflex Save, Evasion or Improved Evasion
                nDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, spell.DC, spell.SavingThrow, spell.SaveType, spell.Caster);
                if(nDamage > 0)
                {
                    eCold = EffectDamage(nDamage, spell.DamageType);
                    // Apply effects to the currently selected target.
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eCold, oTarget));
                }
            }
        }
        //Select the next target within the spell shape.
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPELLCONE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }
}
