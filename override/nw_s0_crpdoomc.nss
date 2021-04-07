//::///////////////////////////////////////////////
//:: Creeping Doom: Heartbeat
//:: NW_S0_CrpDoomC.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creature caught in the swarm take an initial
    damage of 1d20, but there after they take
    1d6 per swarm counter on the AOE.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 17, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- did no damage last round where AOE reached 1k dmg
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_PIERCING;
    spell.SR = NO;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();
    int nDamCount = GetLocalInt(aoe.AOE, "NW_SPELL_CONSTANT_CREEPING_DOOM2");
    if(nDamCount >= 1000 || (aoe.Creator != OBJECT_INVALID && !GetIsObjectValid(aoe.Creator)))
    {
        DestroyObject(aoe.AOE);
        return;
    }
    int nSwarm = GetLocalInt(aoe.AOE, "NW_SPELL_CONSTANT_CREEPING_DOOM1")+1;
    int nDamage;
    effect eDam;
    effect eVis = EffectVisualEffect(spell.DmgVfxS);
    float fDelay;

    //Get first target in spell area
    object oTarget = GetFirstInPersistentObject(aoe.AOE);
    while(GetIsObjectValid(oTarget))
    {
        if(spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
        {
            SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
            fDelay = GetRandomDelay(1.0, 2.2);
            //------------------------------------------------------------------
            // According to the book, SR Does not count against creeping doom
            //------------------------------------------------------------------
            //1.72: this will do nothing by default, but allows to dynamically enforce spell resistance
            if (spell.SR != YES || !MyResistSpell(aoe.Creator, oTarget, fDelay))
            {
                //Roll Damage
                nDamage = MaximizeOrEmpower(spell.Dice,nSwarm,METAMAGIC_NONE);
                //Set Damage Effect with the modified damage
                eDam = EffectDamage(nDamage, spell.DamageType);
                //Apply damage and visuals
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                nDamCount = nDamCount + nDamage;
            }
        }
        //Get next target in spell area
        oTarget = GetNextInPersistentObject(aoe.AOE);
    }
    SetLocalInt(aoe.AOE, "NW_SPELL_CONSTANT_CREEPING_DOOM1", nSwarm);
    SetLocalInt(aoe.AOE, "NW_SPELL_CONSTANT_CREEPING_DOOM2", nDamCount);
}
