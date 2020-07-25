//:: Smoke Claws
//:: NW_S1_SmokeClaw
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    If a Belker succeeds at a touch attack the
    target breaths in part of the Belker and suffers
    3d4 damage per round until a Fortitude save is
    made.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 23 , 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- was unimplemented, but now fixed and implemented
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void spellsDoSmokeClaws(object oTarget, int nDC, int nHD)
{
 if(!MySavingThrow(SAVING_THROW_FORT, oTarget, nDC, SAVING_THROW_TYPE_NONE, OBJECT_SELF))
 {
 effect eVis = EffectVisualEffect(VFX_COM_BLOOD_REG_RED);
 effect eSmoke = EffectDamage(d4(nHD/2));
 ApplyEffectToObject(DURATION_TYPE_INSTANT, eSmoke, oTarget);
 ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
 eSmoke = EffectVisualEffect(VFX_DUR_GHOST_SMOKE_2);
 ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSmoke, oTarget, 6.0);
 DelayCommand(6.0, spellsDoSmokeClaws(oTarget, nDC, nHD));
 }
}

void main()
{
    //Declare major variables
    object oTarget = GetSpellTargetObject();
    int nHD = GetHitDice(OBJECT_SELF);
    int nDC = 10+nHD/2;

    //Make a touch attack
    if(TouchAttackMelee(oTarget))
    {
        if(spellsIsTarget(oTarget,SPELL_TARGET_SINGLETARGET,OBJECT_SELF))
        {
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_SMOKE_CLAW, TRUE));
            spellsDoSmokeClaws(oTarget,nDC,nHD);
        }
    }
}
