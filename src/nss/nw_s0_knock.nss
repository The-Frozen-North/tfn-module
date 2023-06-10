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
    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, FALSE, OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    float fDelay;
    int nResist;

    while(GetIsObjectValid(oTarget))
    {
        SignalEvent(oTarget,EventSpellCastAt(spell.Caster,spell.Id));
        fDelay = GetRandomDelay(0.5, 2.5);
        if(GetLocked(oTarget))
        {
            nResist =  GetDoorFlag(oTarget,DOOR_FLAG_RESIST_KNOCK);
            if (nResist == 0 && !GetLockKeyRequired(oTarget))
            {
                int nRoll = d20();
                int nBase = spell.DC - 10;
                int nTotal = nRoll + nBase;
                int nUnlockDC =  GetLockUnlockDC(oTarget);
                string sOutcome = nTotal >= nUnlockDC ? "success" : "failure";
                string sMessage = GetName(spell.Caster)+" : Knock on " + GetName(oTarget) + " : *"+sOutcome+"* : ("+IntToString(nRoll)+" + "+IntToString(nBase)+" = "+IntToString(nTotal)+" vs. DC: "+IntToString(nUnlockDC)+")";
                FloatingTextStringOnCreature(sMessage, spell.Caster);
                if (nTotal >= nUnlockDC)
                {
                    AssignCommand(oTarget, ActionUnlockObject(oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                    DelayCommand(fDelay, AssignCommand(oTarget, PlaySound("gui_picklockopen")));
                }
            }
            else if  (nResist == 1)
            {
                FloatingTextStrRefOnCreature(83887,spell.Caster);
            }
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, FALSE, OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }
}
