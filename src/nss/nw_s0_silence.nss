//::///////////////////////////////////////////////
//:: Silence
//:: NW_S0_Silence.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The target is surrounded by a zone of silence
    that allows them to move without sound.  Spell
    casters caught in this area will be unable to cast
    spells.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:://////////////////////////////////////////////
/*
Patch 1.72
- SpellCastAt event was signaled after spell resist check
Patch 1.71
- disabled aura stacking
- if cast on ally the effect bypass spell resistance/immunity properly
- moving bug fixed, now caster gains benefit of aura all the time, (cannot guarantee the others,
thats module-related)
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables including Area of Effect Object
    spellsDeclareMajorVariables();

    effect eAOE = EffectAreaOfEffect(AOE_MOB_SILENCE);
    effect eVis = EffectVisualEffect(VFX_DUR_AURA_SILENCE);
    effect eDur2 = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eSilence = EffectSilence();
    effect eImmune = EffectDamageImmunityIncrease(DAMAGE_TYPE_SONIC, 100);

    effect eLink = EffectLinkEffects(eDur2, eSilence);
    eLink = EffectLinkEffects(eLink, eImmune);
    eLink = EffectLinkEffects(eLink, eVis);
    eLink = EffectLinkEffects(eLink, eAOE);

    int nDuration = spell.Level;
    //Check Extend metamagic feat.
    if(spell.Meta & METAMAGIC_EXTEND)
    {
       nDuration = nDuration *2;    //Duration is +100%
    }

    if(!GetIsFriend(spell.Target))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //Make a SR check
        if(!MyResistSpell(spell.Caster, spell.Target))
        {
            if(!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_NONE, spell.Caster))
            {
                //prevent stacking
                RemoveEffectsFromSpell(spell.Target, spell.Id);
                //Create an instance of the AOE Object using the Apply Effect function
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
                spellsSetupNewAOE("VFX_MOB_SILENCE");
            }
        }
    }
    else
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
        //prevent stacking
        RemoveEffectsFromSpell(spell.Target, spell.Id);
        //Create an instance of the AOE Object using the Apply Effect function
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
        spellsSetupNewAOE("VFX_MOB_SILENCE");
    }
}
