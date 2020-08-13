//::///////////////////////////////////////////////
//:: Truestrike
//:: x0_s0_truestrike.nss
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
+20 attack bonus for 9 seconds.
CHANGE: Miss chance still applies, unlike rules.
*/
//:://////////////////////////////////////////////
//:: Created By: Brent Knowles
//:: Created On: July 15, 2002
//:://////////////////////////////////////////////
//:: VFX Pass By:

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_SECONDS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_IMP_HEAD_ODD);

    // * determine the damage bonus to apply
    effect eAttack = EffectAttackIncrease(20);

    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eAttack, eDur);

    //Fire spell cast at event for target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    //Apply VFX impact and bonus effects
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(9));
}
