//::///////////////////////////////////////////////
//:: Stone To Flesh
//:: x0_s0_stoflesh
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The target is freed of any petrify effect
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: Oct 16 2002
//:://////////////////////////////////////////////
//:: VFX Pass By:

//UPDATE - Do a check to make sure that the creature being cast on
//          has not been set up to be a permanent statue.

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "inc_general"

void main()
{
    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    //Check to make sure the creature has not been set up to be a statue.
    if (GetLocalInt(spell.Target, "NW_STATUE") != 1)
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

        //Search for and remove the above negative effects
        effect eLook = GetFirstEffect(spell.Target);

        while(GetIsEffectValid(eLook))
        {
            if(GetEffectType(eLook) == EFFECT_TYPE_PETRIFY)
            {
                SetCommandable(TRUE, spell.Target);
                RemoveEffect(spell.Target, eLook);
            }
            eLook = GetNextEffect(spell.Target);
        }

        if (GetIsPC(spell.Target)) SQLocalsPlayer_DeleteInt(spell.Target, "PETRIFIED");
        DeleteLocalInt(spell.Target, "PETRIFIED");
        //Apply Linked Effect
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DISPEL), spell.Target);
    }
}
