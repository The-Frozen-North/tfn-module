//::///////////////////////////////////////////////
//:: [Raise Dead]
//:: [NW_S0_RaisDead.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Brings a character back to life with 1 HP.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 31, 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: April 11, 2001
//:: VFX Pass By: Preston W, On: June 22, 2001
/*
Patch 1.72

- added feedback when cast on placeable
- fires a scripted event in order to implement some penalty or persistency
*/

#include "70_inc_spells"
#include "x2_inc_spellhook"

void main()
{
    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    //Check to make sure the target is dead first
    //Fire cast spell at event for the specified target
    if (GetIsObjectValid(spell.Target))
    {
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
        if(GetIsDead(spell.Target))
        {
            effect eRaise = EffectResurrection();
            effect eVis = EffectVisualEffect(VFX_IMP_RAISE_DEAD);
            //Apply raise dead effect and VFX impact
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, spell.Loc);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eRaise, spell.Target);
            ExecuteScript("70_mod_resurrect",OBJECT_SELF);
        }
        else
        {
            if (GetObjectType(spell.Target) == OBJECT_TYPE_PLACEABLE)
            {
                int nStrRef = GetLocalInt(spell.Target,"X2_L_RESURRECT_SPELL_MSG_RESREF");
                if (nStrRef == 0)
                {
                    nStrRef = 83861;
                }
                if (nStrRef != -1)
                {
                     FloatingTextStrRefOnCreature(nStrRef,spell.Caster);
                }
            }
        }
    }
}
