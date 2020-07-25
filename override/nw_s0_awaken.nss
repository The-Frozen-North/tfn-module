//::///////////////////////////////////////////////
//:: Awaken
//:: NW_S0_Awaken
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This spell makes an animal ally more
    powerful, intelligent and robust for the
    duration of the spell.  Requires the caster to
    make a Will save to succeed.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Aug 10, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- maximized version fixed
- the spell stacked before
*/

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "x0_i0_spells"

void main()
{
    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    effect eStr = EffectAbilityIncrease(ABILITY_STRENGTH, 4);
    effect eCon = EffectAbilityIncrease(ABILITY_CONSTITUTION, 4);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eInt;
    effect eAttack = EffectAttackIncrease(2);
    effect eVis = EffectVisualEffect(VFX_IMP_HOLY_AID);

    if(GetAssociateType(spell.Target) == ASSOCIATE_TYPE_ANIMALCOMPANION && (GetMaster(spell.Target) == spell.Caster || GetIsDM(spell.Caster)))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

        //Enter Metamagic conditions
        int nInt = MaximizeOrEmpower(10,1,spell.Meta);

        eInt = EffectAbilityIncrease(ABILITY_WISDOM, nInt);

        effect eLink = EffectLinkEffects(eStr, eCon);
        eLink = EffectLinkEffects(eLink, eAttack);
        eLink = EffectLinkEffects(eLink, eInt);
        eLink = EffectLinkEffects(eLink, eDur);
        eLink = SupernaturalEffect(eLink);

        RemoveEffectsFromSpell(spell.Target, spell.Id);

        //Apply the VFX impact and effects
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, spell.Target);
    }
    else
    {
        FloatingTextStrRefOnCreature(83384,spell.Caster,FALSE);
    }
}
