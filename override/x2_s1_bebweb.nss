//::///////////////////////////////////////////////
//:: Bebelith Web
//:: NW_S0_Web.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creates a mass of sticky webs that cling to
    and entangle target who fail a Reflex Save
    Those caught can make a new save every
    round.  Movement in the web is 1/6 normal.
    The higher the creatures Strength the faster
    they move out of the web.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Aug 8, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- was dispellable
*/

#include "70_inc_spells"

void main()
{
    //Declare major variables including Area of Effect Object
    spellsDeclareMajorVariables();
    effect eAOE = EffectAreaOfEffect(AOE_PER_WEB, "x2_s1_bebweba", "x2_s1_bebwebc", "x2_s1_bebwebb");

    int nDuration = GetHitDice(spell.Caster)/2;
    //Make sure duration does no equal 0
    if(nDuration < 1)
    {
        nDuration = 1;
    }
    //Check Extend metamagic feat.
    if(spell.Meta & METAMAGIC_EXTEND)
    {
       nDuration = nDuration *2;    //Duration is +100%
    }
    //Create an instance of the AOE Object using the Apply Effect function
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eAOE), spell.Loc, RoundsToSeconds(nDuration));
    object oAOE = spellsSetupNewAOE("VFX_PER_WEB","x2_s1_bebwebc");
    SetAreaOfEffectUndispellable(oAOE);
}
