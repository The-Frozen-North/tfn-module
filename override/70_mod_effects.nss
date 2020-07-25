//::///////////////////////////////////////////////
//:: Community Patch OnEffectApplied/Removed module event script
//:: 70_mod_effects
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
This script runs for custom effects, truetype >= 96 and vanilla effects too if set
by builder inside effects.2da. Fires twice, once when the effect is applied, second
time when the effect is removed.

Can be used to create a new custom effects, first declare some effect, change its
truetype to value above 96, apply the effect and then code what should happen when
effect with this truetype is applied.

Note, if your custom effects needs to apply another effects, you should use
DURATION_TYPE_INNATE to apply them as without it these effects will be accessable
via GetFirst/NextEffect which you don't want to happen.

Functions to use in this event:
NWNXPatch_GetEffectEventEffect - returns effect that triggered this script.
NWNXPatch_TransferEffectValues - manifests any changes done to the effect returned by
above function to the engine (script works only with a copy of this effect and any
changes done will not manifests automatically)
BypassEvent - will block the original engine code to run - use if you intent to
completely rewrite effect code in this script.

Requires running game via NWNX or NWNCX and Community Patch plugin.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.72
//:: Created On: 31-05-2017
//:://////////////////////////////////////////////

#include "70_inc_nwnx"

const int EFFECT_EVENTTYPE_EFFECT_INVALID = 0;
const int EFFECT_EVENTTYPE_EFFECT_APPLIED = 1;
const int EFFECT_EVENTTYPE_EFFECT_REMOVED = 2;

void BypassEvent();

void main()
{
    int nEvent = GetLocalInt(OBJECT_SELF,"EFFECT_EVENT_EVENT_TYPE");
    effect eEffect = NWNXPatch_GetEffectEventEffect();
    int nEffectTrueType = NWNXPatch_GetEffectTrueType(eEffect);
//    SendMessageToPC(OBJECT_SELF,"70_mod_effects with event: "+IntToString(nEvent)+" effect id: "+IntToString(nEffectTrueType));
    if(nEvent == EFFECT_EVENTTYPE_EFFECT_APPLIED)
    {
        if(nEffectTrueType == EFFECT_TRUETYPE_NWNXPATCH_MODIFYBAB)
        {
            if(GetObjectType(OBJECT_SELF) != OBJECT_TYPE_CREATURE) return;
            int duration_type = GetEffectDurationType(eEffect);
            float fDuration = NWNXPatch_GetEffectRemainingDuration(eEffect);
            effect eIcon = EffectHeal(29);
            eIcon = NWNXPatch_SetEffectTrueType(eIcon,EFFECT_TRUETYPE_ICON);
            if(fDuration == 0.0)
            {
                eIcon = NWNXPatch_SetEffectSpellId(eIcon,10000);//to identify this effect comes from
            }
            ApplyEffectToObject(duration_type,eIcon,OBJECT_SELF,fDuration);
        }
        /*
        //custom effect example - will create an effect overriding number of attacks
        else if(nEffectTrueType == 123)
        {
            if(GetObjectType(OBJECT_SELF) != OBJECT_TYPE_CREATURE) return;
            int nValue = NWNXPatch_GetEffectInteger(eEffect,0);
            if(nValue > 0 && nValue < 7)
            {
                SetBaseAttackBonus(nValue);
            }
        }
        */
    }
    else if(nEvent == EFFECT_EVENTTYPE_EFFECT_REMOVED)
    {
        if(nEffectTrueType == EFFECT_TRUETYPE_NWNXPATCH_MODIFYBAB)
        {
            if(GetObjectType(OBJECT_SELF) != OBJECT_TYPE_CREATURE) return;
            effect eSearch = NWNXPatch_GetFirstEffect(OBJECT_SELF);
            int nType = NWNXPatch_GetEffectTrueType(eSearch);
            while(nType != 0)
            {
                if(nType == EFFECT_TRUETYPE_ICON && GetEffectSpellId(eSearch) == 10000)
                {
                    RemoveEffect(OBJECT_SELF,eSearch);
                }
                eSearch = NWNXPatch_GetNextEffect(OBJECT_SELF);
                nType = NWNXPatch_GetEffectTrueType(eSearch);
            }
        }
        /*
        //custom effect example - will remove an effect overriding number of attacks
        else if(nEffectTrueType == 123)
        {
            if(GetObjectType(OBJECT_SELF) != OBJECT_TYPE_CREATURE) return;
            RestoreBaseAttackBonus();
        }
        */
    }
}

void BypassEvent()
{
    SetLocalInt(OBJECT_SELF,"EFFECT_EVENT_BYPASS",1);
}
