//::///////////////////////////////////////////////
//:: Time Stop
//:: NW_S0_TimeStop.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All persons in the Area are frozen in time
    except the caster.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:://////////////////////////////////////////////
/*
Patch 1.72
- added immunity feature - builder can now make creatures immune to the time stop (in case
there is a monster with immunity in singleplayer, spell will force multiplayer behavior)
Patch 1.70
- in MP environment, spell affect only current area
*/

//#include "70_inc_nwnx"
#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_SECONDS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nRoll = 1 + d4();
    int bForceMPbehavior = FALSE;
    int nTh = 1;

    /*
    effect eTemp = EffectSanctuary(55);
    effect eIcon = NWNXPatch_SetEffectTrueType(eTemp,EFFECT_TRUETYPE_ICON);
    int bNWNXInUse = GetEffectType(eIcon) == EFFECT_TYPE_INVALIDEFFECT;
    */
    effect eTime, eVis = EffectVisualEffect(VFX_FNF_TIME_STOP);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, GetLocation(spell.Caster));

    object oTarget = GetNearestObject(OBJECT_TYPE_CREATURE, spell.Caster, nTh);
    while(GetIsObjectValid(oTarget))
    {
        if(GetLocalInt(oTarget,"IMMUNITY_TIMESTOP"))
        {
            bForceMPbehavior = TRUE;//if someone has immunity, force multiplayer mode
            break;
        }
        oTarget = GetNearestObject(OBJECT_TYPE_CREATURE, spell.Caster, ++nTh);
    }

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Caster, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    if(GetPCPublicCDKey(GetFirstPC(),FALSE) == "" && !bForceMPbehavior)//SP environment, keep default effect
    {
        eTime = EffectTimeStop();
        //Apply the VFX impact and effects
        DelayCommand(0.75, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTime, spell.Caster, DurationToSeconds(9)));
    }
    else//MP environment, use cutscene paralyse for all creatures in caster's area
    {
        eTime = EffectLinkEffects(EffectCutsceneParalyze(), EffectVisualEffect(VFX_DUR_BLUR));
        eTime = ExtraordinaryEffect(EffectLinkEffects(eTime, EffectVisualEffect(VFX_DUR_FREEZE_ANIMATION)));
        /*
        if(bNWNXInUse)
        {
            //shows a timestop icon
            eTime = EffectLinkEffects(eTime,eIcon);
        }
        */
        nTh = 1;
        oTarget = GetNearestObject(OBJECT_TYPE_CREATURE, spell.Caster, nTh);
        while(GetIsObjectValid(oTarget))
        {
            if(oTarget != spell.Caster && !GetIsDM(oTarget) && !GetLocalInt(oTarget,"IMMUNITY_TIMESTOP"))
            {
                DelayCommand(0.75, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTime, oTarget, DurationToSeconds(9)));
            }
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
            oTarget = GetNearestObject(OBJECT_TYPE_CREATURE, spell.Caster, ++nTh);
        }
    }
}
