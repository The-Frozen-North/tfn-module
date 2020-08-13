//::///////////////////////////////////////////////
//:: Psionic Inertial Barrier
//:: x2_s1_psibarr.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*

    Caster gains Damage Reduction that absorbs
    10 points of damage per hit die and lasts
    1 round per hit die

    damage power is +20 for illithids and
    shifter level /3

    Reduction is 10 + some amount per level

    Used by illithids and shifters
*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: Sept 2003
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_inc_spellhook"

void main()
{
    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDuration, nDamagePower, nReduction;
    if (!GetIsPC(spell.Caster))
    {
        nDuration = GetHitDice(spell.Caster);
        nDamagePower = DAMAGE_POWER_PLUS_TWENTY;
    }
    else // shifter
    {
        nDuration = (GetLevelByClass(CLASS_TYPE_SHIFTER,spell.Caster)/3) +1;
        nDamagePower = IPGetDamagePowerConstantFromNumber(nDuration);
    }
    nReduction = nDuration/2;
    if(nReduction < 10)
    {
        nReduction = 10;
    }

    effect eVis = EffectVisualEffect(VFX_DUR_GHOSTLY_VISAGE);
    effect eDam = EffectDamageReduction(nReduction, nDamagePower , nDuration*10);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eDam, eVis);
    eLink = EffectLinkEffects(eLink, eDur);
    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    effect eImpact = EffectVisualEffect(VFX_IMP_AC_BONUS);

    //Apply the VFX impact and effects
    if (!GetHasSpellEffect(GetSpellId(),spell.Target))
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, RoundsToSeconds(nDuration));
    }
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, spell.Target);
}
