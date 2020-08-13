//::///////////////////////////////////////////////
//:: Freedom of Movement
//:: NW_S0_FreeMove.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The target creature gains immunity to the
    Entangle, Slow and Paralysis effects
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 29, 2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 21, 2001

#include "70_inc_spells"
#include "x2_inc_spellhook"

// return TRUE if the effect created by a supernatural force and can't be dispelled by spells
int GetIsSupernaturalCurse(effect eEff);

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_TURNS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDuration = spell.Level;
    effect eParal = EffectImmunity(IMMUNITY_TYPE_PARALYSIS);
    effect eEntangle = EffectImmunity(IMMUNITY_TYPE_ENTANGLE);
    effect eSlow = EffectImmunity(IMMUNITY_TYPE_SLOW);
    effect eMove = EffectImmunity(IMMUNITY_TYPE_MOVEMENT_SPEED_DECREASE);
    effect eVis = EffectVisualEffect(VFX_DUR_FREEDOM_OF_MOVEMENT);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    //Link effects
    effect eLink = EffectLinkEffects(eParal, eEntangle);
    eLink = EffectLinkEffects(eLink, eSlow);
    eLink = EffectLinkEffects(eLink, eVis);
    eLink = EffectLinkEffects(eLink, eDur);
    eLink = EffectLinkEffects(eLink, eMove);

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    //Search for and remove the above negative effects
    effect eLook = GetFirstEffect(spell.Target);
    while(GetIsEffectValid(eLook))
    {
        switch(GetEffectType(eLook))
        {
            case EFFECT_TYPE_PARALYZE:
            case EFFECT_TYPE_ENTANGLE:
            case EFFECT_TYPE_SLOW:
            case EFFECT_TYPE_MOVEMENT_SPEED_DECREASE:
            if(!GetIsSupernaturalCurse(eLook))
                RemoveEffect(spell.Target, eLook);
            break;
        }
        eLook = GetNextEffect(spell.Target);
    }
    //Meta-Magic Checks
    if(spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration *= 2;
    }
    //Apply Linked Effect
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
}

int GetIsSupernaturalCurse(effect eEff)
{
    switch(GetEffectSpellId(eEff))
    {
        case 247: case 248: case 249: //ferocity
        case 273: case 274: case 275: //intensity
        case 299: case 300: case 301: //rage
        case SPELLABILITY_BARBARIAN_RAGE:
        case SPELLABILITY_EPIC_MIGHTY_RAGE:
        case SPELL_BLOOD_FRENZY:
        return TRUE;
    }
    string sTag = GetTag(GetEffectCreator(eEff));
    return sTag == "q6e_ShaorisFellTemple" || sTag == "X3_EC_HORSE";
}
