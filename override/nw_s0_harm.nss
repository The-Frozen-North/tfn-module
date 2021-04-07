//::///////////////////////////////////////////////
//:: [Harm]
//:: [NW_S0_Harm.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Reduces target to 1d4 HP on successful touch
//:: attack.  If the target is undead it is healed.
//:://////////////////////////////////////////////
//:: Created By: Keith Soleski
//:: Created On: Jan 18, 2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 20, 2001
//:: Update Pass By: Preston W, On: Aug 1, 2001
//:: Last Update: Georg Zoeller On: Oct 10, 2004
//:://////////////////////////////////////////////
/*
Patch 1.72
- touch attack will be skipped in case target is a caster himself
Patch 1.70
- touch attack removed if cast on undead (roll wasn't used in this case anyway)
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageType = DAMAGE_TYPE_NEGATIVE;
    spell.SavingThrow = SAVING_THROW_NONE;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDamage, nHeal;
    effect eVis = EffectVisualEffect(VFX_IMP_HARM);
    effect eVis2 = EffectVisualEffect(VFX_IMP_HEALING_G);
    effect eHeal, eDam;
    //Check that the target is undead
    if (spellsIsRacialType(spell.Target, RACIAL_TYPE_UNDEAD))
    {
        //Figure out the amount of damage to heal
        nHeal = GetMaxHitPoints(spell.Target) - GetCurrentHitPoints(spell.Target);
        //Set the heal effect
        eHeal = EffectHeal(nHeal);
        //Apply heal effect and VFX impact
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, spell.Target);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, spell.Target);
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    }
    else if (spell.Target == spell.Caster || TouchAttackMelee(spell.Target) != FALSE)  //GZ: Fixed boolean check to work in NWScript. 1 or 2 are valid return numbers from TouchAttackMelee
    {
        if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, SPELL_HARM));
            if (!MyResistSpell(spell.Caster, spell.Target))
            {
                nDamage = GetCurrentHitPoints(spell.Target) - d4(1);
                //Check for metamagic
                if (spell.Meta & METAMAGIC_MAXIMIZE)
                {
                    nDamage = GetCurrentHitPoints(spell.Target) - 1;
                }
                //1.72: this will do nothing by default, but allows to dynamically enforce saving throw
                if(MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, spell.SaveType, spell.Caster))
                {
                    nDamage/= 2;
                }
                eDam = EffectDamage(nDamage,spell.DamageType);
                //Apply the VFX impact and effects
                DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
            }
        }
    }
}
