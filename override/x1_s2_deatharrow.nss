//::///////////////////////////////////////////////
//:: x1_s2_deatharrow
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Seeker Arrow
     - creates an arrow that automatically hits target.
     - At level 4 the arrow does +2 magic damage
     - at level 5 the arrow does +3 magic damage

     - normal arrow damage, based on base item type

     - Must have shortbow or longbow in hand.
*/
//:://////////////////////////////////////////////
//:: Created By:
//:: Created On:
//:://////////////////////////////////////////////
/*
Patch 1.70

- critical hit damage corrected (damage was always even before)
- added death VFX
- signal event placed before hit check, so it now removes GS/invis every time
*/

#include "x0_i0_spells"
#include "x2_inc_itemprop"

void main()
{
    int nBonus = ArcaneArcherCalculateBonus();
    object oTarget = GetSpellTargetObject();

    if (GetIsObjectValid(oTarget))
    {
        // * Roll Touch Attack
        int nTouch = TouchAttackRanged(oTarget, TRUE);

        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId()));

        if (nTouch > 0)
        {
            int nDamage = ArcaneArcherDamageDoneByBow(nTouch == 2);
            if (nDamage > 0)
            {
                effect ePhysical = EffectDamage(nDamage, DAMAGE_TYPE_PIERCING,IPGetDamagePowerConstantFromNumber(nBonus));
                effect eMagic = EffectDamage(nBonus, DAMAGE_TYPE_MAGICAL);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, ePhysical, oTarget);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eMagic, oTarget);

                int nSaveType = SAVING_THROW_TYPE_NONE;
                if(GetIsImmune(oTarget, IMMUNITY_TYPE_DEATH, OBJECT_SELF))
                {
                    nSaveType = SAVING_THROW_TYPE_DEATH;//workaround for action cancel bug without changing save type
                }
                // * if target fails a save DC20 they die
                if (!MySavingThrow(SAVING_THROW_FORT, oTarget, 20, nSaveType))
                {
                    effect eDeath = EffectDeath();
                    effect eVis = EffectVisualEffect(VFX_IMP_DEATH);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget);
                }
            }
        }
    }
}
