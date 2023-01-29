//::///////////////////////////////////////////////
//:: Divine Power
//:: NW_S0_DivPower.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Improves the Clerics attack to be the
    equivalent of a Fighter's BAB of the same level,
    +1 HP per level and raises their strength to
    18 if is not already there.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 21, 2001
//:://////////////////////////////////////////////
/*
bugfix by Kovi 2002.07.22
- temporary hp was stacked
- loosing temporary hp resulted in loosing the other bonuses
- number of attacks was not increased (should have been a BAB increase)
still problem:
~ attacks are better still approximation (the additional attack is at full BAB)
~ attack/ability bonuses count against the limits

Patch 1.71

- was removing temporary hitpoits even from other sources
- the strength increase will always be calculated from base strength
*/

#include "70_inc_spells"
#include "nw_i0_spells"
#include "x2_inc_spellhook"
#include "inc_spells"

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

    RemoveEffectsFromSpell(spell.Target, spell.Id);

    int nCasterLevel = spell.Level;
    int nTotalCharacterLevel = GetHitDice(spell.Caster);
    int nBAB = GetBaseAttackBonus(spell.Caster);
    int nEpicPortionOfBAB = (nTotalCharacterLevel - 19)/2;

    if (nEpicPortionOfBAB < 0)
    {
        nEpicPortionOfBAB = 0;
    }

    int nExtraAttacks = 0;
    int nAttackIncrease = 0;

    if (nTotalCharacterLevel > 20 )
    {
        nAttackIncrease = 20 + nEpicPortionOfBAB;
        if(nBAB - nEpicPortionOfBAB < 11)
        {
            nExtraAttacks = 2;
        }
        else if(nBAB - nEpicPortionOfBAB > 10 && nBAB - nEpicPortionOfBAB < 16)
        {
            nExtraAttacks = 1;
        }
    }
    else
    {
        nAttackIncrease = nTotalCharacterLevel;
        nExtraAttacks = ((nTotalCharacterLevel - 1)/5) - ((nBAB - 1)/5);
    }
    nAttackIncrease -= nBAB;

    if (nAttackIncrease < 0)
    {
        nAttackIncrease = 0;
    }

    int nStrengthIncrease = 18-GetAbilityScore(spell.Target, ABILITY_STRENGTH, TRUE);

    effect eVis = EffectVisualEffect(VFX_IMP_SUPER_HEROISM);
    effect eStrength = EffectAbilityIncrease(ABILITY_STRENGTH, nStrengthIncrease);
    effect eHP = EffectTemporaryHitpoints(nCasterLevel);
    effect eAttack = EffectAttackIncrease(nAttackIncrease);
    effect eAttackMod = EffectModifyAttacks(nExtraAttacks);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eAttack, eAttackMod);
    eLink = EffectLinkEffects(eLink, eDur);

    //Make sure that the strength modifier is a bonus
    if(nStrengthIncrease > 0)
    {
        eLink = EffectLinkEffects(eLink, eStrength);
    }

    //Meta-Magic
    if(spell.Meta & METAMAGIC_EXTEND)
    {
        nCasterLevel *= 2;
    }

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));


// divine favor does not stack with this
    DisplaceSpell(spell.Target, SPELL_DIVINE_FAVOR, "Divine Favor");

    //Apply Link and VFX effects to the target
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nCasterLevel));
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eHP, spell.Target, DurationToSeconds(nCasterLevel));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
}
