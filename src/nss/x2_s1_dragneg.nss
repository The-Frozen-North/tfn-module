//::///////////////////////////////////////////////
//:: Dragon Breath Negative Energy
//:: NW_S1_DragNeg
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
Patch 1.70

- wrong target check (could affect other NPCs)
- damage was the same for all creatures in AoE
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
//    int nDamage, nDamStrike;; // for level drain
//    int nDamage2, nDamStrike2; // for negative energy
    int nDC = GetDragonBreathDC();
    int nDamStrike;
    float fDelay;
    effect eVis = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
    effect eBreath;

    PlayDragonBattleCry();
    //Get first target in spell area
    object oTarget = GetFirstObjectInShape(SHAPE_SPELLCONE, 14.0, GetSpellTargetLocation(), TRUE);
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != OBJECT_SELF && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_DRAGON_BREATH_NEGATIVE));
            //randomize damage for each creature in AoE
            nDamStrike = d8(nDamage);
            nDamStrike = GetSavingThrowAdjustedDamage(nDamStrike,oTarget,nDC,SAVING_THROW_REFLEX,SAVING_THROW_TYPE_NEGATIVE,OBJECT_SELF);
            if (nDamStrike > 0)
            {
                //Set Damage and VFX
                //effect eBreath = EffectNegativeLevel(nDamStrike);
                eBreath = EffectDamage(nDamStrike, DAMAGE_TYPE_NEGATIVE);
                //eBreath = SupernaturalEffect(eBreath);
                //eBreath2 = SupernaturalEffect(eBreath2);
                //Determine effect delay
                fDelay = GetDistanceBetween(OBJECT_SELF, oTarget)/20;
                //Apply the VFX impact and effects
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                //DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eBreath, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eBreath, oTarget));
             }
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPELLCONE, 14.0, GetSpellTargetLocation(), TRUE);
    }
}
