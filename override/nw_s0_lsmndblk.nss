//::///////////////////////////////////////////////
//:: Lesser Mind Blank
//:: NW_S0_LsMndBlk.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The target is given complete protection
    from all mental effects.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
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
    effect eImm1 = EffectImmunity(IMMUNITY_TYPE_MIND_SPELLS);
    effect eVis = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_POSITIVE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    effect eLink = EffectLinkEffects(eImm1, eVis);
    eLink = EffectLinkEffects(eLink, eDur);
    int bValid;
    int nDuration = spell.Level;
    //Enter Metamagic conditions
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2; //Duration is +100%
    }

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    effect eSearch = GetFirstEffect(spell.Target);
    //Search through effects
    while(GetIsEffectValid(eSearch))
    {
        bValid = FALSE;
        //Check to see if the effect matches a particular type defined below
        switch(GetEffectType(eSearch))
        {
        case EFFECT_TYPE_DAZED:
        case EFFECT_TYPE_CHARMED:
        case EFFECT_TYPE_SLEEP:
        case EFFECT_TYPE_CONFUSED:
        case EFFECT_TYPE_STUNNED:
        case EFFECT_TYPE_DOMINATED:
        bValid = TRUE;
        break;
        default:
         switch(GetEffectSpellId(eSearch))
         {
         case SPELL_FEEBLEMIND:
         case SPELL_BANE:
         bValid = TRUE;
         break;
         }
        break;
        }

        //Apply damage and remove effect if the effect is a match
        if(bValid && !GetIsSupernaturalCurse(eSearch))
        {
        RemoveEffect(spell.Target,eSearch);
        }
        eSearch = GetNextEffect(spell.Target);
    }

    //After effects are removed we apply the immunity to mind spells to the target
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
