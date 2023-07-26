//::///////////////////////////////////////////////
//:: Planar Binding
//:: NW_S0_Planar.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Summons an outsider dependant on alignment, or
    holds an outsider if the creature fails a save.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: April 12, 2001
//:://////////////////////////////////////////////
/*
Patch 1.72
- spell wil now fire signal event for non-outsiders too
Patch 1.71
- added saving throw subtype (paralyse)
- added duration scaling per game difficulty
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "inc_general"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDuration = spell.Level;
    effect eSummon;
    effect eGate;
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eDur2 = EffectVisualEffect(VFX_DUR_PARALYZED);
    effect eDur3 = EffectVisualEffect(VFX_DUR_PARALYZE_HOLD);
    effect eLink = EffectLinkEffects(eDur, EffectParalyze());
    eLink = EffectLinkEffects(eLink, eDur2);
    eLink = EffectLinkEffects(eLink, eDur3);

    int nAlign = GetAlignmentGoodEvil(spell.Caster);

    //Check for metamagic extend
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2;   //Duration is +100%
    }
    //Check to make sure a target was selected
    if (GetIsObjectValid(spell.Target))
    {
        if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
        {
            //Check to make sure the target is an outsider
            if(spellsIsRacialType(spell.Target, RACIAL_TYPE_OUTSIDER))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
                //Make a Will save
                if(!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC+2, /*SAVING_THROW_TYPE_PARALYSE*/20, spell.Caster))
                {
                    nDuration = GetScaledDuration(spell.Level/2,spell.Target);
                    //Check for metamagic extend
                    if (spell.Meta & METAMAGIC_EXTEND)
                    {
                        nDuration = nDuration *2;   //Duration is +100%
                    }
                    //Apply the linked effect
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
                }
            }
        }
    }
    else
    {
        //Set the summon effect based on the alignment of the caster
        float fDelay = 3.0;
        switch (nAlign)
        {
            case ALIGNMENT_EVIL:
                eSummon = EffectSummonCreature("sum_succubus",VFX_FNF_SUMMON_GATE, fDelay);
            break;
            case ALIGNMENT_GOOD:
                eSummon = EffectSummonCreature("sum_houndarchon", VFX_FNF_SUMMON_CELESTIAL, fDelay);
            break;
            case ALIGNMENT_NEUTRAL:
                eSummon = EffectSummonCreature("sum_slaadgreen", VFX_FNF_SUMMON_MONSTER_3, 1.0);
            break;
        }
        if (GetIsPC(spell.Caster))
        {
            IncrementPlayerStatistic(spell.Caster, "creatures_summoned");
        }
        //Apply the summon effect and VFX impact
        ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSummon, spell.Loc, HoursToSeconds(nDuration));
    }
}
