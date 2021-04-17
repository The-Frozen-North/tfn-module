//::///////////////////////////////////////////////
//:: Summon Creature Series
//:: NW_S0_Summon
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Carries out the summoning of the appropriate
    creature for the Summon Monster Series of spells
    1 to 9
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 8, 2002
//:://////////////////////////////////////////////
/*
Patch 1.71

- the animal domain power doesn't work anymore when the spell is cast from an item
*/

effect SetSummonEffect(int nSpellID, int bAnimalDomain);

#include "70_inc_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_HOURS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDuration = 24;

    effect eSummon = SetSummonEffect(spell.Id,spell.Item == OBJECT_INVALID && GetHasFeat(FEAT_ANIMAL_DOMAIN_POWER,spell.Caster));

    //Make metamagic check for extend
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2;   //Duration is +100%
    }
    //Apply the VFX impact and summon effect

    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSummon, spell.Loc, DurationToSeconds(nDuration));
}


effect SetSummonEffect(int nSpellID, int bAnimalDomain)
{
    int nFNF_Effect;
    int nRoll = d3();
    string sSummon;
    if(bAnimalDomain) //WITH THE ANIMAL DOMAIN
    {
        if(nSpellID == SPELL_SUMMON_CREATURE_I)
        {
            nFNF_Effect = VFX_FNF_SUMMON_MONSTER_1;
            sSummon = "NW_S_BOARDIRE";
        }
        else if(nSpellID == SPELL_SUMMON_CREATURE_II)
        {
            nFNF_Effect = VFX_FNF_SUMMON_MONSTER_1;
            sSummon = "NW_S_WOLFDIRE";
        }
        else if(nSpellID == SPELL_SUMMON_CREATURE_III)
        {
            nFNF_Effect = VFX_FNF_SUMMON_MONSTER_1;
            sSummon = "NW_S_SPIDDIRE";
        }
        else if(nSpellID == SPELL_SUMMON_CREATURE_IV)
        {
            nFNF_Effect = VFX_FNF_SUMMON_MONSTER_2;
            sSummon = "NW_S_beardire";
        }
        else if(nSpellID == SPELL_SUMMON_CREATURE_V)
        {
            nFNF_Effect = VFX_FNF_SUMMON_MONSTER_2;
            sSummon = "NW_S_diretiger";
        }
        else if(nSpellID == SPELL_SUMMON_CREATURE_VI)
        {
            nFNF_Effect = VFX_FNF_SUMMON_MONSTER_3;
            switch (nRoll)
            {
                case 1:
                    sSummon = "NW_S_AIRHUGE";
                break;

                case 2:
                    sSummon = "NW_S_WATERHUGE";
                break;

                case 3:
                    sSummon = "NW_S_FIREHUGE";
                break;
            }
        }
        else if(nSpellID == SPELL_SUMMON_CREATURE_VII)
        {
            nFNF_Effect = VFX_FNF_SUMMON_MONSTER_3;
            switch (nRoll)
            {
                case 1:
                    sSummon = "NW_S_AIRGREAT";
                break;

                case 2:
                    sSummon = "NW_S_WATERGREAT";
                break;

                case 3:
                    sSummon = "NW_S_FIREGREAT";
                break;
            }
        }
        else if(nSpellID == SPELL_SUMMON_CREATURE_VIII)
        {
            nFNF_Effect = VFX_FNF_SUMMON_MONSTER_3;
            switch (nRoll)
            {
                case 1:
                    sSummon = "NW_S_AIRELDER";
                break;

                case 2:
                    sSummon = "NW_S_WATERELDER";
                break;

                case 3:
                    sSummon = "NW_S_FIREELDER";
                break;
            }
        }
        else if(nSpellID == SPELL_SUMMON_CREATURE_IX)
        {
            nFNF_Effect = VFX_FNF_SUMMON_MONSTER_3;
            switch (nRoll)
            {
                case 1:
                    sSummon = "NW_S_AIRELDER";
                break;

                case 2:
                    sSummon = "NW_S_WATERELDER";
                break;

                case 3:
                    sSummon = "NW_S_FIREELDER";
                break;
            }
        }
    }
    else  //WITOUT THE ANIMAL DOMAIN
    {
        if(nSpellID == SPELL_SUMMON_CREATURE_I)
        {
            nFNF_Effect = VFX_FNF_SUMMON_MONSTER_1;
            sSummon = "NW_S_badgerdire";
        }
        else if(nSpellID == SPELL_SUMMON_CREATURE_II)
        {
            nFNF_Effect = VFX_FNF_SUMMON_MONSTER_1;
            sSummon = "NW_S_BOARDIRE";
        }
        else if(nSpellID == SPELL_SUMMON_CREATURE_III)
        {
            nFNF_Effect = VFX_FNF_SUMMON_MONSTER_1;
            sSummon = "NW_S_WOLFDIRE";
        }
        else if(nSpellID == SPELL_SUMMON_CREATURE_IV)
        {
            nFNF_Effect = VFX_FNF_SUMMON_MONSTER_2;
            sSummon = "NW_S_SPIDDIRE";
        }
        else if(nSpellID == SPELL_SUMMON_CREATURE_V)
        {
            nFNF_Effect = VFX_FNF_SUMMON_MONSTER_2;
            sSummon = "NW_S_beardire";
        }
        else if(nSpellID == SPELL_SUMMON_CREATURE_VI)
        {
            nFNF_Effect = VFX_FNF_SUMMON_MONSTER_2;
            sSummon = "NW_S_diretiger";
        }
        else if(nSpellID == SPELL_SUMMON_CREATURE_VII)
        {
            nFNF_Effect = VFX_FNF_SUMMON_MONSTER_3;
            switch (nRoll)
            {
                case 1:
                    sSummon = "NW_S_AIRHUGE";
                break;

                case 2:
                    sSummon = "NW_S_WATERHUGE";
                break;

                case 3:
                    sSummon = "NW_S_FIREHUGE";
                break;
            }
        }
        else if(nSpellID == SPELL_SUMMON_CREATURE_VIII)
        {
            nFNF_Effect = VFX_FNF_SUMMON_MONSTER_3;
            switch (nRoll)
            {
                case 1:
                    sSummon = "NW_S_AIRGREAT";
                break;

                case 2:
                    sSummon = "NW_S_WATERGREAT";
                break;

                case 3:
                    sSummon = "NW_S_FIREGREAT";
                break;
            }
        }
        else if(nSpellID == SPELL_SUMMON_CREATURE_IX)
        {
            nFNF_Effect = VFX_FNF_SUMMON_MONSTER_3;
            switch (nRoll)
            {
                case 1:
                    sSummon = "NW_S_AIRELDER";
                break;

                case 2:
                    sSummon = "NW_S_WATERELDER";
                break;

                case 3:
                    sSummon = "NW_S_FIREELDER";
                break;
            }
        }
    }
    effect eSummonedMonster = EffectSummonCreature(sSummon, nFNF_Effect);
    return eSummonedMonster;
}
