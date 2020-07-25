//::///////////////////////////////////////////////
//:: Evil Blight
//:: x2_s0_EvilBlight
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Any enemies within the area of effect will
    suffer a curse effect
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: Jan 2/03
//:://////////////////////////////////////////////
//:: Updated by: Andrew Nobbs
//:: Updated on: March 28, 2003
//:: 2003-07-07: Stacking Spell Pass, Georg Zoeller
/*
Patch 1.70

- added delay into applications of effects and VFXs
- wrong signal event fixed
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Range = RADIUS_SIZE_COLOSSAL;
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_SELECTIVEHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eImpact = EffectVisualEffect(VFX_IMP_DOOM);
    effect eVis = EffectVisualEffect(VFX_IMP_EVIL_HELP);
    effect eCurse = SupernaturalEffect(EffectCurse(3,3,3,3,3,3));

    //Apply Spell Effects
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, spell.Loc);

    //Get first target in the area of effect
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    float fDelay;

    while(GetIsObjectValid(oTarget))
    {
        //Check faction of oTarget
        if(spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            fDelay = GetRandomDelay();//random delay so each target gets affected in different moment
            //Signal spell cast at event
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            //Make SR Check
            if (!MyResistSpell(spell.Caster, oTarget, fDelay))
            {
                //Make Will Save
                if (!MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_NONE, spell.Caster, fDelay))
                {
                    // wont stack
                    if (!GetHasSpellEffect(spell.Id, oTarget))
                    {
                         DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oTarget));
                         DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eCurse, oTarget));
                    }
                }
            }
        }
        //Get next spell target
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    }
}
