//::///////////////////////////////////////////////
//:: Undeath's Eternal Foe
//:: x0_s0_udetfoe.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Grants many protections against undead
    to allies in a small area
    of effect (everyone gets negative energy protection)
    immunity to poison and disease too
    +4 AC bonus to all creatures
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 31, 2002
//:://////////////////////////////////////////////
//:: VFX Pass By:

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Range = RADIUS_SIZE_MEDIUM;
    spell.TargetType = SPELL_TARGET_ALLALLIES;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eImpact = EffectVisualEffect(VFX_FNF_LOS_HOLY_30);
    effect eVis = EffectVisualEffect(VFX_IMP_HOLY_AID);
    effect eNeg = EffectDamageImmunityIncrease(DAMAGE_TYPE_NEGATIVE, 100);
    effect eLevel = EffectImmunity(IMMUNITY_TYPE_NEGATIVE_LEVEL);
    effect eAbil = EffectImmunity(IMMUNITY_TYPE_ABILITY_DECREASE);
    effect ePoison = EffectImmunity(IMMUNITY_TYPE_POISON);
    effect eDisease = EffectImmunity(IMMUNITY_TYPE_DISEASE);
    effect eAC = EffectACIncrease(4,AC_DEFLECTION_BONUS);//should be probably dodge vs undead only
    float fDelay;
    int nDuration = spell.Level;

    //Enter Metamagic conditions
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2; //Duration is +100%
    }

    //Link Effects
    effect eLink = EffectLinkEffects(eNeg, eLevel);
    eLink = EffectLinkEffects(eLink, eAbil);
    eLink = EffectLinkEffects(eLink, eAC);
    eLink = EffectLinkEffects(eLink, ePoison);
    eLink = EffectLinkEffects(eLink, eDisease);

    //Apply Impact
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);

    //Get the first target in the radius around the caster
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    while(GetIsObjectValid(oTarget))
    {
        if(spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            fDelay = GetRandomDelay(0.4, 1.1);
            //Fire spell cast at event for target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
            //Apply the VFX impact and effects
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration));
        }
        //Get the next target in the specified area around the caster
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    }
}
