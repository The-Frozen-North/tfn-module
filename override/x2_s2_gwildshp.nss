//::///////////////////////////////////////////////
//:: Greater Wild Shape, Humanoid Shape
//:: x2_s2_gwildshp
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Allows the character to shift into one of these
    forms, gaining special abilities

    Credits must be given to mr_bumpkin from the NWN
    community who had the idea of merging item properties
    from weapon and armor to the creatures new forms.

*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: 2003-07-02
//:://////////////////////////////////////////////
//:: Modified By: Deva Winblood
//:: Modified Date: January 26th, 2008
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

Patch 1.72

- rewritten onto "new polymorph engine"
- added benefits of being incorporeal to the spectre shape (50% concealment and
the ability to walk through other creatures)
- a spectre polymorph now also release character from the effects of the grappling
- cured from horse include while retaining the shapeshifting horse check
*/

#include "70_inc_shifter"
#include "x2_inc_itemprop"
#include "x2_inc_shifter"
#include "x3_inc_horse"


void main()
{
    //--------------------------------------------------------------------------
    // Declare major variables
    //--------------------------------------------------------------------------
    int    nSpell = GetSpellId();
    object oTarget = GetSpellTargetObject();
    effect eVis = EffectVisualEffect(VFX_IMP_POLYMORPH);
    int    nShifter = GetLevelByClass(CLASS_TYPE_SHIFTER);
    effect ePoly;
    int    nPoly;

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

    // Feb 13, 2004, Jon: Added scripting to take care of case where it's an NPC
    // using one of the feats. It will randomly pick one of the shapes associated
    // with the feat.
    switch(nSpell)
    {
        // Greater Wildshape I
        case 646: nSpell = Random(5)+658; break;
        // Greater Wildshape II
        case 675: switch(Random(3))
                  {
                    case 0: nSpell = 672; break;
                    case 1: nSpell = 678; break;
                    case 2: nSpell = 680;
                  }
                  break;
        // Greater Wildshape III
        case 676: switch(Random(3))
                  {
                    case 0: nSpell = 670; break;
                    case 1: nSpell = 673; break;
                    case 2: nSpell = 674;
                  }
                  break;
        // Greater Wildshape IV
        case 677: switch(Random(3))
                  {
                    case 0: nSpell = 679; break;
                    case 1: nSpell = 691; break;
                    case 2: nSpell = 694;
                  }
                  break;
        // Humanoid Shape
        case 681:  nSpell = Random(3)+682; break;
        // Undead Shape
        case 685:  nSpell = Random(3)+704; break;
        // Dragon Shape
        case 725:  nSpell = Random(3)+707; break;
        // Outsider Shape
        case 732:  nSpell = Random(3)+733; break;
        // Construct Shape
        case 737:  nSpell = Random(3)+738; break;
    }

    //--------------------------------------------------------------------------
    // Determine which form to use based on spell id, gender and level
    //--------------------------------------------------------------------------
    switch (nSpell)
    {

        //-----------------------------------------------------------------------
        // Greater Wildshape I - Wyrmling Shape
        //-----------------------------------------------------------------------
        case 658:  nPoly = POLYMORPH_TYPE_WYRMLING_RED; break;
        case 659:  nPoly = POLYMORPH_TYPE_WYRMLING_BLUE; break;
        case 660:  nPoly = POLYMORPH_TYPE_WYRMLING_BLACK; break;
        case 661:  nPoly = POLYMORPH_TYPE_WYRMLING_WHITE; break;
        case 662:  nPoly = POLYMORPH_TYPE_WYRMLING_GREEN; break;

        //-----------------------------------------------------------------------
        // Greater Wildshape II  - Minotaur, Gargoyle, Harpy
        //-----------------------------------------------------------------------
        case 672: if (nShifter < X2_GW2_EPIC_THRESHOLD)
                     nPoly = POLYMORPH_TYPE_HARPY;
                  else
                     nPoly = 97;
                  break;

        case 678: if (nShifter < X2_GW2_EPIC_THRESHOLD)
                     nPoly = POLYMORPH_TYPE_GARGOYLE;
                  else
                     nPoly = 98;
                  break;

        case 680: if (nShifter < X2_GW2_EPIC_THRESHOLD)
                     nPoly = POLYMORPH_TYPE_MINOTAUR;
                  else
                     nPoly = 96;
                  break;

        //-----------------------------------------------------------------------
        // Greater Wildshape III  - Drider, Basilisk, Manticore
        //-----------------------------------------------------------------------
        case 670: if (nShifter < X2_GW3_EPIC_THRESHOLD)
                     nPoly = POLYMORPH_TYPE_BASILISK;
                  else
                     nPoly = 99;
                  break;

        case 673: if (nShifter < X2_GW3_EPIC_THRESHOLD)
                     nPoly = POLYMORPH_TYPE_DRIDER;
                  else
                     nPoly = 100;
                  break;

        case 674: if (nShifter < X2_GW3_EPIC_THRESHOLD)
                     nPoly = POLYMORPH_TYPE_MANTICORE;
                  else
                     nPoly = 101;
                  break;

       //-----------------------------------------------------------------------
       // Greater Wildshape IV - Dire Tiger, Medusa, MindFlayer
       //-----------------------------------------------------------------------
        case 679: nPoly = POLYMORPH_TYPE_MEDUSA; break;
        case 691: nPoly = 68; break; // Mindflayer
        case 694: nPoly = 69; break; // DireTiger


       //-----------------------------------------------------------------------
       // Humanoid Shape - Kobold Commando, Drow, Lizard Crossbow Specialist
       //-----------------------------------------------------------------------
       case 682:
                 if(nShifter< 17)
                 {
                     if (GetGender(OBJECT_SELF) == GENDER_MALE) //drow
                         nPoly = 59;
                     else
                         nPoly = 70;
                 }
                 else
                 {
                     if (GetGender(OBJECT_SELF) == GENDER_MALE) //drow
                         nPoly = 105;
                     else
                         nPoly = 106;
                 }
                 break;
       case 683:
                 if(nShifter< 17)
                 {
                    nPoly = 82; break; // Lizard
                 }
                 else
                 {
                    nPoly =104; break; // Epic Lizard
                 }
       case 684: if(nShifter< 17)
                 {
                    nPoly = 83; break; // Kobold Commando
                 }
                 else
                 {
                    nPoly = 103; break; // Kobold Commando
                 }

       //-----------------------------------------------------------------------
       // Undead Shape - Spectre, Risen Lord, Vampire
       //-----------------------------------------------------------------------
       case 704: nPoly = 75; break; // Risen lord

       case 705: if (GetGender(OBJECT_SELF) == GENDER_MALE) // vampire
                     nPoly = 74;
                  else
                     nPoly = 77;
                 break;

       case 706: nPoly = 76; break; /// spectre

       //-----------------------------------------------------------------------
       // Dragon Shape - Red Blue and Green Dragons
       //-----------------------------------------------------------------------
       case 707: nPoly = 72; break; // Ancient Red   Dragon
       case 708: nPoly = 71; break; // Ancient Blue  Dragon
       case 709: nPoly = 73; break; // Ancient Green Dragon


       //-----------------------------------------------------------------------
       // Outsider Shape - Rakshasa, Azer Chieftain, Black Slaad
       //-----------------------------------------------------------------------
       case 733:   if (GetGender(OBJECT_SELF) == GENDER_MALE) //azer
                      nPoly = 85;
                    else // anything else is female
                      nPoly = 86;
                    break;

       case 734:   if (GetGender(OBJECT_SELF) == GENDER_MALE) //rakshasa
                      nPoly = 88;
                    else // anything else is female
                      nPoly = 89;
                    break;

       case 735: nPoly =87; break; // slaad

       //-----------------------------------------------------------------------
       // Construct Shape - Stone Golem, Iron Golem, Demonflesh Golem
       //-----------------------------------------------------------------------
       case 738: nPoly =91; break; // stone golem
       case 739: nPoly =92; break; // demonflesh golem
       case 740: nPoly =90; break; // iron golem

    }
    //--------------------------------------------------------------------------
    // Here the actual polymorphing is done
    //--------------------------------------------------------------------------
    if(nPoly == 76)//1.71: in a spectre polymorph, player releases from any kind of grapple
    {
        if(GetHasSpellEffect(SPELL_BIGBYS_CRUSHING_HAND))
        {
            RemoveEffectsFromSpell(OBJECT_SELF, SPELL_BIGBYS_CRUSHING_HAND);
        }
        if(GetHasSpellEffect(SPELL_BIGBYS_GRASPING_HAND))
        {
            RemoveEffectsFromSpell(OBJECT_SELF, SPELL_BIGBYS_GRASPING_HAND);
        }
        RemoveSpecificEffect(EFFECT_TYPE_ENTANGLE,OBJECT_SELF);
    }
    //Fire cast spell at event for the specified target
    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), FALSE));

    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF);
    //1.72: new polymorph engine - handles all the magic around polymorph automatically now
    ApplyPolymorph(OBJECT_SELF, nPoly, SUBTYPE_EXTRAORDINARY);

    //--------------------------------------------------------------------------
    // Set artificial usage limits for special ability spells to work around
    // the engine limitation of not being able to set a number of uses for
    // spells in the polymorph radial
    //--------------------------------------------------------------------------
    ShifterSetGWildshapeSpellLimits(nSpell);
}
