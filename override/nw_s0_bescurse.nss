//::///////////////////////////////////////////////
//:: Bestow Curse
//:: NW_S0_BesCurse.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Afflicted creature must save or suffer a -2 penalty
    to all ability scores. This is a supernatural effect.
*/
//:://////////////////////////////////////////////
//:: Created By: Bob McCabe
//:: Created On: March 6, 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk
//:: VFX Pass By: Preston W, On: June 20, 2001
//:: Update Pass By: Preston W, On: July 20, 2001
/*
Patch 1.70

- wrong signal event fixed
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
    effect eCurse = EffectCurse(2, 2, 2, 2, 2, 2);

    //Make sure that curse is of type supernatural not magical
    eCurse = SupernaturalEffect(eCurse);
    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Signal spell cast at event
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
         //Make SR Check
         if (!MyResistSpell(spell.Caster, spell.Target))
         {
            //Make Will Save
            if (!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_NONE, spell.Caster))
            {
                //Apply Effect and VFX
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, eCurse, spell.Target);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
            }
        }
    }
}
