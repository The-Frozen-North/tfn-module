//::///////////////////////////////////////////////
//:: Dragon Breath Weaken
//:: NW_S1_DragWeak
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Calculates the proper damage and DC Save for the
    breath weapon based on the HD of the dragon.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 9, 2001
//:: Updated On: Oct 21, 2003
//:://////////////////////////////////////////////
/*
Patch 1.72
- fixed casting the spell on self not finding any targets in AoE
Patch 1.70
- saving throw type changed to fortitude
- wrong target check (could affect other NPCs)
> breath weapon damage and DC calculation changed in order to allow higher values
for custom content dragons with 40+ HD. DC calculation is now 10+1/2 dragon's HD+
dragon's constitution modifier.
*/

#include "70_inc_dragons"
#include "x0_i0_spells"

void main()
{
    //Declare major variables
    int nDC = GetDragonBreathDC();
    int nDamage = GetDragonBreathNumDice()/2;
    float fDelay;
    effect eVis = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
    effect eBreath = EffectAbilityDecrease(ABILITY_STRENGTH, nDamage);
    eBreath = SupernaturalEffect(eBreath);

    location lTargetLocation = GetSpellTargetLocation();
    if(lTargetLocation == GetLocation(OBJECT_SELF))
    {
        vector vFinalPosition = GetPositionFromLocation(lTargetLocation);
        vFinalPosition.x+= cos(GetFacing(OBJECT_SELF));
        vFinalPosition.y+= sin(GetFacing(OBJECT_SELF));
        lTargetLocation = Location(GetAreaFromLocation(lTargetLocation),vFinalPosition,GetFacingFromLocation(lTargetLocation));
    }

    PlayDragonBattleCry();
    //Get first target in spell area
    object oTarget = GetFirstObjectInShape(SHAPE_SPELLCONE, 14.0, lTargetLocation, TRUE);
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != OBJECT_SELF && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_DRAGON_BREATH_WEAKEN));
            fDelay = GetDistanceBetween(OBJECT_SELF, oTarget)/20;
            //Make a saving throw check
            if(!MySavingThrow(SAVING_THROW_FORT, oTarget, nDC, SAVING_THROW_TYPE_NONE, OBJECT_SELF, fDelay))
            {
                //Apply the VFX impact and effects
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));

                //--------------------------------------------------------------
                //GZ: Bug fix
                //--------------------------------------------------------------
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eBreath, oTarget));
            }
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPELLCONE, 14.0, lTargetLocation, TRUE);
    }
}
