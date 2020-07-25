//::///////////////////////////////////////////////
//:: Lesser Restoration
//:: NW_S0_LsRestor.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Removes all supernatural effects related to ability
    damage, as well as AC, Damage,
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:://////////////////////////////////////////////
/*
Patch 1.72
- restoration doesn't remove horse related effects
Patch 1.71
- restoration doesn't remove effects of rage anymore (all rage variants)
*/

#include "70_inc_spells"
#include "x2_inc_spellhook"

// return TRUE if the effect created by a supernatural force and can't be dispelled by spells
int GetIsSupernaturalCurse(effect eEff);

void main()
{
    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVisual = EffectVisualEffect(VFX_IMP_RESTORATION_LESSER);
    effect eBad = GetFirstEffect(spell.Target);
    //Search for negative effects
    while(GetIsEffectValid(eBad))
    {
        switch(GetEffectType(eBad))
        {
            case EFFECT_TYPE_ABILITY_DECREASE:
            case EFFECT_TYPE_AC_DECREASE:
            case EFFECT_TYPE_ATTACK_DECREASE:
            case EFFECT_TYPE_DAMAGE_DECREASE:
            case EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE:
            case EFFECT_TYPE_SAVING_THROW_DECREASE:
            case EFFECT_TYPE_SPELL_RESISTANCE_DECREASE:
            case EFFECT_TYPE_SKILL_DECREASE:
            //Remove effect if it is negative.
            if(!GetIsSupernaturalCurse(eBad))
                RemoveEffect(spell.Target, eBad);
            break;
        }
        eBad = GetNextEffect(spell.Target);
    }
    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, spell.Target);
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
