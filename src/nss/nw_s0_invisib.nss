//::///////////////////////////////////////////////
//:: Invisibility
//:: NW_S0_Invisib.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Target creature becomes invisibility
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    //effect eVis = EffectVisualEffect(VFX_DUR_INVISIBILITY);
    effect eInvis = EffectInvisibility(INVISIBILITY_TYPE_NORMAL);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    effect eLink = EffectLinkEffects(eInvis, eDur);
    //eLink = EffectLinkEffects(eLink, eVis);

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    int nDuration = spell.Level;
    //Enter Metamagic conditions
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2; //Duration is +100%
    }

    int nInvis = GetLocalInt(spell.Target, "invis");

    float fDuration = DurationToSeconds(nDuration);

    if (nInvis == 1)
    {
        FloatingTextStringOnCreature("*Your invisibility has 50% duration.*", spell.Target);
        fDuration = fDuration * 0.50;
    }
    else if (nInvis >= 2)
    {
        FloatingTextStringOnCreature("*Your invisibility has 25% duration.*", spell.Target);
        fDuration = fDuration * 0.25;
    }


    SetLocalInt(spell.Target, "invis", nInvis+1);

    //Apply the VFX impact and effects
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, fDuration);
}
