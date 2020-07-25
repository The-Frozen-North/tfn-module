//::///////////////////////////////////////////////
//:: Shield of Faith
//:: x0_s0_ShieldFait.nss
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
 +2 deflection AC bonus, +1 every 6 levels (max +5)
 Duration: 1 turn/level
*/
//:://////////////////////////////////////////////
//:: Created By: Brent Knowles
//:: Created On: September 6, 2002
//:://////////////////////////////////////////////
//:: VFX Pass By:
/*
Patch 1.72
- removed the visual effect that was shared with protection against evil (to prevent mistaking these two)
- added "cessate" visual effect (this will run at the end of the duration as a kind of feedback "you just lost some beneficial spell"
Patch 1.70
- did signalized wrong spell ID
*/

#include "70_inc_spells"
#include "x0_i0_spells"
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
    effect eVis = EffectVisualEffect(VFX_IMP_AC_BONUS);
    int nCasterLvl = spell.Level;

    int nValue = 2 + (nCasterLvl)/6;
    if (nValue > spell.Limit)
     nValue = spell.Limit; // * Max of 5

    effect eAC = EffectACIncrease(nValue, AC_DEFLECTION_BONUS);

    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eAC, eDur);

    int nDuration = spell.Level; // * Duration 1 turn/level
    if (spell.Meta & METAMAGIC_EXTEND)    //Duration is +100%
    {
         nDuration = nDuration * 2;
    }

    //Fire spell cast at event for target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //Apply VFX impact and bonus effects
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
}
