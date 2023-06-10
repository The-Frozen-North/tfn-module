//::///////////////////////////////////////////////
//:: x1_s2_imbuearrow
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Imbue Arrow
     - creates a fireball arrow that when it explodes
     acts like a fireball.
     - Must have shortbow or longbow in hand.

    GZ: Updated

*/
//:://////////////////////////////////////////////
//:: Created By:
//:: Created On:
//:://////////////////////////////////////////////
/*
Patch 1.70

- critical hit damage corrected (damage was always even before)
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //Declare major variables
    spellsDeclareMajorVariables();
    int nCasterLvl = GetLevelByClass(CLASS_TYPE_ARCANE_ARCHER, spell.Caster); // * get a bonus of +10 to make this useful for arcane archer
    int nDamage;
    float fDelay;
    effect eExplode = EffectVisualEffect(VFX_FNF_FIREBALL);
    effect eVis = EffectVisualEffect(VFX_IMP_FLAME_M);
    effect eDam;
    //Limit Caster level for the purposes of damage
    if (nCasterLvl > 10)
    {
        nCasterLvl = 10 + ((nCasterLvl-10)/2);      // add some epic progression of 1d6 per 2 levels after 10
    }
    else // * preserve minimum damage of 10d6
    {
         nCasterLvl = 10;
    }
    // * GZ: Add arrow damage if targeted on creature...
    if (GetIsObjectValid(spell.Target))
    {
        if (spellsIsTarget(spell.Target, SPELL_TARGET_SELECTIVEHOSTILE, spell.Caster))
        {
          int nTouch = TouchAttackRanged(spell.Target, TRUE);
          if (nTouch > 0)
          {
            nDamage = ArcaneArcherDamageDoneByBow(nTouch==2);

            int  nBonus = ArcaneArcherCalculateBonus();
            effect ePhysical = EffectDamage(nDamage, DAMAGE_TYPE_PIERCING, IPGetDamagePowerConstantFromNumber(nBonus));
            effect eMagic = EffectDamage(nBonus, DAMAGE_TYPE_MAGICAL);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, ePhysical, spell.Target);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eMagic, spell.Target);
          }
        }
    }

    //Apply the fireball explosion at the location captured above.
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, spell.Loc);
    //Declare the spell shape, size and the location.  Capture the first target object in the shape.
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, spell.Loc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget))
    {
        if(spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, spell.Caster))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id, TRUE));
            //Get the distance between the explosion and the target to calculate delay
            fDelay = GetDistanceBetweenLocations(spell.Loc, GetLocation(oTarget))/20;
            if (!MyResistSpell(spell.Caster, oTarget, fDelay))
            {
                //Roll damage for each target
                nDamage = d6(nCasterLvl);
                //Resolve metamagic
                //Adjust the damage based on the Reflex Save, Evasion and Improved Evasion.
                nDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, spell.DC, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_FIRE);
                if(nDamage > 0)
                {
                    //Set the damage effect
                    eDam = EffectDamage(nDamage, DAMAGE_TYPE_FIRE);
                    // Apply effects to the currently selected target.
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                    //This visual effect is applied to the target object not the location as above.  This visual effect
                    //represents the flame that erupts on the target not on the ground.
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                }
             }
        }
       //Select the next target within the spell shape.
       oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, spell.Loc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }
}
