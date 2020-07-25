//::///////////////////////////////////////////////
//:: Elemental Shape
//:: NW_S2_ElemShape
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Allows the Druid to change into elemental forms.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 22, 2002
//:://////////////////////////////////////////////
//:: Modified By: Deva Winblood
//:: Modified Date: January 15th-16th, 2008
//:://////////////////////////////////////////////
/*
    Modified to insure no shapeshifting spells are castable upon
    mounted targets.  This prevents problems that can occur due
    to dismounting after shape shifting, or other issues that can
    occur due to preserved appearances getting out of synch.

    This can additional check can be disabled by setting the variable
    X3_NO_SHAPESHIFT_SPELL_CHECK to 1 on the module object.  If this
    variable is set then this script will function as it did prior to
    this modification.

Patch 1.71

- rewritten onto "new polymorph engine"
- cured from horse include while retaining the shapeshifting horse check
*/

#include "70_inc_shifter"
#include "x2_inc_itemprop"

void main()
{
    //Declare major variables
    int nSpell = GetSpellId();
    object oTarget = GetSpellTargetObject();
    effect eVis = EffectVisualEffect(VFX_IMP_POLYMORPH);
    effect ePoly;
    int nPoly;
    int nDuration = GetLevelByClass(CLASS_TYPE_DRUID); //GetCasterLevel(OBJECT_SELF);
    int bElder = FALSE;
    if (!GetLocalInt(GetModule(),"X3_NO_SHAPESHIFT_SPELL_CHECK"))
    { // check to see if abort due to being mounted
        switch(GetPhenoType(oTarget))
        {// shape shifting not allowed while mounted
            case 3:
            case 5:
            case 6:
            case 8:
            if(GetIsPC(oTarget))
            {
                FloatingTextStrRefOnCreature(111982,oTarget,FALSE);
            }
            // shape shifting not allowed while mounted
            return;
        }
    } // check to see if abort due to being mounted
    if(GetLevelByClass(CLASS_TYPE_DRUID) >= 20)
    {
        bElder = TRUE;
    }
    //Determine Polymorph subradial type
    if(bElder == FALSE)
    {
        if(nSpell == 397)
        {
            nPoly = POLYMORPH_TYPE_HUGE_FIRE_ELEMENTAL;
        }
        else if (nSpell == 398)
        {
            nPoly = POLYMORPH_TYPE_HUGE_WATER_ELEMENTAL;
        }
        else if (nSpell == 399)
        {
            nPoly = POLYMORPH_TYPE_HUGE_EARTH_ELEMENTAL;
        }
        else if (nSpell == 400)
        {
            nPoly = POLYMORPH_TYPE_HUGE_AIR_ELEMENTAL;
        }
    }
    else
    {
        if(nSpell == 397)
        {
            nPoly = POLYMORPH_TYPE_ELDER_FIRE_ELEMENTAL;
        }
        else if (nSpell == 398)
        {
            nPoly = POLYMORPH_TYPE_ELDER_WATER_ELEMENTAL;
        }
        else if (nSpell == 399)
        {
            nPoly = POLYMORPH_TYPE_ELDER_EARTH_ELEMENTAL;
        }
        else if (nSpell == 400)
        {
            nPoly = POLYMORPH_TYPE_ELDER_AIR_ELEMENTAL;
        }
    }
    //Fire cast spell at event for the specified target
    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_ELEMENTAL_SHAPE, FALSE));

    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF);
    //1.72: new polymorph engine - handles all the magic around polymorph automatically now
    ApplyPolymorph(OBJECT_SELF, nPoly, SUBTYPE_EXTRAORDINARY, HoursToSeconds(nDuration));
}
