//::///////////////////////////////////////////////
//:: Cone: Disease
//:: NW_S1_ConeDisea
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creature spits out a cone of disease that cannot
    be avoided unless a Reflex save is made.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 22, 2001
//:://////////////////////////////////////////////
/*
Patch 1.71

- area of effect size prolonged to 11.0 to match the distance of the cone usage/visual
- wrong target check (could affect other NPCs)
- shape size wasn't correct (started with 10.0 then continued ith 11.0, which
caused issues)
- disease made extraordinary
*/

#include "x0_i0_spells"

void main()
{
    //Declare major variables
    location lTargetLocation = GetSpellTargetLocation();
    float fDelay;
    int nHD = GetHitDice(OBJECT_SELF);
    int nRacial = GetRacialType(OBJECT_SELF);
    int nDisease;
    //Determine the disease type based on the Racial Type and HD
    switch (nRacial)
    {
        case RACIAL_TYPE_OUTSIDER:
            nDisease = DISEASE_DEMON_FEVER;
        break;
        case RACIAL_TYPE_VERMIN:
            nDisease = DISEASE_VERMIN_MADNESS;
        break;
        case RACIAL_TYPE_UNDEAD:
            if(nHD <= 3)
            {
                nDisease = DISEASE_ZOMBIE_CREEP;
            }
            else if (nHD > 3 && nHD <= 10)
            {
                nDisease = DISEASE_GHOUL_ROT;
            }
            else if(nHD > 10)
            {
                nDisease = DISEASE_MUMMY_ROT;
            }
        default:
            if(nHD <= 3)
            {
                nDisease = DISEASE_MINDFIRE;
            }
            else if (nHD > 3 && nHD <= 10)
            {
                nDisease = DISEASE_RED_ACHE;
            }
            else if(nHD > 10)
            {
                nDisease = DISEASE_SHAKES;
            }


        break;
    }
    //Set disease effect
    effect eCone = EffectDisease(nDisease);
    eCone = ExtraordinaryEffect(eCone);
    effect eVis = EffectVisualEffect(VFX_IMP_DISEASE_S);
    object oTarget = GetFirstObjectInShape(SHAPE_SPELLCONE, 11.0, lTargetLocation, TRUE);
    //Get first target in spell area
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != OBJECT_SELF && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_CONE_DISEASE));
            //Get the delay time
            fDelay = GetDistanceBetween(OBJECT_SELF, oTarget)/20;
            //Apply the VFX impact and effects
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eCone, oTarget));
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPELLCONE, 11.0, lTargetLocation, TRUE);
    }
}
