//::///////////////////////////////////////////////
//:: Wall of Fire: On Enter
//:: NW_S0_WallFireA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Person within the AoE take 4d6 fire damage
    per round.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 17, 2001
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_FIRE;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();
    int nDamage;
    effect eDam;
    //Declare and assign personal impact visual effect.
    effect eVis = EffectVisualEffect(spell.DmgVfxL);
    //Capture the first target object in the shape.
    object oTarget = GetEnteringObject();

    if (spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
        //Make SR check, and appropriate saving throw(s).
        if(!MyResistSpell(aoe.Creator, oTarget))
        {
            //Roll damage.
            nDamage = MaximizeOrEmpower(spell.Dice,4,spell.Meta);
            nDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, spell.DC, spell.SavingThrow, spell.SaveType, aoe.Creator);
            if(nDamage > 0)
            {
                // Apply effects to the currently selected target.
                eDam = EffectDamage(nDamage, spell.DamageType);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
            }
        }
    }
}
