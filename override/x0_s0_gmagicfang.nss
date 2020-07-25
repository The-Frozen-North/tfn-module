//::///////////////////////////////////////////////
//:: Greater Magic Fang
//:: x0_s0_gmagicfang.nss
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
 +1 enhancement bonus to attack and damage rolls.
 Also applys damage reduction +1; this allows the creature
 to strike creatures with +1 damage reduction.

 Checks to see if a valid summoned monster or animal companion
 exists to apply the effects to. If none exists, then
 the spell is wasted.

*/
//:://////////////////////////////////////////////
//:: Created By: Brent Knowles
//:: Created On: September 6, 2002
//:://////////////////////////////////////////////
//:: VFX Pass By:

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
    object oTarget = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION,spell.Caster);

    if (!GetIsObjectValid(oTarget))
    {
            FloatingTextStrRefOnCreature(8962, spell.Caster, FALSE);
            return; // has neither an animal companion
    }

    int nCasterLevel = spell.Level;
    int nPower = (nCasterLevel + 1) / 3;
    if (nPower > spell.Limit)
     nPower = spell.Limit;  // * max of +5 bonus
    int nDamagePower = DAMAGE_POWER_PLUS_ONE;

    switch (nPower)
    {
        case 1: nDamagePower = DAMAGE_POWER_PLUS_ONE; break;
        case 2: nDamagePower = DAMAGE_POWER_PLUS_TWO; break;
        case 3: nDamagePower = DAMAGE_POWER_PLUS_THREE; break;
        case 4: nDamagePower = DAMAGE_POWER_PLUS_FOUR; break;
        case 5: nDamagePower = DAMAGE_POWER_PLUS_FIVE; break;
        default: nDamagePower = nPower+1; break;//support for modification of spell limit
    }

    //Remove effects of anyother fang spells
    RemoveSpellEffects(SPELL_MAGIC_FANG, spell.Caster, oTarget);
    RemoveSpellEffects(spell.Id, spell.Caster, oTarget);

    effect eVis = EffectVisualEffect(VFX_IMP_HOLY_AID);

    effect eAttack = EffectAttackIncrease(nPower);
    effect eDamage = EffectDamageIncrease(nPower, DAMAGE_TYPE_MAGICAL);
    effect eReduction = EffectDamageReduction(nPower, nDamagePower); // * doing this because
                                                                     // * it creates a true
                                                                     // * enhancement bonus

    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eAttack, eDur);
    eLink = EffectLinkEffects(eLink, eDamage);
    eLink = EffectLinkEffects(eLink, eReduction);

    int nDuration = spell.Level; // * Duration 1 turn/level
    if (spell.Meta & METAMAGIC_EXTEND)    //Duration is +100%
    {
         nDuration = nDuration * 2;
    }

    //Fire spell cast at event for target
    SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //Apply VFX impact and bonus effects
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, DurationToSeconds(nDuration));
}
