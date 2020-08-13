//::///////////////////////////////////////////////
//:: Mestil's Acid Breath
//:: X2_S0_AcidBrth
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// You breathe forth a cone of acidic droplets. The
// cone inflicts 1d6 points of acid damage per caster
// level (maximum 10d6).
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov, 22 2002
//:://////////////////////////////////////////////
/*
Patch 1.70

- cone could in certain circumstances affect caster
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageCap = 10;
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_ACID;
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
        if(oTarget != spell.Caster && spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
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

                // Apply effects to the currently selected target.
                effect eAcid = EffectDamage(nDamage, spell.DamageType);
                effect eVis = EffectVisualEffect(spell.DmgVfxL);
                if(nDamage > 0)
                {
                    //Apply delayed effects
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eAcid, oTarget));
                }
            }
        }
        //Select the next target within the spell shape.
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPELLCONE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }
}
