//::///////////////////////////////////////////////
//:: Community Patch 1.72 Spellhook Library
//:: 70_inc_spellhook
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
This include contains a special functions used in internal spellhook. Since Community Patch
aiming for maximum compatibility, I had to create a special include for them even when
they would normally fit the x2_inc_spellhook library. But if some module contained a
modified version of this library, compiling AI scripts might fail with compile error.

Thats why these functions must stay here.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow
//:: Created On: 26-06-2018
//:://////////////////////////////////////////////

#include "x2_inc_switches"

//private function for 70_spellhook/x2_inc_spellhook
int MusicalInstrumentsCheck(object oItem)
{
    int bRulesApply = GetGameDifficulty() >= GAME_DIFFICULTY_CORE_RULES;
    if(bRulesApply)
    {
        int nSwitch = GetLocalInt(oItem,"71_RESTRICT_MUSICAL_INSTRUMENTS");
        if(!nSwitch)
        {
            nSwitch = GetModuleSwitchValue("71_RESTRICT_MUSICAL_INSTRUMENTS");
        }
        if(nSwitch & 1)//perform based
        {
            if(GetSkillRank(SKILL_PERFORM) > -1)
            {
                int nDC = GetLocalInt(oItem,"MUSICAL_INSTRUMENT_DC");
                if(!nDC)
                {
                    nDC = 7+3*StringToInt(Get2DAString("des_crft_spells","Level",GetSpellId()));
                }
                if(!GetIsSkillSuccessful(OBJECT_SELF, SKILL_PERFORM, nDC))
                {
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGIC_RESISTANCE_USE), OBJECT_SELF);
                    return FALSE;
                }
            }
            else
            {
                FloatingTextStrRefOnCreature(8288,OBJECT_SELF,FALSE);//you cannot use this skill
                return FALSE;
            }
        }
        if(nSwitch & 2)//song feat based
        {
            if(GetHasFeat(FEAT_BARD_SONGS))
            {
                DecrementRemainingFeatUses(OBJECT_SELF,FEAT_BARD_SONGS);
            }
            else
            {
                FloatingTextStrRefOnCreature(40063,OBJECT_SELF,FALSE);
                return FALSE;
            }
        }
    }
    int bDeaf;
    effect eSearch = GetNextEffect(OBJECT_SELF);//part1 check for silence effect
    while(GetIsEffectValid(eSearch))
    {
        switch(GetEffectType(eSearch))
        {
            case EFFECT_TYPE_SILENCE:
            FloatingTextStrRefOnCreature(85764,OBJECT_SELF); // not useable when silenced
            return FALSE;
            case EFFECT_TYPE_DEAF:
            bDeaf = TRUE;
            break;
        }
        eSearch = GetNextEffect(OBJECT_SELF);
    }
    if(bDeaf && bRulesApply && d100() < 21)// 20% chance to fail under deafness
    {
        FloatingTextStrRefOnCreature(83576,OBJECT_SELF); //* You can not concentrate on using this ability effectively *
        return FALSE;
    }
    string music = GetLocalString(oItem,"MUSICAL_INSTRUMENT_SOUND");
    if(music == "")
    {
        music = "sdr_bardsong";
    }
    PlaySound(music);
    return TRUE;
}
