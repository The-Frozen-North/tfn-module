//::///////////////////////////////////////////////
//:: Dragon Wing Buffet
//:: NW_S1_WingBlast
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The dragon will launch into the air, knockdown
    all opponents who fail a Reflex Save and then
    land on one of those opponents doing damage
    up to a maximum of the Dragons HD + 10.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Feb 4, 2002
//:://////////////////////////////////////////////
/*
Patch 1.70

- was unimplemented, but now fixed and implemented, feel free to add this ability
to your dragons!
*/

#include "x0_i0_spells"
#include "70_inc_dragons"

void main()
{
    //Declare major variables
    effect eDam, eKnockDown = EffectKnockdown();
    int nHD = GetHitDice(OBJECT_SELF);
    int nDC = GetDragonBreathDC();
    int nSize = GetCreatureSize(OBJECT_SELF);
    location lLoc = GetLocation(OBJECT_SELF);
    float fDelay;
    string sAOETag;

    effect eVis = EffectVisualEffect(VFX_IMP_PULSE_WIND);
    effect eShake = EffectVisualEffect(VFX_FNF_SCREEN_SHAKE);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eShake, OBJECT_SELF);
    effect eImpact = EffectVisualEffect(VFX_FNF_LOS_NORMAL_20);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, OBJECT_SELF);

    //Get first target in spell area
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, lLoc, TRUE, OBJECT_TYPE_CREATURE|OBJECT_TYPE_AREA_OF_EFFECT);
    while(GetIsObjectValid(oTarget))
    {
        if(GetObjectType(oTarget) == OBJECT_TYPE_AREA_OF_EFFECT)//this ability also disperses any cloud effects in area of effect
        {
            // Gust of wind should only destroy "cloud/fog like" area of effect spells.
            sAOETag = GetTag(oTarget);
            if ( sAOETag == "VFX_PER_FOGACID" || sAOETag == "VFX_PER_FOGKILL" || sAOETag == "VFX_PER_FOGBEWILDERMENT" || sAOETag == "VFX_PER_STONEHOLD" ||
                 sAOETag == "VFX_PER_FOGSTINK" || sAOETag == "VFX_PER_FOGFIRE" || sAOETag == "VFX_PER_FOGMIND" || sAOETag == "VFX_PER_CREEPING_DOOM")
            {
                DestroyObject(oTarget);
            }
        }
        else if(oTarget != OBJECT_SELF && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_DRAGON_WING_BUFFET));
            //huge creatures are immune, was bit weird in the dragon vs dragon duel
            if(GetCreatureSize(oTarget) < nSize)
            {
                fDelay = GetDistanceBetween(oTarget,OBJECT_SELF)/20.0;
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                eDam = EffectDamage(Random(nHD)+11, DAMAGE_TYPE_BLUDGEONING);
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));

                if(!MySavingThrow(SAVING_THROW_REFLEX, oTarget, nDC, SAVING_THROW_TYPE_NONE, OBJECT_SELF, fDelay))
                {
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnockDown, oTarget, 6.0));
                    //slide only creatures not immune to knockdown
                    if(!GetIsImmune(oTarget, IMMUNITY_TYPE_KNOCKDOWN, OBJECT_SELF))
                    {
                        DelayCommand(fDelay, ActionRepel(oTarget, 15.0, 4.0));
                    }                                            //tile and half for the duration of 4 seconds
                }
            }
        }
        //Get next target in spell area
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, lLoc, TRUE, OBJECT_TYPE_CREATURE|OBJECT_TYPE_AREA_OF_EFFECT);
    }
    //Apply the VFX impact and effects
    effect eAppear = EffectAppear();
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAppear, OBJECT_SELF);
    //go attack you stupid dragon, don't stand there flatfooted!
    object oNearest = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
    if(GetIsObjectValid(oNearest))
    {

        DelayCommand(1.0, DetermineCombatRound(oNearest));
    }
    else
    {
        oNearest = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_HEARD, CREATURE_TYPE_IS_ALIVE, TRUE);
        if(GetIsObjectValid(oNearest))
        {
            DelayCommand(1.0, DetermineCombatRound(oNearest));
        }
    }
}
