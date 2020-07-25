//::///////////////////////////////////////////////
//:: [Power Word Stun]
//:: [NW_S0_PWStun.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The creature is stunned for a certain number of
    rounds depending on its HP.  No save.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Feb 4, 2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 22, 2001

/*
bugfix by Kovi 2002.07.28
- =151HP stunned for 4d4 rounds
- >151HP sometimes stunned for indefinit duration
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nHP =  GetCurrentHitPoints(spell.Target);
    effect eStun = EffectStunned();
    effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eLink = EffectLinkEffects(eMind, eStun);
    effect eVis = EffectVisualEffect(VFX_IMP_STUN);
    effect eWord = EffectVisualEffect(VFX_FNF_PWSTUN);
    int nDuration;
    int nDice, nNumDice;
    //Apply the VFX impact
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eWord, spell.Loc);
    //Determine the number rounds the creature will be stunned
    if (nHP >= 151)
    {
        nNumDice = 0;
        nDice = 0;
    }
    else if (nHP >= 101 && nHP <= 150)
    {
        nNumDice = 1;
        nDice = 4;
    }
    else if (nHP >= 51  && nHP <= 100)
    {
        nNumDice = 2;
        nDice = 8;
    }
    else
    {
        nNumDice = 4;
        nDice = 16;
    }

    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //Make an SR check
        if(!MyResistSpell(spell.Caster, spell.Target))
        {
            if (nDice>0)
            {
                nDuration = MaximizeOrEmpower(nDice,nNumDice,spell.Meta);
                //Apply linked effect and the VFX impact
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
            }
        }
    }
}
