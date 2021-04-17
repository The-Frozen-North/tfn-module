//::///////////////////////////////////////////////
//:: Associate: On Spawn In
//:: NW_CH_AC9
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*

This must support the OC henchmen and all summoned/companion
creatures.

*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 19, 2001
//:://////////////////////////////////////////////
//:: Updated By: Georg Zoeller, 2003-08-20: Added variable check for spawn in animation
/*
Patch 1.72
- fixed the henchman distance settings
Patch 1.71
- implemented multi summoning feature
*/

#include "x0_inc_henai"
#include "x2_inc_switches"
#include "inc_ai_combat"

void main_delayed()
{
    object oMaster = GetMaster();
    //1.72: moved into delay as GetMaster is not valid in initial script
    if(GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oMaster) == OBJECT_SELF)
    {
        SetAssociateState(NW_ASC_DISTANCE_2_METERS);
    }
    //1.71: multisummoning feature
    int maxSummonModule = GetModuleSwitchValue("71_UNLIMITED_SUMMONING");
    int maxSummonPC = GetLocalInt(oMaster,"71_UNLIMITED_SUMMONING");
    if(maxSummonModule > 0 || maxSummonPC > 0)
    {
        int maxSummon;
        if(maxSummonModule == 1 || maxSummonPC == 1) maxSummon = 1;
        else maxSummon = maxSummonPC > maxSummonModule ? maxSummonPC : maxSummonModule;

        int numSummon = 1;
        while(GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_SUMMONED,oMaster,numSummon)))
        {
           numSummon++;
        }
        if(numSummon > 2 && (maxSummon == 1 || maxSummon >= numSummon-1))
        {
            object oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED,oMaster,1);
            ExecuteScript("70_ch_multisumm",oSummon);
        }
    }
}

void main()
{
     //Sets up the special henchmen listening patterns
    SetAssociateListenPatterns();

    // Set additional henchman listening patterns
    bkSetListeningPatterns();

    // Default behavior for henchmen at start
    SetAssociateState(NW_ASC_POWER_CASTING);
    SetAssociateState(NW_ASC_HEAL_AT_50);
    SetAssociateState(NW_ASC_RETRY_OPEN_LOCKS);
    SetAssociateState(NW_ASC_DISARM_TRAPS);
    SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, FALSE);


    //Use melee weapons by default
    SetAssociateState(NW_ASC_USE_RANGED_WEAPON, FALSE);

    // Distance: make henchmen stick closer
    SetAssociateState(NW_ASC_DISTANCE_4_METERS);
/*    if (GetAssociate(ASSOCIATE_TYPE_HENCHMAN, GetMaster()) == OBJECT_SELF) {
    SetAssociateState(NW_ASC_DISTANCE_2_METERS);
    }*///1.71: this doesn't work! master always invalid

    // * If Incorporeal, apply changes
    if (GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_IS_INCORPOREAL) == TRUE)
    {
        effect eConceal = EffectConcealment(50, MISS_CHANCE_TYPE_NORMAL);
        effect eGhost = EffectCutsceneGhost();
        effect eKDImmunity = EffectImmunity(IMMUNITY_TYPE_KNOCKDOWN);
        effect eImmunity = EffectImmunity(IMMUNITY_TYPE_ENTANGLE);
        effect eLink = EffectLinkEffects(eConceal,eGhost);
        eLink = EffectLinkEffects(eLink,eKDImmunity);
        eLink = EffectLinkEffects(eLink,eImmunity);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(eLink), OBJECT_SELF);
    }


    // Set starting location
    SetAssociateStartLocation();

    FastBuff();

    //1.72: new way of enforcing unlimited summoning feature
    DelayCommand(0.0,main_delayed());
}
