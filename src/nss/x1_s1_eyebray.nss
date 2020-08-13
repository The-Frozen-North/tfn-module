//::///////////////////////////////////////////////
//:: Eyeball attacks
//:: x1_s1_eyebray
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*

    By default, the eyeball only has the cold
    attack. On critical its freezing

    2nd attack (familiar) is wounding
    On Critical hit its slowing for 1d3 rounds


*/
//:://////////////////////////////////////////////
//:
//:://////////////////////////////////////////////
/*
Patch 1.70

- was missing no-pvp check
- no need to success in touch attack now if the target of the inflict ray
is undead
*/

#include "70_inc_spells"
#include "x0_i0_spells"

int EBGetScaledBoltDamage(int nSpell)
{
    int nLevel = GetHitDice(OBJECT_SELF);
    int nCount = nLevel /5;
    if (nCount < 1)
    {
        nCount = 1;
    }

    int nDamage;

    switch (nSpell)
    {
        case 710:
            nDamage = d4(nCount) + (nLevel /2);
            break;
        case 711:
            nDamage = d6(2) + (nCount*2);
            break;
        case 712:
            nDamage = d6(nCount) + (nCount);
            break;
    }

    return nDamage;
}

void main()
{
    //Declare major variables
    object oTarget = GetSpellTargetObject();
    int nHD = GetHitDice(OBJECT_SELF);
    effect eVis, eBolt;
    int nHit;
    int nDC = 10 + (nHD/3);
    int nSpell = GetSpellId();
    int nDamage = EBGetScaledBoltDamage(nSpell);

    if(nSpell == 710) // cold bolt
    {
        eVis = EffectVisualEffect(VFX_IMP_FROST_S);
        eBolt = EffectDamage(nDamage,DAMAGE_TYPE_COLD);

        if(spellsIsTarget(oTarget, SPELL_TARGET_SINGLETARGET, OBJECT_SELF))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, nSpell));
            //Make a saving throw check
            nHit = TouchAttackRanged(oTarget);
            if(nHit > 0)
            {
                //Apply the VFX impact and effects
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eBolt, oTarget);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);

                // if critical hit , freeze for 1 round
                if(nHit == 2)
                {
                    effect ePara = EffectParalyze();
                    effect eIce = EffectVisualEffect(VFX_DUR_ICESKIN);
                    ePara = EffectLinkEffects(eIce,ePara);
                    if(!MySavingThrow(SAVING_THROW_FORT, oTarget, nDC, SAVING_THROW_TYPE_COLD, OBJECT_SELF))
                    {
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ePara, oTarget, RoundsToSeconds(1));
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_FROST_L), oTarget, RoundsToSeconds(d3(2)));
                    }
                }
            }
        }
    }
    else if(nSpell == 711) // inflict wounds
    {
        // Negative Energy should heal undead creatures.
        int bUndead = spellsIsRacialType(oTarget, RACIAL_TYPE_UNDEAD);
        if(bUndead || spellsIsTarget(oTarget, SPELL_TARGET_SINGLETARGET, OBJECT_SELF))
        {
            if(!bUndead)
            {
                eVis = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
                eBolt = EffectDamage(nDamage,DAMAGE_TYPE_NEGATIVE);
            }
            else
            {
               eVis = EffectVisualEffect(VFX_IMP_HEALING_M);
               eBolt =  EffectHeal(nDamage);
               nHit = 1;
            }
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, nSpell, !bUndead));
            //Make a touch attack, but only if the target is not undead

            if(!bUndead)
            {
                nHit = TouchAttackRanged(oTarget);
            }
            if(nHit > 0)
            {
                //Apply the VFX impact and effects
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eBolt, oTarget);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);

                // if critical hit , slow for 1 round
                if(nHit == 2 && !bUndead)
                {
                    effect eSlow = EffectSlow();
                    if(!MySavingThrow(SAVING_THROW_FORT, oTarget, nDC, SAVING_THROW_TYPE_NONE, OBJECT_SELF))
                    {
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSlow, oTarget, RoundsToSeconds(d3(2)));
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SLOW), oTarget, RoundsToSeconds(d3(2)));
                    }
                }
            }
        }
    }
    else if(nSpell == 712)//Fire
    {
        eVis = EffectVisualEffect(VFX_IMP_FLAME_S);
        eBolt = EffectDamage(nDamage,DAMAGE_TYPE_FIRE);
        if(spellsIsTarget(oTarget, SPELL_TARGET_SINGLETARGET, OBJECT_SELF))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, nSpell));
            //Make a saving throw check
            nHit = TouchAttackRanged(oTarget);
            if(nHit > 0)
            {
                //Apply the VFX impact and effects
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eBolt, oTarget);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);

                // if critical hit , knockdown for 1 round
                if(nHit == 2)
                {
                    effect eKnock = EffectKnockdown();
                    if(!MySavingThrow(SAVING_THROW_FORT, oTarget, nDC, SAVING_THROW_TYPE_NONE, OBJECT_SELF))
                    {
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnock, oTarget, RoundsToSeconds(2));
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_FLAME_M), oTarget, RoundsToSeconds(d3(2)));
                    }
                }
            }
        }
    }
}
