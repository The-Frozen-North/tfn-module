//::///////////////////////////////////////////////
//:: Blade Barrier: On Enter
//:: NW_S0_BladeBarA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creates a wall 10m long and 2m thick of whirling
    blades that hack and slice anything moving into
    them.  Anything caught in the blades takes
    2d6 per caster level.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 20, 2001
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageCap = 20;
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_SLASHING;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();
    object oTarget = GetEnteringObject();
    effect eDam;
    effect eVis = EffectVisualEffect(spell.DmgVfxL);
    int nLevel = spell.Level;
    //Make level check
    if(nLevel > spell.DamageCap)
    {
        nLevel = spell.DamageCap;
    }
    if(spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
    {
        //Fire spell cast at event
        SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
        //Roll Damage
        int nDamage = MaximizeOrEmpower(spell.Dice,nLevel,spell.Meta);

        //Make SR Check
        if (!MyResistSpell(aoe.Creator, oTarget))
        {
            //Adjust damage according to Reflex Save, Evasion or Improved Evasion
            nDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, spell.DC, spell.SavingThrow, spell.SaveType, aoe.Creator);

            //Set damage effect
            eDam = EffectDamage(nDamage, spell.DamageType);
            //Apply damage and VFX
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
        }
    }
}
