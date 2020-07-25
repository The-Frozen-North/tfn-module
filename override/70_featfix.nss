#include "70_inc_nwnx"

void main()
{
    object oPC = OBJECT_SELF;
    object oCreator = GetObjectByTag("70_FEATFIX");
    int darkvision,lowvision;
    if(GetHasFeat(FEAT_DARKVISION,oPC))
    {
        switch(GetRacialType(oPC))
        {
            case RACIAL_TYPE_DWARF:
            case RACIAL_TYPE_HALFORC:
            break;
            default:
            darkvision = TRUE;
            break;
        }
    }
    if(GetHasFeat(FEAT_LOWLIGHTVISION,oPC))
    {
        switch(GetRacialType(oPC))
        {
            case IP_CONST_RACIALTYPE_GNOME:
            case IP_CONST_RACIALTYPE_ELF:
            case IP_CONST_RACIALTYPE_HALFELF:
            break;
            default:
            lowvision = TRUE;
            break;
        }
    }
    int bUpdateRequired = darkvision != GetLocalInt(oPC,"70_applied_darkvision") || lowvision != GetLocalInt(oPC,"70_applied_lowlightvision");
    SetLocalInt(oPC,"70_applied_darkvision",darkvision);
    SetLocalInt(oPC,"70_applied_lowlightvision",lowvision);
    if(bUpdateRequired)
    {
        effect eSearch = NWNXPatch_GetFirstEffect(oPC);
        while(NWNXPatch_GetEffectTrueType(eSearch) != EFFECT_TRUETYPE_INVALIDEFFECT)
        {
            if(GetEffectTag(eSearch) == "EC_FEATFIX")
            {
                RemoveEffect(oPC,eSearch);
            }
            eSearch = NWNXPatch_GetNextEffect(oPC);
        }
    }
    if(darkvision)
    {
        ApplyEffectToObject(DURATION_TYPE_EQUIPPED,TagEffect(NWNXPatch_SetEffectTrueType(EffectVisualEffect(2),69),"EC_FEATFIX"),oPC);
    }
    if(lowvision)
    {
        ApplyEffectToObject(DURATION_TYPE_EQUIPPED,TagEffect(NWNXPatch_SetEffectTrueType(EffectVisualEffect(1),69),"EC_FEATFIX"),oPC);
    }
}
