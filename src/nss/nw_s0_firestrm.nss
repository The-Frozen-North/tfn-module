//::///////////////////////////////////////////////
//:: Fire Storm
//:: NW_S0_FireStm
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creates a zone of destruction around the caster
    within which all living creatures are pummeled
    with fire.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: April 11, 2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 21, 2001
/*
Patch 1.72
- fixed bug that prevented the spell to target placeables and doors
Patch 1.70
- capped at lvl 20
- damage values were always even
- fixed special case where target wasn't damaged at all
*/
#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageCap = 20;
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_FIRE;
    spell.Range = RADIUS_SIZE_COLOSSAL;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_SELECTIVEHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDamage, nDamage1, nDamage2;
    int nCasterLevel = spell.Level;
    if(nCasterLevel > spell.DamageCap)
    {
        nCasterLevel = spell.DamageCap;
    }
    effect eVis = EffectVisualEffect(spell.DmgVfxL);
    effect eFireStorm = EffectVisualEffect(VFX_FNF_FIRESTORM);
    float fDelay;
    //Apply Fire and Forget Visual in the area;
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eFireStorm, spell.Loc);
    //Declare the spell shape, size and the location.  Capture the first target object in the shape.
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while(GetIsObjectValid(oTarget))
    {
        //This spell smites everyone who is more than 2 meters away from the caster.
        //if (GetDistanceBetween(oTarget, OBJECT_SELF) > 2.0)
        //{
            if (oTarget != spell.Caster && spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
            {
                fDelay = GetRandomDelay(1.5, 2.5);
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
                //Make SR check, and appropriate saving throw(s).
                if (!MyResistSpell(spell.Caster, oTarget, fDelay))
                {
                    //Roll Damage
                    nDamage = MaximizeOrEmpower(spell.Dice,nCasterLevel,spell.Meta);
                    //first save for the divine part of the damage
                    nDamage2 = GetSavingThrowAdjustedDamage(nDamage/2, oTarget, spell.DC, spell.SavingThrow, SAVING_THROW_TYPE_DIVINE, spell.Caster);
                    if(nDamage2 > 0)
                    {   //if failed in saving throw, apply divine damage
                        effect eDivine = EffectDamage(nDamage2, DAMAGE_TYPE_DIVINE);
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDivine, oTarget));
                    }
                    //second save for the fire part of the damage
                    nDamage1 = GetSavingThrowAdjustedDamage((nDamage+1)/2, oTarget, spell.DC, spell.SavingThrow, spell.SaveType, spell.Caster);
                    if(nDamage1 > 0)
                    {   //if failed in saving throw, apply fire damage
                        effect eFire = EffectDamage(nDamage1, spell.DamageType);
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eFire, oTarget));
                    }
                    //if at least one of the save failed, apply fire visual effect, but only once
                    if(nDamage1+nDamage2 > 0)
                    {
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                    }
                }
            //}
        }
        //Select the next target within the spell shape.
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }
}
