//::///////////////////////////////////////////////
//:: Knock
//:: NW_S0_Knock
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Opens doors not locked by magical means.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 29, 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Georg 2003/07/31 - Added signal event and custom door flags
//:: VFX Pass By: Preston W, On: June 22, 2001

#include "70_inc_spells"
#include "nw_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Range = 50.0;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    object oTarget;
    effect eVis = EffectVisualEffect(VFX_IMP_KNOCK);
    oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, FALSE, OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    float fDelay;
    int nResist;

    while(GetIsObjectValid(oTarget))
    {
        SignalEvent(oTarget,EventSpellCastAt(spell.Caster,spell.Id));
        fDelay = GetRandomDelay(0.5, 2.5);
        if(!GetPlotFlag(oTarget) && GetLocked(oTarget))
        {
            nResist =  GetDoorFlag(oTarget,DOOR_FLAG_RESIST_KNOCK);
            if (nResist == 0)
            {
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                AssignCommand(oTarget, ActionUnlockObject(oTarget));
            }
            else if  (nResist == 1)
            {
                FloatingTextStrRefOnCreature(83887,spell.Caster);
            }
        }
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, FALSE, OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }
}
