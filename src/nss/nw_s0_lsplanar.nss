//::///////////////////////////////////////////////
//:: Lesser Planar Binding
//:: NW_S0_LsPlanar.nss
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
//:: VFX Pass By: Preston W, On: June 20, 2001
/*
Patch 1.71

- added saving throw subtype (paralyse)
- added missing saving throw VFX
- added duration scaling per game difficulty
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

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

    //Check for metamagic extend
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2;   //Duration is +100%
    }
    //Check to see if the target is valid
    if (GetIsObjectValid(spell.Target))
    {
        if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
            //Check to make sure the target is an outsider
            if(spellsIsRacialType(spell.Target, RACIAL_TYPE_OUTSIDER))
            {
                //Make a will save
                if(!MySavingThrow(spell.SavingThrow,spell.Target,spell.DC,/*SAVING_THROW_TYPE_PARALYSE*/20,spell.Caster))
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
        //Get the alignment of the caster
        int nAlign = GetAlignmentGoodEvil(spell.Caster);
        float fDelay = 3.0;
        switch (nAlign)
        {
            //Set the summon effect based on alignment
            case ALIGNMENT_EVIL:
                {
                    eSummon = EffectSummonCreature("sum_imp",VFX_FNF_SUMMON_GATE , fDelay);
                }
            break;
            case ALIGNMENT_GOOD:
                {
                    eSummon = EffectSummonCreature("sum_lantern", 219 ,fDelay);
                }
            break;
            case ALIGNMENT_NEUTRAL:
                {
                    eSummon = EffectSummonCreature("sum_slaad", VFX_FNF_SUMMON_MONSTER_3);
                }
            break;
        }
        //Apply the summon effect and the VFX impact
        ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSummon, spell.Loc, HoursToSeconds(nDuration));
    }
}
