//::///////////////////////////////////////////////
//:: Invisibility Sphere
//:: NW_S0_InvSph.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All allies within 15ft are rendered invisible.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:://////////////////////////////////////////////
/*
Patch 1.71

- disabled aura stacking
- moving bug fixed, now caster gains benefit of aura all the time, (cannot guarantee the others,
thats module-related)
*/

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "x0_i0_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_TURNS;
    spell.TargetType = SPELL_TARGET_ALLALLIES;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables including Area of Effect Object
    spellsDeclareMajorVariables();
    effect eAOE = EffectAreaOfEffect(AOE_PER_INVIS_SPHERE);

    effect eInvis = EffectInvisibility(INVISIBILITY_TYPE_NORMAL);
    effect eVis = EffectVisualEffect(VFX_DUR_INVISIBILITY);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    effect eLink = EffectLinkEffects(eInvis, eVis);
    eLink = EffectLinkEffects(eLink, eDur);
    eLink = EffectLinkEffects(eLink, eAOE);
    int nDuration = spell.Level;

    //Check Extend metamagic feat.
    if (spell.Meta & METAMAGIC_EXTEND)
    {
       nDuration = nDuration *2;    //Duration is +100%
    }

    //prevent stacking
    RemoveEffectsFromSpell(spell.Target, spell.Id);

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //Create an instance of the AOE Object using the Apply Effect function
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
    spellsSetupNewAOE("VFX_PER_INVIS_SPHERE");
}

