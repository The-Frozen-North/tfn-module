//::///////////////////////////////////////////////
//:: Breath Weapon for Dragon Disciple Class
//:: x2_s2_discbreath
//:: Copyright (c) 2003Bioware Corp.
//:://////////////////////////////////////////////
/*

  Damage Type is Fire
  Save is Reflex
  Shape is cone, 30' == 10m

  Level      Damage      Save
  ---------------------------
  3          2d10         19
  7          4d10         19
  10          6d10        19

  after 10:
   damage: 6d10  + 1d10 per 3 levels after 10
   savedc: increasing by 1 every 4 levels after 10



*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: June, 17, 2003
//:://////////////////////////////////////////////
/*
Pach 1.72
- fixed bug in "cast on self" workaround that prevented the breath to work properly in case it was used at non zero Z position
Patch 1.70
- wrong target check (could affect other NPCs)
- damage was the same for all creatures in AoE
- old evasion behaviour (now that evasion is applied will appear in log)
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    int nType = GetSpellId();
    int nDamageDice;
    int nSaveDC = 19;

    int nLevel = GetLevelByClass(CLASS_TYPE_DRAGON_DISCIPLE,OBJECT_SELF);// 37 = red dragon disciple

    if (nLevel <7)
    {
        nDamageDice = 2;
    }
    else if (nLevel <10)
    {
        nDamageDice = 4;
    }
    else if (nLevel ==10)
    {
        nDamageDice = 6;
    }
    else
    {
      nDamageDice = 6+((nLevel -10)/3);
      nSaveDC = nSaveDC + ((nLevel -10)/4);
    }

    int nDamage, nPersonalDamage;
    //Declare major variables
    float fDelay;
    effect eBreath, eVis = EffectVisualEffect(494);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT,eVis,GetSpellTargetLocation());
    eVis = EffectVisualEffect(VFX_IMP_FLAME_M);

    //Get first target in spell area
    location lFinalTarget = GetSpellTargetLocation();
    if ( lFinalTarget == GetLocation(OBJECT_SELF) )
    {
        // Since the target and origin are the same, we have to determine the
        // direction of the spell from the facing of OBJECT_SELF (which is more
        // intuitive than defaulting to East everytime).

        // In order to use the direction that OBJECT_SELF is facing, we have to
        // instead we pick a point slightly in front of OBJECT_SELF as the target.
        vector vFinalPosition = GetPositionFromLocation(lFinalTarget);//1.72: this will retain Z position
        vFinalPosition.x+= cos(GetFacing(OBJECT_SELF));
        vFinalPosition.y+= sin(GetFacing(OBJECT_SELF));
        lFinalTarget = Location(GetAreaFromLocation(lFinalTarget),vFinalPosition,GetFacingFromLocation(lFinalTarget));
    }

    object oTarget = GetFirstObjectInShape(SHAPE_SPELLCONE, 10.0, lFinalTarget, TRUE,  OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR  | OBJECT_TYPE_PLACEABLE);
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != OBJECT_SELF && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId()));
            //Determine effect delay
            fDelay = GetDistanceBetween(OBJECT_SELF, oTarget)/20;
            //randomize damage for each creature in AoE
            nDamage = d10(nDamageDice);
            //Adjust the damage based on the Reflex Save, Evasion and Improved Evasion.
            nPersonalDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, nSaveDC, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_FIRE, OBJECT_SELF);
            if (nPersonalDamage > 0)
            {
                //Set Damage
                eBreath = EffectDamage(nPersonalDamage, DAMAGE_TYPE_FIRE);
                //Apply the VFX impact and effects
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eBreath, oTarget));
             }
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPELLCONE, 10.0, lFinalTarget, TRUE,  OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR  | OBJECT_TYPE_PLACEABLE);
    }
}
