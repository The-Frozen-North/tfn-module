//::///////////////////////////////////////////////
//:: Harpies Captivating Song
//:: x2_s1_harpycry
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Will charm any creature failing saving a will throw DC 15 x
    Charm song in a RADIUS_SIZE_HUGE radius for 6 rounds

    If cast by a Shifter Character, the DC is
    15 + Shifter Level /3

*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: 2003/07/08
//:://////////////////////////////////////////////
/*
Patch 1.72
- added deaf failure chance
Patch 1.70
- shape location wasn't correct (at least if used by creature)
- was doing charm effect even for players (replaced for daze in this case)
- added delay into SR and saving throw's VFX
- don't work under silenced effect anymore
- doesn't affect silenced or deafened creatures anymore
*/

#include "x0_i0_spells"

void main()
{
    if (GetHasEffect(EFFECT_TYPE_SILENCE,OBJECT_SELF))
    {
        FloatingTextStrRefOnCreature(85764,OBJECT_SELF); // not useable when silenced
        return;
    }
    else if(GetGameDifficulty() >= GAME_DIFFICULTY_CORE_RULES && d100() < 21 && GetHasEffect(EFFECT_TYPE_DEAF,OBJECT_SELF))
    {                                                    // 20% chance to fail under deafness
        FloatingTextStrRefOnCreature(83576,OBJECT_SELF); //* You can not concentrate on using this ability effectively *
        return;
    }
    effect eCharm = EffectCharmed();
    effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eImpact = EffectVisualEffect(VFX_FNF_LOS_NORMAL_30);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects(eMind, eDur);
    effect eVis = EffectVisualEffect(VFX_IMP_CHARM);
    effect scaledEffect;
    int nDuration = 6;
    float fDelay;
    int nSaveDC;
    if (GetIsPC(OBJECT_SELF))
    {
        int nShifter = GetLevelByClass(CLASS_TYPE_SHIFTER,OBJECT_SELF) / 3 ;
        if (nShifter<1)
        {
            nShifter = 0;
        }
        nSaveDC = 15 + nShifter;
    }
    else
    {
        nSaveDC = 15;
    }

    location lTarget = GetLocation(OBJECT_SELF);
    // Apply song Effect on Self
    effect eSong = EffectVisualEffect(VFX_DUR_BARD_SONG);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSong, OBJECT_SELF, RoundsToSeconds(nDuration));
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, lTarget);

    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lTarget);
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != OBJECT_SELF && AmIAHumanoid(oTarget) && spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, OBJECT_SELF))
        {
            if (!GetHasEffect(EFFECT_TYPE_SILENCE,oTarget) && !GetHasEffect(EFFECT_TYPE_DEAF,oTarget))
            {
                fDelay = GetRandomDelay();
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId()));
                //Make an SR check
                if(MyResistSpell(OBJECT_SELF, oTarget, fDelay) < 1)
                {
                    //Make a Will save to negate
                    if(!MySavingThrow(SAVING_THROW_WILL, oTarget, nSaveDC, SAVING_THROW_TYPE_MIND_SPELLS, OBJECT_SELF, fDelay))
                    {
                        //Apply the linked effects and the VFX impact
                        scaledEffect = GetScaledEffect(eCharm, oTarget);
                        scaledEffect = EffectLinkEffects(eLink, scaledEffect);

                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, scaledEffect, oTarget, RoundsToSeconds(nDuration)));
                        DelayCommand(fDelay,ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                    }
                }
            }
        }
        //Get next target in spell area
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lTarget);
    }
}
