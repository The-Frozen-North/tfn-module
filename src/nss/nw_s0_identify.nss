//::///////////////////////////////////////////////
//:: Identify
//:: NW_S0_Identify.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Gives the caster a boost to Lore skill of +25
    plus caster level.  Lasts for 2 rounds.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 22, 2001
//:://////////////////////////////////////////////
/*
Patch 1.72
- added custom content support when the spell is modified to cast on item instead
of caster, in such case the spell will identify targetted item without any check
Patch 1.71
- the spell couldn't be recast if caster had also legend lore effect
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
    int nBonus = 10 + spell.Level;
    effect eLore = EffectSkillIncrease(SKILL_LORE, nBonus);
    effect eVis = EffectVisualEffect(VFX_IMP_MAGICAL_VISION);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eVis, eDur);
    eLink = EffectLinkEffects(eLink, eLore);

    int nDuration = 2;

    //Meta-Magic checks
    if(spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = 4;
    }

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    //Apply linked and VFX effects
    if(GetObjectType(spell.Target) == OBJECT_TYPE_ITEM)
    {
        if(!GetLocalInt(spell.Target,"72_DISSALOW_IDENTIFY"))
        {
            SetIdentified(spell.Target,TRUE);
        }
        spell.Target = spell.Caster;//a small hack to ensure visual will run on caster
    }
    else
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
    }
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
}
