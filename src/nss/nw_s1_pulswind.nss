//::///////////////////////////////////////////////
//:: Pulse Whirlwind
//:: NW_S1_PulsWind
//:: Copyright (c) 2001 Bioware Corp.
//::///////////////////////////////////////////////
/*
    All those that fail a save of DC 14 are knocked
    down by the elemental whirlwind.

     * made this make the knockdown last 2 rounds instead of 1
     * it will now also do d3(hitdice/2) damage
*/
//::///////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 8, 2002
//::///////////////////////////////////////////////
/*
Patch 1.70

- wrong target check (could affect other NPCs)
- was missing signal event
- damage was the same for all creatures in AoE
+ better visual effect
+ disperses any cloud like effect like gust of wind does
*/

#include "x0_i0_spells"

void main()
{
    //Declare major variables
    effect eDam, eDown = EffectKnockdown();
    int numDice = GetHitDice(OBJECT_SELF)/2;
    location lLoc = GetLocation(OBJECT_SELF);

    effect eImpact = EffectVisualEffect(VFX_IMP_PULSE_WIND);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, OBJECT_SELF);
    eImpact = EffectVisualEffect(VFX_FNF_LOS_NORMAL_20);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, OBJECT_SELF);

    //Get first target in spell area
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, lLoc);
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != OBJECT_SELF && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_PULSE_WHIRLWIND));
            //Make a saving throw check
            if(!MySavingThrow(SAVING_THROW_REFLEX, oTarget, 14, SAVING_THROW_TYPE_NONE, OBJECT_SELF))
            {
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDown, oTarget, RoundsToSeconds(2));
                //Apply the VFX impact and effects
                eDam = EffectDamage(d3(numDice), DAMAGE_TYPE_SLASHING);
                DelayCommand(0.01, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
            }
        }
        //Get next target in spell area
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, lLoc);
    }
    int nTh = 1;
    string sAOETag;
    //this ability also disperses any cloud effects in area of effect
    oTarget = GetNearestObject(OBJECT_TYPE_AREA_OF_EFFECT,OBJECT_SELF,nTh);
    while(GetIsObjectValid(oTarget))
    {
        if(GetIsInSubArea(OBJECT_SELF,oTarget))
        {
            // Gust of wind should only destroy "cloud/fog like" area of effect spells.
            sAOETag = GetTag(oTarget);
            if ( sAOETag == "VFX_PER_FOGACID" || sAOETag == "VFX_PER_FOGKILL" || sAOETag == "VFX_PER_FOGBEWILDERMENT" || sAOETag == "VFX_PER_STONEHOLD" ||
                 sAOETag == "VFX_PER_FOGSTINK" || sAOETag == "VFX_PER_FOGFIRE" || sAOETag == "VFX_PER_FOGMIND" || sAOETag == "VFX_PER_CREEPING_DOOM")
            {
                DestroyObject(oTarget);
            }
        }
    oTarget = GetNearestObject(OBJECT_TYPE_AREA_OF_EFFECT,OBJECT_SELF,++nTh);
    }
}
