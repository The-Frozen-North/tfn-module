//::///////////////////////////////////////////////
//:: Flame Lash
//:: NW_S0_FlmLash.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creates a whip of fire that targets a single
    individual
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 21, 2001
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageType = DAMAGE_TYPE_FIRE;
    spell.Dice = 6;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nCasterLevel = spell.Level;

    if(nCasterLevel > 3)
    {
        nCasterLevel = (nCasterLevel-3)/3;
    }
    else
    {
        nCasterLevel = 0;
    }
    int nDamage = MaximizeOrEmpower(spell.Dice,2 + nCasterLevel,spell.Meta);

    effect eVis = EffectVisualEffect(spell.DmgVfxS);
    effect eRay = EffectBeam(VFX_BEAM_FIRE_LASH, spell.Caster, BODY_NODE_HAND);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRay, spell.Target, 1.7);

    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        if (!MyResistSpell(spell.Caster, spell.Target, 1.0))
        {
            nDamage = GetSavingThrowAdjustedDamage(nDamage, spell.Target, spell.DC, spell.SavingThrow, spell.SaveType, spell.Caster);
            effect eDam = EffectDamage(nDamage, spell.DamageType);
            if(nDamage > 0)
            {
                //Apply the VFX impact and effects
                DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target));
                DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target));
            }
        }
    }
}
