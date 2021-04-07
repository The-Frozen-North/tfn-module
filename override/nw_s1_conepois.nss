//::///////////////////////////////////////////////
//:: Cone: Poison
//:: NW_S1_ConePois
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creature spits out a cone of poison that cannot
    be avoided unless a Reflex save is made.  Creatures
    who fail there save are struck with Wyvern Poison
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 22, 2001
//:://////////////////////////////////////////////
/*
Patch 1.71

- area of effect size prolonged to 11.0 to match the distance of the cone usage/visual
- wrong target check (could affect other NPCs)
- shape size wasn't correct (started with 10.0 then continued with 11.0, which
caused issues)
- poison made extraordinary
*/

#include "x0_i0_spells"

void main()
{
    //Declare major variables
    location lTargetLocation = GetSpellTargetLocation();
    object oTarget;
    float fDelay;
    int nHD = GetHitDice(OBJECT_SELF);
    int nDC = 10 + (nHD/2);
    int nRacial = GetRacialType(OBJECT_SELF);
    int nPoison;
    //Determine the poison type based on the Racial Type and HD
    switch (nRacial)
    {
        case RACIAL_TYPE_OUTSIDER:
            if (nHD <= 9)
            {
                nPoison = POISON_QUASIT_VENOM;
            }
            else if (nHD < 13)
            {
                nPoison = POISON_BEBILITH_VENOM;
            }
            else //if (nHD >= 13)
            {
                nPoison = POISON_PIT_FIEND_ICHOR;
            }
        break;
        case RACIAL_TYPE_VERMIN:
            if (nHD < 3)
            {
                nPoison = POISON_TINY_SPIDER_VENOM;
            }
            else if (nHD < 6)
            {
                nPoison = POISON_SMALL_SPIDER_VENOM;
            }
            else if (nHD < 9)
            {
                nPoison = POISON_MEDIUM_SPIDER_VENOM;
            }
            else if (nHD < 12)
            {
                nPoison =  POISON_LARGE_SPIDER_VENOM;
            }
            else if (nHD < 15)
            {
                nPoison = POISON_HUGE_SPIDER_VENOM;
            }
            else if (nHD < 18)
            {
                nPoison = POISON_GARGANTUAN_SPIDER_VENOM;
            }
            else //if (nHD >= 18)
            {
                nPoison = POISON_COLOSSAL_SPIDER_VENOM;
            }
        break;
        default:
            if (nHD < 3)
            {
                nPoison = POISON_NIGHTSHADE;
            }
            else if (nHD < 6)
            {
                nPoison = POISON_BLADE_BANE;
            }
            else if (nHD < 9)
            {
                nPoison = POISON_BLOODROOT;
            }
            else if (nHD < 12)
            {
                nPoison =  POISON_LARGE_SPIDER_VENOM;
            }
            else if (nHD < 15)
            {
                nPoison = POISON_LICH_DUST;
            }
            else if (nHD < 18)
            {
                nPoison = POISON_DARK_REAVER_POWDER;
            }
            else //if (nHD >= 18 )
            {
                nPoison = POISON_BLACK_LOTUS_EXTRACT;
            }

        break;
    }
    effect eCone = EffectPoison(nPoison);
    eCone = ExtraordinaryEffect(eCone);
    effect eVis = EffectVisualEffect(VFX_IMP_POISON_S);
    oTarget = FIX_GetFirstObjectInShape(SHAPE_SPELLCONE, 11.0, lTargetLocation, TRUE);
    //Get first target in spell area
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != OBJECT_SELF && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_CONE_POISON));
            //Get the delay time
            fDelay = GetDistanceBetween(OBJECT_SELF, oTarget)/20;
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eCone, oTarget));
        }
        //Get next target in spell area
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPELLCONE, 11.0, lTargetLocation, TRUE);
    }
}
