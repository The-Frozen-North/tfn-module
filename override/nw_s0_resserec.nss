//::///////////////////////////////////////////////
//:: [Ressurection]
//:: [NW_S0_Ressurec.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Brings a character back to life with full
//:: health.
//:: When cast on placeables, you get a default error message.
//::   * You can specify a different message in
//::      X2_L_RESURRECT_SPELL_MSG_RESREF
//::   * You can turn off the message by setting the variable
//::     to -1
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 31, 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Georg Z on 2003-07-31
//:: VFX Pass By: Preston W, On: June 22, 2001
/*
Patch 1.72

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
        if (GetIsDead(spell.Target))
        {
            //Declare major variables
            int nHealed = GetMaxHitPoints(spell.Target);
            effect eRaise = EffectResurrection();
            effect eHeal = EffectHeal(nHealed + 10);
            effect eVis = EffectVisualEffect(VFX_IMP_RAISE_DEAD);
            //Apply the heal, raise dead and VFX impact effect
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eRaise, spell.Target);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, spell.Target);
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, spell.Loc);
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
