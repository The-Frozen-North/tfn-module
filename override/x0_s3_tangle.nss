//::///////////////////////////////////////////////
//:: Tanglefoot bag
//:: x0_s3_tangle
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Grenade.
    Fires at a target. If hit, the target takes
    direct damage. If missed, all enemies within
    an area of effect take splash damage.

    HOWTO:
        Will entangle target.
        + If a saving throw REFLEX vs. DC 15 is failed the creature
          is immobile (HELD)

        DURATION: 1 turn
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: September 10, 2002
//:://////////////////////////////////////////////
/*
Patch 1.72
- effects made undispellable (extraordinary)
Patch 1.71
- added missing incorporeal check
*/

#include "x0_i0_spells"

void main()
{
    //Declare major variables
    effect eHold = EffectEntangle();
    effect eEntangle = EffectVisualEffect(VFX_DUR_ENTANGLE);
    object oTarget = GetSpellTargetObject();
    effect eLink = EffectLinkEffects(eHold, eEntangle);
    eLink = ExtraordinaryEffect(eLink);

    if(spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
    {
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), TRUE));
        //Make reflex save
        if(!GetCreatureFlag(oTarget, CREATURE_VAR_IS_INCORPOREAL) && !MySavingThrow(SAVING_THROW_REFLEX, oTarget, 15))
        {
           //Apply linked effects
           ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(2));
        }
    }
}
