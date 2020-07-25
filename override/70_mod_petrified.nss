//::///////////////////////////////////////////////
//:: Community Patch OnPetrified event script
//:: 70_mod_petrified
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
Server primarily as an easy way to enforce persistency, add extra effects,
penalties or even to remove the petrification effect entirely.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.72
//:: Created On: 28-12-2015
//:://////////////////////////////////////////////
#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    int nPower = GetLocalInt(OBJECT_SELF,"Petrify_nPower");
    int nSpellID = GetLocalInt(OBJECT_SELF,"Petrify_nSpellID");
    int nFortSaveDC = GetLocalInt(OBJECT_SELF,"Petrify_nFortSaveDC");
    object oSource = GetLocalObject(OBJECT_SELF,"Petrify_oSource");
    object oTarget = GetLocalObject(OBJECT_SELF,"Petrify_oTarget");

    DeleteLocalObject(OBJECT_SELF,"Petrify_oSource");
    DeleteLocalObject(OBJECT_SELF,"Petrify_oTarget");
    DeleteLocalInt(OBJECT_SELF,"Petrify_nFortSaveDC");
    DeleteLocalInt(OBJECT_SELF,"Petrify_nSpellID");
    DeleteLocalInt(OBJECT_SELF,"Petrify_nPower");
    SetExecutedScriptReturnValue();

    // * exit if creature is immune to petrification
    if(spellsIsImmuneToPetrification(oTarget))
    {
        //engine workaround for immunity feedback
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSpellImmunity(nSpellID), oTarget, 0.01);
    }
    if(MyResistSpell(oSource,oTarget) > 0)
    {
        return;
    }
    float fDifficulty = 0.0;
    int bShowPopup = FALSE;
    effect ePetrify = EffectPetrify();
    // * calculate Duration based on difficulty settings
    switch(GetGameDifficulty())
    {
        case GAME_DIFFICULTY_VERY_EASY:
        nPower = nPower/2;
        case GAME_DIFFICULTY_EASY:
        case GAME_DIFFICULTY_NORMAL:
            fDifficulty = RoundsToSeconds(nPower < 1 ? 1 : nPower); // One Round per hit-die or caster level
        break;
        case GAME_DIFFICULTY_CORE_RULES:
        case GAME_DIFFICULTY_DIFFICULT:
            bShowPopup = TRUE;
        break;
    }

    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects(eDur, ePetrify);

    // Do a fortitude save check
    if(!MySavingThrow(SAVING_THROW_FORT, oTarget, nFortSaveDC, SAVING_THROW_TYPE_NONE, oSource))
    {
        if(GetPlotFlag(oTarget) || GetImmortal(oTarget)) return; //1.71: dont do anything else for plot/immortal, caused action cancel before
        // Save failed; apply paralyze effect and VFX impact
        /// * The duration is permanent against NPCs but only temporary against PCs
        if(GetIsPC(oTarget))
        {
            if(bShowPopup)
            {
                // * under hardcore rules or higher, this is an instant death
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
                DelayCommand(2.75, PopUpDeathGUIPanel(oTarget, FALSE , TRUE, 40579));
                // if in hardcore, treat the player as an NPC
                //bIsPC = FALSE;
                //fDifficulty = TurnsToSeconds(nPower); // One turn per hit-die
            }
            else
            {
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, fDifficulty);
            }
        }
        else
        {
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
            //----------------------------------------------------------
            // GZ: Fix for henchmen statues haunting you when changing
            //     areas. Henchmen are now kicked from the party if
            //     petrified.
            //----------------------------------------------------------
            if (GetAssociateType(oTarget) == ASSOCIATE_TYPE_HENCHMAN)
            {
                FireHenchman(GetMaster(oTarget),oTarget);
            }
        }
        // April 2003: Clearing actions to kick them out of conversation when petrified
        AssignCommand(oTarget, ClearAllActions(TRUE));
    }
}
