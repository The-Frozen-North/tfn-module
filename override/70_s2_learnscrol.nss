//::///////////////////////////////////////////////
//:: Scroll Learning
//:: 70_s2_learnscrol
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
This script implements learning spells from scrolls.

Currently its merely a transcription of the bioware hardcoded code into NWScript
without any extra features. If you want to add scroll learning to some custom class
you need to modify this script and handle it yourself.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow
//:: Created On: 25-2-2016
//:://////////////////////////////////////////////

#include "70_inc_nwnx"
#include "70_inc_spells"

void main()
{
    //Declare major variables
    object oPC = OBJECT_SELF;
    object oItem = GetLocalObject(oPC,"LEARNSCROLL_ITEMID");
    if(GetIsObjectValid(oItem) && GetBaseItemType(oItem) == BASE_ITEM_SPELLSCROLL)
    {
        if(GetItemPossessor(oItem) == oPC)
        {
            itemproperty ip = GetFirstItemProperty(oItem);
            while(GetIsItemPropertyValid(ip))
            {
                if(GetItemPropertyType(ip) == ITEM_PROPERTY_CAST_SPELL)
                {
                    int nLevel = GetLevelByClass(CLASS_TYPE_WIZARD,oPC);
                    if(nLevel > 0)
                    {
                        //spell progression value from nwnx_patch
                        SetLocalInt(GetModule(),"NWNXPATCH_RESULT",-1);
                        SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!513",ObjectToString(oPC)+"|"+IntToString(CLASS_TYPE_WIZARD));
                        DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!513");
                        int nMod = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
                        DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
                        if(nMod > 0) nLevel+= nMod;
                        //end of spell progression code
                        string sSpell = Get2DAString("iprp_spells","SpellIndex",GetItemPropertySubType(ip));
                        int nSpell = StringToInt(sSpell);
                        if(!nSpell && sSpell != "0") return;
                        int nSpellLevel = GetSpellLevel(nSpell,CLASS_TYPE_WIZARD);
                        if(nSpellLevel > -1 && nSpellLevel < 10)
                        {
                            string s2DA = Get2DAString("classes","SpellGainTable",CLASS_TYPE_WIZARD);
                            string sNumSpellLevels = Get2DAString(s2DA,"NumSpellLevels",nLevel);
                            if(s2DA != "" && sNumSpellLevels != "" && StringToInt(sNumSpellLevels) > nSpellLevel)
                            {
                                if(GetSpellMinAbilityMet(oPC,CLASS_TYPE_WIZARD,nSpellLevel))
                                {
                                    int nSchool = NWNXPatch_GetSpellSchoolSpecialization(oPC,CLASS_TYPE_WIZARD);
                                    string sOppositeSchool = "~";
                                    switch(nSchool)
                                    {
                                    case SPELL_SCHOOL_ABJURATION:       sOppositeSchool = "C"; break;
                                    case SPELL_SCHOOL_CONJURATION:      sOppositeSchool = "T"; break;
                                    case SPELL_SCHOOL_DIVINATION:       sOppositeSchool = "I"; break;
                                    case SPELL_SCHOOL_ENCHANTMENT:      sOppositeSchool = "I"; break;
                                    case SPELL_SCHOOL_EVOCATION:        sOppositeSchool = "C"; break;
                                    case SPELL_SCHOOL_ILLUSION:         sOppositeSchool = "E"; break;
                                    case SPELL_SCHOOL_NECROMANCY:       sOppositeSchool = "D"; break;
                                    case SPELL_SCHOOL_TRANSMUTATION:    sOppositeSchool = "C"; break;
                                    }
                                    if(nSchool == SPELL_SCHOOL_GENERAL || Get2DAString("spells","School",nSpell) != sOppositeSchool)
                                    {
                                        if(!NWNXPatch_GetKnowsSpell(oPC,CLASS_TYPE_WIZARD,nSpell))
                                        {
                                            NWNXPatch_AddKnownSpell(oPC,CLASS_TYPE_WIZARD,nSpell);
                                            if(GetItemStackSize(oItem) > 1)
                                            {
                                                SetItemStackSize(oItem,GetItemStackSize(oItem)-1);
                                            }
                                            else
                                            {
                                                DestroyObject(oItem);
                                            }
                                            SetCustomToken(0,GetStringByStrRef(StringToInt(Get2DAString("spells","Name",nSpell))));
                                            SendMessageToPCByStrRef(oPC,53307);//<CUSTOM0> has been added to your spellbook.
                                            return;
                                        }
                                        else
                                        {
                                            SendMessageToPCByStrRef(oPC,53308);//You already have that spell in your spellbook.
                                            return;
                                        }
                                    }
                                    else
                                    {
                                        SendMessageToPCByStrRef(oPC,68614);//You cannot learn spells from your school of opposition.
                                        return;
                                    }
                                }
                                else
                                {
                                    SendMessageToPCByStrRef(oPC,68613);//You do not have the minimum attribute required to learn this spell.
                                    return;
                                }
                            }
                            else
                            {
                                SendMessageToPCByStrRef(oPC,68612);//You have not achieved the required level to learn that spell.
                                return;
                            }
                        }
                        else
                        {
                            SendMessageToPCByStrRef(oPC,68661);//You can only learn Arcane spells.
                            return;
                        }
                    }
                    else
                    {
                        SendMessageToPCByStrRef(oPC,68611);//Only Wizards may learn spells in that manner.
                        return;
                    }
                    break;
                }
                ip = GetNextItemProperty(oItem);
            }
        }
        else
        {
            SendMessageToPCByStrRef(oPC,53310);//You do not possess that item.
            return;
        }
    }
    SendMessageToPCByStrRef(oPC,53309);//You cannnot learn anything from that item.
}
