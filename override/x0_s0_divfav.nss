//::///////////////////////////////////////////////
//:: Bless
//:: x0_s0_divfav.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
+1 bonus to attack and damage for every three
caster levels (+1 to max +5)  \
NOTE: Official rules say +6, we can only go to +5
 Duration: 1 turn
*/
//:://////////////////////////////////////////////
//:: Created By: Brent Knowles
//:: Created On: July 15, 2002
//:://////////////////////////////////////////////
//:: VFX Pass By:

#include "70_inc_spells"
#include "nw_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_TURNS;
    spell.Limit = 5;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_IMP_HEAD_HOLY);
    effect eImpact = EffectVisualEffect(VFX_FNF_LOS_HOLY_30);

    int nScale = spell.Level / 3;
    // * must fall between +1 and +5
    if (nScale < 1)
        nScale = 1;
    else
    if (nScale > spell.Limit)
        nScale = spell.Limit;
    // * determine the damage bonus to apply
    effect eAttack = EffectAttackIncrease(nScale);
    effect eDamage = EffectDamageIncrease(nScale, DAMAGE_TYPE_MAGICAL);


    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eAttack, eDamage);
    eLink = EffectLinkEffects(eLink, eDur);

    int nDuration = 1; // * Duration 1 turn
    if ( spell.Meta & METAMAGIC_EXTEND )
    {
        nDuration = nDuration * 2;
    }

    //Apply Impact
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);

    //Fire spell cast at event for target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //Apply VFX impact and bonus effects
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
}
