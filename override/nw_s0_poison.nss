//::///////////////////////////////////////////////
//:: Poison
//:: NW_S0_Poison.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Must make a touch attack. If successful the target
    is struck down with wyvern poison.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 22, 2001
//:://////////////////////////////////////////////
/*
Patch 1.71

- poison made extraordinary
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect ePoison = EffectPoison(POISON_LARGE_SCORPION_VENOM);
    ePoison = ExtraordinaryEffect(ePoison);
    int nTouch = 1;//seems that touch attack was removed from some reason, let it be then
    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //Make touch attack
        if (nTouch > 0)
        {
            //Make SR Check
            if (!MyResistSpell(spell.Caster, spell.Target))
            {
                //Apply the poison effect and VFX impact
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, ePoison, spell.Target);
            }
        }
    }
}
