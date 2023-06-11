//::///////////////////////////////////////////////
//:: Dragon Breath Fire
//:: NW_S1_DragFire
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Calculates the proper damage and DC Save for the
    breath weapon based on the HD of the dragon.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 9, 2001
//:://////////////////////////////////////////////
/*
Patch 1.72
- fixed casting the spell on self not finding any targets in AoE
Patch 1.70
- wrong target check (could affect other NPCs)
- damage was the same for all creatures in AoE
- old evasion behaviour (now that evasion is applied will appear in log)
> breath weapon damage and DC calculation changed in order to allow higher values
for custom content dragons with 40+ HD. DC calculation is now 10+1/2 dragon's HD+
dragon's constitution modifier.
*/

#include "70_inc_spells"
#include "70_inc_dragons"
#include "x0_i0_spells"

void main()
{
    //Declare major variables
    int nDamage = GetDragonBreathNumDice();
    int nDC = GetDragonBreathDC();
    int nDamStrike;
    float fDelay;
    effect eVis = EffectVisualEffect(VFX_IMP_FLAME_M);
    effect eBreath;

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
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_DRAGON_BREATH_FIRE));
            //randomize damage for each creature in AoE
            nDamStrike = d10(nDamage);
            //Adjust the damage based on the Reflex Save, Evasion and Improved Evasion.
            nDamStrike = GetSavingThrowAdjustedDamage(nDamStrike, oTarget, nDC, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_FIRE, OBJECT_SELF);
            if (nDamStrike > 0)
            {
                //Set Damage
                eBreath = EffectDamage(nDamStrike, DAMAGE_TYPE_FIRE);
                //Determine effect delay
                fDelay = GetDistanceBetween(OBJECT_SELF, oTarget)/20;
                //Apply the VFX impact and effects
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eBreath, oTarget));
             }
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPELLCONE, 14.0, lTargetLocation, TRUE);
    }
}
