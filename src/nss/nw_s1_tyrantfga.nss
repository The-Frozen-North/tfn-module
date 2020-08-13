//::///////////////////////////////////////////////
//:: Tyrant Fog Zombie Mist Heartbeat
//:: NW_S1_TyrantFgA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creatures entering the area around the zombie
    must save or take 1 point of Constitution
    damage.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 25, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- won't affect poison immune creatures anymore
*/

#include "x0_i0_spells"

void main()
{
    //Declare major variables
    object oTarget = GetEnteringObject();
    object oCreator = GetAreaOfEffectCreator();

    if(!GetHasSpellEffect(SPELLABILITY_TYRANT_FOG_MIST, oTarget))
    {
        if(spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oCreator))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_TYRANT_FOG_MIST));
            //Make a saving throw check
            if(!MySavingThrow(SAVING_THROW_FORT, oTarget, 13, SAVING_THROW_TYPE_POISON, oCreator))
            {
                if(!GetIsImmune(oTarget, IMMUNITY_TYPE_POISON, oCreator))
                {
                    effect eCon = EffectAbilityDecrease(ABILITY_CONSTITUTION, 1);
                    eCon = ExtraordinaryEffect(eCon);
                    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
                    effect eLink = EffectLinkEffects(eCon, eDur);
                    //Apply the VFX impact and effects
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(5));
                }
                else
                {
                    //engine workaround to get proper immunity feedback
                    ApplyEffectToObject(DURATION_TYPE_PERMANENT,EffectPoison(POISON_ETTERCAP_VENOM),oTarget);
                }
            }
        }
    }
}
