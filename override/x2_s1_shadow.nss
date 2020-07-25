//::///////////////////////////////////////////////
//:: x2_s1_shadow
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The shadow gets  special strength drain
    attack, once per round.

    The shifter's spectre form can use this ability
    but is not as effective as a real shadow
*/
//:://////////////////////////////////////////////
//:: Created By:
//:: Created On:
//:://////////////////////////////////////////////
/*
Patch 1.70

- killing method could fail in special case (magic damage immune/resistant + death magic immune)
- fixed immunity check so now works properly in case of ability decrease immnity only vs undead
- added signal event in order to remove invisibility/GS
- strength damage reduced to 1d4
*/

#include "x0_i0_spells"

void ApplyShadow(int nDamage, object oTarget)
{
    effect eDamage = EffectAbilityDecrease(ABILITY_STRENGTH, nDamage);

    // * Delaying the command to sever the connection between this effect and
    // * the spell, so its effects stack
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eDamage, oTarget);
}

void DoShadowHit(object oTarget)
{
    int nDamage = Random(4) + 1;

    int nTargetStrength = GetAbilityScore(oTarget, ABILITY_STRENGTH);

    SignalEvent(oTarget,EventSpellCastAt(OBJECT_SELF, GetSpellId(), TRUE));
    effect eVis;
    // * Target is slain in Hardcore mode or higher if Strength is reduced to 0
    if(!GetIsImmune(oTarget, IMMUNITY_TYPE_ABILITY_DECREASE, OBJECT_SELF))
    {
        //--------------------------------------------------------------------
        // On Hardcore rules, kill target if strength would fall below 0
        // This does not work for PCs (shiifter) it would be too unbalancing
        //--------------------------------------------------------------------
        if((nTargetStrength - nDamage) <= 0  && GetGameDifficulty() >= GAME_DIFFICULTY_CORE_RULES)
        {
            FloatingTextStrRefOnCreature(84482, oTarget,FALSE);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(EffectDeath(FALSE,FALSE)), oTarget);
        }
        else
        {
            DelayCommand(0.1, ApplyShadow(nDamage, oTarget));
            FloatingTextStrRefOnCreature(84483, oTarget, FALSE);
        }
        eVis = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
    }
    else
    {
        eVis = EffectVisualEffect(VFX_COM_HIT_NEGATIVE);
    }
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
}

void main()
{
    object oEnemy = GetSpellTargetObject();
    int nAttack = TouchAttackMelee(oEnemy, TRUE);
    if(nAttack == 1)
    {
        DoShadowHit(oEnemy);
    }
    else if(nAttack == 2)    // * Critical Hit!
    {
        DoShadowHit(oEnemy);
    }
    else
    {
        // * missed
    }
}
