//::///////////////////////////////////////////////
//:: Negative Energy Ray
//:: NW_S0_NegRay
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Fires a bolt of negative energy at the target
    doing 1d6 damage.  Does an additional 1d6
    damage for 2 levels after level 1 (3,5,7,9) to
    a maximum of 5d6 at level 9.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Sept 13, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- ray VFX didn't appeared at friendly targets on low difficulty
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_NEGATIVE;
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nCasterLevel = spell.Level;

    if(nCasterLevel > 9)
    {
        nCasterLevel = 9;
    }
    nCasterLevel = (nCasterLevel + 1) / 2;
    int nDamage = MaximizeOrEmpower(spell.Dice,nCasterLevel,spell.Meta);

    effect eVis = EffectVisualEffect(spell.DmgVfxS);
    effect eVisHeal = EffectVisualEffect(VFX_IMP_HEALING_M);
    effect eRay = EffectBeam(VFX_BEAM_EVIL, spell.Caster, BODY_NODE_HAND);
    if(!spellsIsRacialType(spell.Target, RACIAL_TYPE_UNDEAD))
    {
        if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
            if (!MyResistSpell(spell.Caster, spell.Target))
            {
                //Make a will saving throw check
                if(MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, spell.SaveType, spell.Caster))
                {
                    nDamage /= 2;
                }
                effect eDam = EffectDamage(nDamage, spell.DamageType);
                //Apply the VFX impact and effects
                //DelayCommand(0.5, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target));
                DelayCommand(0.5, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target);
            }
        }
    }
    else
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
        effect eHeal = EffectHeal(nDamage);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisHeal, spell.Target);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, spell.Target);
    }
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRay, spell.Target, 1.7);
}
