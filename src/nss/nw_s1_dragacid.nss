//::///////////////////////////////////////////////
//:: Dragon Breath Acid
//:: NW_S1_DragAcid
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
- damage dice calculation wasn't correct for some HDs
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
    effect eVis = EffectVisualEffect(VFX_IMP_ACID_S);
    effect eBreath;

    PlayDragonBattleCry();
    //Get first target in spell area
    object oTarget = GetFirstObjectInShape(SHAPE_SPELLCONE, 14.0, GetSpellTargetLocation(), TRUE);
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != OBJECT_SELF && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_DRAGON_BREATH_ACID));
            //Determine effect delay
            fDelay = GetDistanceBetween(OBJECT_SELF, oTarget)/20;
            //randomize damage for each creature in AoE
            nDamStrike = d4(nDamage);
            //Adjust the damage based on the Reflex Save, Evasion and Improved Evasion.
            nDamStrike = GetSavingThrowAdjustedDamage(nDamStrike, oTarget, nDC, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_ACID, OBJECT_SELF);
            if (nDamStrike > 0)
            {
                //Set Damage
                eBreath = EffectDamage(nDamStrike, DAMAGE_TYPE_ACID);
                //Apply the VFX impact and effects
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eBreath, oTarget));
             }
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPELLCONE, 14.0, GetSpellTargetLocation(), TRUE);
    }
}
