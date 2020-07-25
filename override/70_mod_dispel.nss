//::///////////////////////////////////////////////
//:: Community Patch OnDispel event script
//:: 70_mod_dispel
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
This script implementes vanilla dispel effect. The purpose of this script is to
allow modifications into dispelling without need to alter spellscripts.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.72
//:: Created On: 06-06-2018
//:://////////////////////////////////////////////

#include "x0_i0_spells"

void main()
{
    //declare major variables
    object oCaster = OBJECT_SELF;
    object oTarget = GetLocalObject(oCaster,"Dispell_oTarget");
    int bAll = GetLocalInt(oCaster,"Dispell_bAll");
    int bBreachSpells = GetLocalInt(oCaster,"Dispell_bBreachSpells");
    int nId = GetLocalInt(oCaster,"Dispell_nId");
    int nCasterLevel = GetLocalInt(oCaster,"Dispell_nCasterLevel");
    float fDelay = GetLocalFloat(oCaster,"Dispell_fDelay");
    effect eDispel;

    DeleteLocalObject(oCaster,"Dispell_oTarget");
    DeleteLocalInt(oCaster,"Dispell_bAll");
    DeleteLocalInt(oCaster,"Dispell_bBreachSpells");
    DeleteLocalInt(oCaster,"Dispell_nId");
    DeleteLocalInt(oCaster,"Dispell_nCasterLevel");
    DeleteLocalFloat(oCaster,"Dispell_fDelay");
    SetExecutedScriptReturnValue();

    if (bAll)
    {
        eDispel = EffectDispelMagicAll(nCasterLevel);
        //----------------------------------------------------------------------
        // GZ: Support for Mord's disjunction
        //----------------------------------------------------------------------
        if (bBreachSpells)
        {
            DoSpellBreach(oTarget, 6, 10, nId);
        }
    }
    else
    {
        eDispel = EffectDispelMagicBest(nCasterLevel);
        if (bBreachSpells)
        {
           DoSpellBreach(oTarget, 2, 10, nId);
        }
    }

    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDispel, oTarget));
}
