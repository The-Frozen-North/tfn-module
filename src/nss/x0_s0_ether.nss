//::///////////////////////////////////////////////
//:: Etherealness
//:: x0_s0_ether.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Like sanctuary except almost always guaranteed
    to work.
    Lasts one turn per level.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:://////////////////////////////////////////////
/*
Patch 1.72

- fixed duration declaration so it now works with spell overrides
*/

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
    effect eVis = EffectVisualEffect(VFX_DUR_SANCTUARY);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eSanc = EffectEthereal();

    effect eLink = EffectLinkEffects(eVis, eSanc);
    eLink = EffectLinkEffects(eLink, eDur);

    int nDuration = spell.Level;
    //Enter Metamagic conditions
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2; //Duration is +100%
    }

    int nGsanc = GetLocalInt(spell.Target, "gsanc");

    float fDuration = DurationToSeconds(nDuration);

    if (nGsanc == 1)
    {
        FloatingTextStringOnCreature("*Your greater sanctuary has 50% duration.*", spell.Target);
        fDuration = fDuration * 0.50;
    }
    else if (nGsanc >= 2)
    {
        FloatingTextStringOnCreature("*Your greater sanctuary has 25% duration.*", spell.Target);
        fDuration = fDuration * 0.25;
    }

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //Apply the VFX impact and effects
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, fDuration);
}
