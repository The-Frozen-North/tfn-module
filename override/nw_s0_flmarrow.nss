//::///////////////////////////////////////////////
//:: Flame Arrow
//:: NW_S0_FlmArrow
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Fires a stream of fiery arrows at the selected
    target that do 4d6 damage per arrow.  1 Arrow
    per 4 levels is created.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Sept 20, 2001
//:: Updated By: Georg Zoeller, Aug 18 2003: Uncapped
//:://////////////////////////////////////////////
/*
Patch 1.71

- the extra point of damage removed to match description
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_FIRE;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables  ( fDist / (3.0f * log( fDist ) + 2.0f) )
    spellsDeclareMajorVariables();
    int nDamage = 0;
    int nCnt;
    effect eMissile;
    effect eVis = EffectVisualEffect(spell.DmgVfxS);
    int nMissiles = (spell.Level)/4;
    float fDist = GetDistanceBetween(spell.Caster, spell.Target);
    float fDelay = fDist/(3.0 * log(fDist) + 2.0);
    //Limit missiles to five
    if(nMissiles == 0)
    {
        nMissiles = 1;
    }
    /* Uncapped because PHB does list any cap and we now got epic levels
    else if (nMissiles > 5)
    {
        nMissiles = 5;
    }*/
    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //Apply a single damage hit for each missile instead of as a single mass
        //Make SR Check
        for (nCnt = 1; nCnt <= nMissiles; nCnt++)
        {
            if(!MyResistSpell(spell.Caster, spell.Target, fDelay))
            {
                //Roll damage
                int nDam = MaximizeOrEmpower(spell.Dice,4,spell.Meta);

                nDam = GetSavingThrowAdjustedDamage(nDam, spell.Target, spell.DC, spell.SavingThrow, spell.SaveType, spell.Caster);
                //Set damage effect
                effect eDam = EffectDamage(nDam, spell.DamageType);
                //Apply the MIRV and damage effect
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, spell.Target));

            }
            // * May 2003: Make it so the arrow always appears, even if resisted
            eMissile = EffectVisualEffect(VFX_IMP_MIRV_FLAME);
           ApplyEffectToObject(DURATION_TYPE_INSTANT, eMissile, spell.Target);
        }
    }
}
