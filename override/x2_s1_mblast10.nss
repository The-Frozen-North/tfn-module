//::///////////////////////////////////////////////
//:: Greater Mindblast 10m radius
//:: x2_s1_mblast10
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    A psionic wave originating from the creature
    in a 10m foot radius around the creature

    Creatures can save vs the mindblast at a
    -4 modifier or be stunned for 1d3 rounds

    if the creature is already stunned, the
    mind blast does 1d3+casterlevel points of
    damage

*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: July 30, 2003
//:://////////////////////////////////////////////
/*
Patch 1.71

- was missing saving throw VFX
- added missing delay into effect applications
- signal event didn't fired in all cases
- radius size shortened to 10m per description
*/

#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //Declare major variables
    object oTarget;
    int nLevel = GetHitDice(OBJECT_SELF);
    effect eVis = EffectVisualEffect(VFX_IMP_PULSE_WIND);
    eVis = EffectLinkEffects(EffectVisualEffect(VFX_FNF_LOS_NORMAL_20),eVis);
    effect eVisStun = EffectVisualEffect(VFX_IMP_DOMINATE_S);
    float fDelay;
    int nDuration;
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    eDur = EffectLinkEffects(EffectStunned(),eDur);

    int nSaveDC = 10 +(GetHitDice(OBJECT_SELF)/2) +  GetAbilityModifier(ABILITY_WISDOM,OBJECT_SELF);

    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF);

    //Determine enemies in the radius around the bard
    oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, 10.0, GetLocation(OBJECT_SELF), TRUE, OBJECT_TYPE_CREATURE);
    int nDamage = GetHitDice(OBJECT_SELF);
    effect eDam = EffectDamage(nDamage,DAMAGE_TYPE_POSITIVE);
    while (GetIsObjectValid(oTarget))
    {
        if (oTarget != OBJECT_SELF && spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, OBJECT_SELF))
        {
           SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId()));
           fDelay = GetDistanceBetween(OBJECT_SELF, oTarget)/20;
           if (GetHasSpellEffect(GetSpellId(),oTarget))
           {
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_STUN), oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
           }
           else
           {
               //Make SR and Will saves
               if (!MySavingThrow(SAVING_THROW_WILL, oTarget, nSaveDC, SAVING_THROW_TYPE_MIND_SPELLS, OBJECT_SELF, fDelay))
               {
                   nDuration = d3();
                   DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisStun, oTarget));
                   DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, oTarget, RoundsToSeconds(nDuration)));
               }
          }
        }
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, 10.0, GetLocation(OBJECT_SELF), TRUE, OBJECT_TYPE_CREATURE);
    }
}
