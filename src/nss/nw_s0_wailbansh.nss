//::///////////////////////////////////////////////
//:: Wail of the Banshee
//:: NW_S0_WailBansh
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
  You emit a terrible scream that kills enemy creatures who hear it
  The spell affects up to one creature per caster level. Creatures
  closest to the point of origin are affected first.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On:  Dec 12, 2000
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: April 11, 2001
//:: VFX Pass By: Preston W, On: June 25, 2001
/*
Patch 1.72
- number of targets pool was incorrectly decreased also for creatures that weren't affected due to the pvp settings
Patch 1.70
- had double death VFX
- spell now affect targets gradually per description
- delay on VFX/effect halved (in order to limit the immunity swap exploit)
- deaf/silenced creatures are not affected anymore (sound descriptor)
- can no longer destroy placeables
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Range = RADIUS_SIZE_COLOSSAL;
    spell.SavingThrow = SAVING_THROW_FORT;
    spell.TargetType = SPELL_TARGET_SELECTIVEHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eWail = EffectVisualEffect(VFX_FNF_WAIL_O_BANSHEES);
    //Apply the FNF VFX impact
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eWail, spell.Loc);
    //delays the effects of entire spell until banshee VFX screams
    int nCnt = 1;
    int nToAffect = spell.Level;
    float fTargetDistance;
    float fDelay;
    effect eDeath = EffectDeath();
    //Get the closest target from the spell target location
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    while(GetIsObjectValid(oTarget) && nCnt <= nToAffect)
    {
        if(spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            //Get the distance of the target from the center of the effect
            fTargetDistance = GetDistanceBetweenLocations(spell.Loc, GetLocation(oTarget));
            //scale delay by distance from epicenter
            fDelay = GetDelayByRange(0.5, 1.5, fTargetDistance, spell.Range);//creatures starts dying in 0.5 to 1.5 seconds
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            //if target cannot hear the banshee he shouldn't be affected
            if(GetIsAbleToHear(oTarget) && !MyResistSpell(spell.Caster, oTarget, fDelay)) //, 1.0))
            {
                //Make a fortitude save to avoid death
                if(!MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_DEATH, spell.Caster, fDelay)) //, OBJECT_SELF, 3.0))
                {
                    //Apply the death effect
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget)); // no delay
                }
            }
            //Increment the count of creatures targeted
            nCnt++;
        }
        //Get the next closest target in the spell target location.
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    }
}