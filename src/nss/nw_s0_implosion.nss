//::///////////////////////////////////////////////
//:: Implosion
//:: NW_S0_Implosion.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All persons within a 5ft radius of the spell must
    save at +3 DC or die.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: April 13, 2001
//:://////////////////////////////////////////////
/*
Patch 1.72
- added a special workaround that will fix the "no roll auto death" issue when this spell
is modified to affect caster and he casts it under himself with death immunity
Patch 1.71
- implosion has no effect on creatures in gaseous form or on incorporeal creatures.
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

int MySavingThrow2(int nSavingThrow, object oTarget, int nDC, int nSaveType=SAVING_THROW_TYPE_NONE, object oSaveVersus = OBJECT_SELF, float fDelay = 0.0);

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Range = RADIUS_SIZE_MEDIUM;
    spell.SavingThrow = SAVING_THROW_FORT;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    object oTarget;
    effect eDeath = EffectDeath(TRUE);
    eDeath = SupernaturalEffect(eDeath);
    effect eImplode = EffectVisualEffect(VFX_FNF_IMPLOSION);
    float fDelay;
    effect eVis = EffectVisualEffect(VFX_IMP_DEATH);
    //Apply the implose effect
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImplode, spell.Loc);
    //Get the first target in the shape
    oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    while (GetIsObjectValid(oTarget))
    {
        if (oTarget != spell.Caster && spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
           //Fire cast spell at event for the specified target
           SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
           fDelay = GetRandomDelay(0.4, 1.2);
           //incorporeal creatures aren't affected                      //Make SR check
           if (!GetCreatureFlag(oTarget, CREATURE_VAR_IS_INCORPOREAL) && !MyResistSpell(spell.Caster, oTarget, fDelay))
           {
                //Make Reflex save
                if(!MySavingThrow2(spell.SavingThrow, oTarget, spell.DC+3, SAVING_THROW_TYPE_DEATH, spell.Caster, fDelay))
                {
                    //Apply death effect and the VFX impact
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget));
                    //added death visual because the old came from SAVING_THROW_TYPE_DEATH, which is lost now
                    //DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                }
            }
        }
        //Get next target in the shape
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    }
}

/*
Patch 1.70

> Community Patch unified the saving throw function into no-roll if immune behavior which
is an expected behavior and what most saving throws roll does. Saving throw against death
was the exception most probably because of this spell, so this has to be workarounded by
adding a custom function that will keep default behavior. Another choice was to change save
type to NONE (which is what it should be actually) but that would be actually a huge buff to
the aoe death spell with no immunity and highest DC in the game.*/
int MySavingThrow2(int nSavingThrow, object oTarget, int nDC, int nSaveType=SAVING_THROW_TYPE_NONE, object oSaveVersus = OBJECT_SELF, float fDelay = 0.0)
{
    if(oTarget == oSaveVersus) nSaveType = SAVING_THROW_TYPE_NONE;
    // -------------------------------------------------------------------------
    // GZ: sanity checks to prevent wrapping around
    // -------------------------------------------------------------------------
    if (nDC<1)
    {
       nDC = 1;
    }
    else if (nDC > 255)
    {
      nDC = 255;
    }

    effect eVis;
    int bValid = FALSE;
    if(nSavingThrow == SAVING_THROW_FORT)
    {
        bValid = FortitudeSave(oTarget, nDC, nSaveType, oSaveVersus);
        if(bValid == 1)
        {
            eVis = EffectVisualEffect(VFX_IMP_FORTITUDE_SAVING_THROW_USE);
        }
    }
    else if(nSavingThrow == SAVING_THROW_REFLEX)
    {
        bValid = ReflexSave(oTarget, nDC, nSaveType, oSaveVersus);
        if(bValid == 1)
        {
            eVis = EffectVisualEffect(VFX_IMP_REFLEX_SAVE_THROW_USE);
        }
    }
    else if(nSavingThrow == SAVING_THROW_WILL)
    {
        bValid = WillSave(oTarget, nDC, nSaveType, oSaveVersus);
        if(bValid == 1)
        {
            eVis = EffectVisualEffect(VFX_IMP_WILL_SAVING_THROW_USE);
        }
    }

    int nSpellID = GetSpellId();

    /*
        return 0 = FAILED SAVE
        return 1 = SAVE SUCCESSFUL
        return 2 = IMMUNE TO WHAT WAS BEING SAVED AGAINST
    */
    if(bValid == 0)
    {
        if(nSaveType == SAVING_THROW_TYPE_DEATH && nSpellID != SPELL_HORRID_WILTING)
        {
            eVis = EffectVisualEffect(VFX_IMP_DEATH);
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
        }
    }
    else //if(bValid == 1 || bValid == 2)
    {
        if(bValid == 2)
        {
            eVis = EffectVisualEffect(VFX_IMP_MAGIC_RESISTANCE_USE);
            /*
            If the spell is save immune then the link must be applied in order to get the true immunity
            to be resisted.  That is the reason for returing false and not true.  True blocks the
            application of effects.
            */
            bValid = FALSE;
        }
        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
    }
    return bValid;
}
