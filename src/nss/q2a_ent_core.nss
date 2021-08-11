//::///////////////////////////////////////////////
//:: Name q2a_ent_core
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
        Function to set up layout for battle 2
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: Sept 3/03
//:://////////////////////////////////////////////
#include "x2_inc_globals"
void CreateHerald(object oPC);

void main()
{
    if (GetLocalInt(GetModule(), "X2_Q2AnBattle2Spawn") == 1)
        return;

    object oPC = GetEnteringObject();
    if (GetIsDM(oPC) == TRUE)
        return;
    if (GetIsPC(oPC) == FALSE)
        return;


    //Ok - we need to do a plot check whenever the PC enters the zone - in case they
    //come back from the boat trip having done another plot.  After the 1st and 3rd
    //plots are done - we run a cutscene (q7_cut702  and then q7_cut703)

    //if the PC has spoken to the seer about the siege - nothing else needs happen here
    //this variable is set in the Seer's conversation when she sends the PC off to the siege
    if (GetLocalInt(GetModule(), "X2_StartSeerSiegeSpeech") != 2)
    {
        int nCount = 0;
        //First - check to see if any new plots have been completed
        //Shattered Mirror
        if (GetLocalInt(GetModule(), "q6_city_gone") == 1)
        {
            if (GetLocalInt(GetModule(), "X2_nShatteredMirrorCounted") != 1)
            {
                SetLocalInt(GetModule(), "X2_nShatteredMirrorCounted", 1);
                nCount++;
            }
        }
        //Hive Mother
        if (GetLocalInt(GetModule(), "x2_plot_beholders_out") == 1)
        {
            if (GetLocalInt(GetModule(), "X2_nHiveMotherCounted") != 1)
            {
                SetLocalInt(GetModule(), "X2_nHiveMotherCounted", 1);
                nCount++;
            }
        }
        //Isle of the Maker
        if (GetLocalInt(GetModule(), "x2_plot_golem1_in") == 1 ||
            GetLocalInt(GetModule(), "x2_plot_golem2_in") == 1 ||
            GetLocalInt(GetModule(), "x2_plot_psource") == 1)
        {
            if (GetLocalInt(GetModule(), "X2_nMakerCounted") != 1)
            {
                SetLocalInt(GetModule(), "X2_nMakerCounted", 1);
                nCount++;
            }
        }
        //Slaves to the Overmind
        if (GetLocalInt(GetModule(), "X2_Q2DOvermind") > 0)
        {
            if (GetLocalInt(GetModule(), "X2_nOvermindCounted") != 1)
            {
                SetLocalInt(GetModule(), "X2_nOvermindCounted", 1);
                nCount++;
            }
        }

        //Dracolich
        if (GetLocalInt(GetModule(), "x2_plot_undead_out") == 1)
        {
            if (GetLocalInt(GetModule(), "X2_nDracolichCounted") != 1)
            {
                SetLocalInt(GetModule(), "X2_nDracolichCounted", 1);
                nCount++;
            }
        }
        //Number of Plots done equals previously counted plots + Plots completed in this count
        int nPlotProgress = GetLocalInt(GetModule(), "X2_Chapter2Plots_Done") + nCount;
        SetLocalInt(GetModule(), "X2_Chapter2Plots_Done", nPlotProgress);
        if (nPlotProgress >= 4)
        {
            //When 4 plots have been completed - Sgt Ossyr will appear at 'wp_q2a4plot_sgt'
            //and talk to the player - taking him to the Seer to start the siege
            SetLocalInt(GetModule(), "X2_Chapter2Plots_Done", 6);
            object oSergeant = GetObjectByTag("q2a_prebat_sgt");
            //SetAILevel(oSergeant, AI_LEVEL_NORMAL);
            //AssignCommand(oSergeant, ClearAllActions(TRUE));
            DestroyObject(oSergeant);

            object oTarget = GetNearestObjectByTag("wp_q2a4plot_sgt", oPC);

            object oNewSergeant = CreateObject(OBJECT_TYPE_CREATURE, "q2a_prebat_sgt", GetLocation(oTarget));
            //AssignCommand(oSergeant, JumpToObject(oTarget));
            AssignCommand(oPC, ClearAllActions(TRUE));
            //SetCutsceneMode(oPC, TRUE);
            DelayCommand(2.0, AssignCommand(oPC, ActionMoveToObject(oNewSergeant, FALSE, 2.0)));
            DelayCommand(1.0, AssignCommand(oNewSergeant, ActionStartConversation(oPC)));

        }
        else if (nPlotProgress >= 3 && GetLocalInt(GetModule(), "X2_Cut703Done") != 1)
        {
            SetLocalInt(GetModule(), "X2_Cut703Done", 1);
            ExecuteScript("q7_cut703", oPC);
            return;
        }
        else if (nPlotProgress >= 1 && GetLocalInt(GetModule(), "X2_Cut702Done") != 1)
        {
            SetLocalInt(GetModule(), "X2_Cut702Done", 1);
            ExecuteScript("q7_cut702", oPC);
            return;
        }
    }
    // light effect near cavallas
    if (GetLocalInt(OBJECT_SELF, "nDoLight") != 1)
    {
        SetLocalInt(OBJECT_SELF, "nDoLight", 1);
        object oStone1 = GetObjectByTag("q2acavallasstone");
        object oStone2 = GetObjectByTag("q2acavallasstone2");
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_DUR_GLOW_GREEN), oStone1);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_DUR_GLOW_GREEN), oStone2);

    }
    //Basically -we need to do a check to see if the PC was talking to Imloth
    //or the Seer at the stat of one of the waves and did a save/load - thus
    //screwing things up.
    //Safe settings are done in either the Seer or Imloth's dialog, depending on the wave
    if (GetLocalInt(oPC, "X2_SiegeUnsafeToLoad") > 0)
    {
        //Check which wave this was
        if (GetLocalInt(GetModule(), "X2_Q2Battle2Wave2Spawned") == 0)
        {
            object oImloth = GetObjectByTag("q2arebimloth");
            AssignCommand(oImloth, ActionStartConversation(oPC));
        }
        else if (GetLocalInt(GetModule(), "X2_Q2Battle2Wave3Spawned") == 0)
        {
            object oSeer = GetObjectByTag("q2aseer");
            AssignCommand(oSeer, ActionStartConversation(oPC));
        }
        else if (GetLocalInt(GetModule(), "X2_Q2Battle2Wave4Spawned") == 0)
        {
            object oSeer = GetObjectByTag("q2aseer");
            AssignCommand(oSeer, ActionStartConversation(oPC));
        }
        return;
    }

    //Signal to the Training Soldiers to start training
    if (GetLocalInt(GetModule(), "X2_Q2ABattle2Started") == 0)
    {
        int nCount;
        object oTrain;
        for (nCount = 1; nCount < 7; nCount++)
        {
            oTrain = GetObjectByTag("q2amaemark" + IntToString(nCount));

            SignalEvent(oTrain, EventUserDefined(99));
        }
        for (nCount = 1; nCount < 7; nCount++)
        {
            oTrain = GetObjectByTag("q2atrainreb" + IntToString(nCount));
            SignalEvent(oTrain, EventUserDefined(99));
        }

    }
    else if (GetLocalInt(GetModule(), "X2_Q2ABattle2Started") > 0)
    {
        //Do an autosave
        //DoSinglePlayerAutoSave();
        //Since this is the start of the next battle - lets make sure that the PC is not immortal still
        //(and his henchmen)

        // This one is used for the seer's starting conditions.
        SetLocalInt(GetModule(), "X2_Q2ABattle2Wave1", 3);
        SetImmortal(oPC, FALSE);
        int i = 1;
        object oHench = GetHenchman(oPC, i);
        while(oHench != OBJECT_INVALID)
        {
            SetImmortal(oHench, FALSE);
            i++;
            oHench = GetHenchman(oPC, i);
        }

        object oBattleMaster = GetObjectByTag("q2abattle2master");
        SetLocalInt(GetModule(), "X2_Q2AnBattle2Spawn", 1);

        //empty the city core of ambient NPCs
        ExecuteScript("bat2_emptycore", oBattleMaster);


        //If the PC betrayed the rebels - spawn in the PC as a friend of the attackers
        if (GetLocalInt(GetModule(), "X2_Q2ARebelsBetrayed") == 1)
        {
            //Chapter 3 variable for Rob
            SetGlobalInt("bSeerBetrayed", TRUE);

            //Henchmen betrayal variables
            SetGlobalInt("PC_BETRAY_NAT", 1);
            SetGlobalInt("PC_BETRAY_VAL", 1);

            ExecuteScript("bat2_spawnevil", oBattleMaster);

        }
        //else spawn in the PC at the head of the defence
        else
        {
            //Check to see if the PC promised the Valsharess that he would betray the rebels
            //if the PC double crossed the Valsharess - any reward he would have got from her
            //is now cursed
            if (GetLocalInt(oPC, "X2_BetrayalPromise") == 1)
            {
                SetLocalInt(GetModule(), "X2_ValsharessCurseActive", 1);
                ExecuteScript("q2betraycurse", oPC);
            }

            //if the House Maeviir betrayal has not been prevented - it will occur now.
            //Jump the PC to a cutscene involving the Seer and House Maeviir
            if (GetLocalInt(GetModule(), "X2_Q2ABattle2_Maeviir") == 0)
            {
                //BlackScreen(oPC);
                SetLocalInt(GetModule(), "X2_Q2AStartCutscene108", 1);
                object oJumpTo = GetObjectByTag("cut108wp_pcstart");
                AssignCommand(oPC, JumpToObject(oJumpTo));
            }
            //else with no betrayal - we can head straight to the gathering of forces
            //in the city square.
            else
            {

                //Autosave if the PC won the first battle
                //if (GetLocalInt(GetModule(), "X2_Q2ABattle1Won") == 1)
                //{
                    //Set a variable to help check the save/load bug
                    SetLocalInt(oPC, "X2_SiegeUnsafeToLoad", 1);

                //}
                //Spawn in all defending groups..
                ExecuteScript("bat2_spawndef", oBattleMaster);

                //Herald will start talking with the PC
                DelayCommand(1.0, CreateHerald(oPC));
            }
        }
    }

}

void CreateHerald(object oPC)
{

    object oHerald = GetObjectByTag("q2arebimloth");
    DestroyObject(oHerald);
    object oHeraldStart = GetWaypointByTag("wp_q2abattle2_herald_lossstart");

                //if (GetIsObjectValid(oHerald) == FALSE)
                //{
    object oImloth = CreateObject(OBJECT_TYPE_CREATURE, "q2arebimloth", GetLocation(oHeraldStart));

    SetLocalObject(oImloth, "oLeader", oPC);
    //Paralyze the PC so that imloth can talk to him
    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectCutsceneParalyze(), oPC, 3.0);

                //}
                //else
                //{
                //    AssignCommand(oHerald, JumpToObject(oHeraldStart));
                //}
    SetPlotFlag(oImloth, FALSE);
    SetImmortal(oImloth, FALSE);
    SetLocalInt(oImloth, "nTalkToPC", 1);
    DelayCommand(1.0, AssignCommand(oPC, ClearAllActions(TRUE)));
    DelayCommand(2.0, AssignCommand(oImloth, ActionStartConversation(oPC)));
    SignalEvent(oImloth, EventUserDefined(101));
}
