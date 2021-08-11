//::///////////////////////////////////////////////
//:: Name q2a_ud_batmast2
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Battle Master User Defined.
    For Battle 2
    The Battle master controls certain battle events
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: August 28/03
//:://////////////////////////////////////////////
#include "q2_inc_battle"
#include "x2_inc_globals"
#include "nw_i0_plot"

int CheckGroupCount(object oLeader);
void SpawnDrowGroupAt(int nFormation, string szResRef, object oTarget, location lSpawn);
void RespawnCreature(string szResRef);
void ReturnRebelsToPositions();
void RemoveBadEffects(object oPC);

void main()
{

        int nEvent = GetUserDefinedEventNumber();

        if (nEvent == BATTLEMASTER_SIGNAL_RETREAT)
        {
            SetLocalInt(OBJECT_SELF, "nBattle1RetreatSounded", 1);

            //Get the new target (the inner gate)

            object oRetreatTo = GetObjectByTag("wp_bat2_retreat");

            //How many total formations have been created.
            int nTotalFormCount = GetLocalInt(OBJECT_SELF, "nBattle1DrowFormCount");
            object oGroupLeader, oGroupMember, oGroupTarget;
            int nCount = 1, nCount2;
            //Cycle through all the formation leaders stored by the Battlemaster until w
            //find one that hasn't been already assigned to the city gate and make them attack
            for (nCount = 1; nCount <= nTotalFormCount; nCount++)
            {

                //if the chosen formation hasn't been wiped out
                if (GetLocalInt(OBJECT_SELF, "nDeadFormation" + IntToString(nCount)) != 1)
                {
                    oGroupLeader = GetLocalObject(OBJECT_SELF, "oFormationLeader" + IntToString(nCount));
                    for (nCount2 = 1; nCount2 < 6; nCount2++)
                    {
                        oGroupMember = GetLocalObject(oGroupLeader, "oFormMember" + IntToString(nCount2));
                        if (GetIsObjectValid(oGroupMember) == TRUE)
                        {
                            //Have all members fire their advance to gate script

                            SetLocalInt(oGroupMember, "nRetreat", 1);
                            SetLocalObject(oGroupMember,"oTarget", oRetreatTo);
                            AssignCommand(oGroupMember, ClearAllActions(TRUE));
                            DelayCommand(0.3, AssignCommand(oGroupMember, ActionForceMoveToObject(oRetreatTo, TRUE)));
                            DelayCommand(0.6, AssignCommand(oGroupMember, ActionDoCommand(SetCommandable(FALSE, oGroupMember))));

                         }
                    }

                }
            }
            //End Battle Variables
            SetLocalInt(GetModule(), "X2_Q2ABattle2Won", 1);
            SetLocalInt(GetModule(), "X2_Q2ABattle2Started", 2);

            //Have the Herald speak to the PC and start conversation with the PC
            object oHerald = GetObjectByTag("q2arebimloth");
            object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oHerald);
            AssignCommand(oHerald, PlaySpeakSoundByStrRef(85755)); //"They are retreating. We have won the battle."
            AssignCommand(oPC, ClearAllActions(TRUE));
            DelayCommand(0.5, AssignCommand(oHerald, ActionStartConversation(oPC)));

        }
        //If the Seer is ever killed - the PC has lost - go to a defeat cutscene
        //and get transported to the Matron's castle
        else if (nEvent == BATTLE2_PLAYER_DEFEAT)
        {
            //Set Module Variables
            SetLocalInt(GetModule(), "X2_Q2ABattle2Defeat", 1);

            object oTarget = GetWaypointByTag("wp_q2a9_pcsiegeoffer");
            object oHerald = GetObjectByTag("q2arebimloth");
            object oPC = GetLocalObject(oHerald, "oLeader");
            //SendMessageToPC(GetFirstPC(), "HERALD LEADER: " + GetName(oPC));
            DelayCommand(1.6, AssignCommand(oPC, ClearAllActions(TRUE)));
            DelayCommand(2.0, AssignCommand(oPC, JumpToObject(oTarget)));
        }
        else if (nEvent == BATTLEMASTER_SIGNAL_WAVE2_RETREAT)
        {
            //have the Duergar of Wave 2 retreat back towards the gate they spawned in from
            object oArea = GetArea(OBJECT_SELF);
            object oWave2Retreat = GetWaypointByTag("wp_bat2_wave2_retreat");
            object oCreature = GetFirstObjectInArea(oArea);
            while (oCreature != OBJECT_INVALID)
            {
                if (GetObjectType(oCreature) == OBJECT_TYPE_CREATURE)
                {
                    string szTag = GetTag(oCreature);
                    if (GetStringLeft(szTag, 13) == "q2a_bat2_duer" || szTag == "q2a_bat2_undead3")
                    {
                        SetLocalInt(oCreature, "nRetreat", 1);
                        SetLocalObject(oCreature,"oTarget", oWave2Retreat);

                        AssignCommand(oCreature, ClearAllActions(TRUE));
                        DelayCommand(0.3, AssignCommand(oCreature, ActionForceMoveToObject(oWave2Retreat, TRUE)));
                        DelayCommand(0.6, AssignCommand(oCreature, ActionDoCommand(SetCommandable(FALSE, oCreature))));
                        DestroyObject(oCreature, 15.0);
                    }
                }
                oCreature = GetNextObjectInArea(oArea);
            }
        }
        else if (nEvent == BATTLE2_PLAYER_WAVE2_VICTORY)
        {
            //only do this event once..
            if (GetLocalInt(OBJECT_SELF, "X2_Q2Battle2Wave2Over") == 1)
                return;

            //The PC will run towards the Seer - fade out -
            //Appear next to the Seer and start conversation with her
            object oSeer = GetObjectByTag("q2aseer");
            object oNearSeer = GetWaypointByTag("wp_bat2_pcseertalk");

            SetLocalInt(oSeer, "Q2B_CASTING", 0);
            //SendMessageToPC(GetFirstPC(), "WAVE 2 VICTORY - WAVE 2 OVER****");
            SetLocalInt(OBJECT_SELF, "X2_Q2Battle2Wave2Over", 1);
            SetLocalInt(GetModule(), "X2_Q2Battle2Wave2Over", 1);
            SetLocalInt(oSeer, "X2_Q2Battle2Wave2Over", 1);
            object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oSeer);
            AssignCommand(oPC, PlaySound("as_pl_comyaygrp2"));
            AssignCommand(oPC, ClearAllActions(TRUE));
            SetCutsceneMode(oPC, TRUE);
            DelayCommand(2.0, AssignCommand(oPC, ActionMoveToObject(oSeer, TRUE)));
            FadeToBlack(oPC, FADE_SPEED_FAST);
            DelayCommand(6.0, AssignCommand(oPC, ClearAllActions(TRUE)));
            DelayCommand(6.2, AssignCommand(oPC, JumpToObject(oNearSeer)));
            AssignCommand(oSeer, ClearAllActions(TRUE));
            DelayCommand(6.5, FadeFromBlack(oPC, FADE_SPEED_FASTEST));
            DelayCommand(7.0, AssignCommand(oSeer, ActionStartConversation(oPC)));
            DelayCommand(7.0, SetCutsceneMode(oPC, FALSE));

            //Keep still, darn players
            DelayCommand(7.2, ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectCutsceneImmobilize(), oPC));

            DelayCommand(7.0, ReturnRebelsToPositions());
        }
        //Signal Formation 1 to protect the seer all other rebel troops to advance to the port
        else if (nEvent == BATTLE2_WAVE2_REBEL_ADVANCE)
        {
            string szRebel = "q2abat2reb";
            object oMoveTo;
            object oArea = GetArea(OBJECT_SELF);
            object oCreature = GetFirstObjectInArea(oArea);
            while (oCreature != OBJECT_INVALID)
            {
                if (GetObjectType(oCreature) == OBJECT_TYPE_CREATURE)
                {
                    if (GetStringLeft(GetTag(oCreature), 10) == szRebel)
                    {
                        //Formation 1 will go to guard seer positions
                        if(GetLocalInt(oCreature, "nFormation") == 1)
                        {
                            string szNumber = GetStringRight(GetTag(OBJECT_SELF), 1);
                            AssignCommand(oCreature, ActionForceMoveToObject(GetWaypointByTag("wp_bat2seerpost" + szNumber), TRUE, 5.0));
                            DelayCommand(6.0, SignalEvent(oCreature, EventUserDefined(UNIT_ORDER_STAND_POST)));
                        }
                        else
                        {
                            oMoveTo = GetObjectByTag("wp_bat2_wave2_rebel" + IntToString(Random(2) + 1));
                            SetLocalObject(oCreature, "oMoveTarget", oMoveTo);
                            AssignCommand(oCreature, ActionMoveToObject(oMoveTo, TRUE));
                            DelayCommand(6.0, SignalEvent(oCreature, EventUserDefined(UNIT_MOVE_TO_TARGET)));
                        }
                    }
                }
                oCreature = GetNextObjectInArea(oArea);
            }
            //Imloth moves into position
            object oImloth = GetObjectByTag("q2arebimloth");
            object oImTarget = GetWaypointByTag("wp_bat2_pcseertalk");
            AssignCommand(oImloth, ActionMoveToObject(oImTarget));

        }
        //Repopulate the attackers in Wave 2 after a certain amount of them have been killed.
        else if (nEvent == BATTLEMASTER_RESPAWN_WAVE_WAVE2)
        {

            if (GetLocalInt(OBJECT_SELF, "nWave2TimesRespawned") == 0)
            {
                int nWave2TotalSpawnedCount = 11;
               //Spawn in soldiers

                RespawnCreature("q2a_bat2_duer2");
                DelayCommand(1.0, RespawnCreature("q2a_bat2_duer2"));
                DelayCommand(2.0, RespawnCreature("q2a_bat2_duer1"));
                DelayCommand(3.0, RespawnCreature("q2a_bat2_duer1"));
                DelayCommand(4.0, RespawnCreature("q2a_bat2_duer1"));
                DelayCommand(5.0, RespawnCreature("q2a_bat2_duer2"));
                DelayCommand(6.0, RespawnCreature("q2a_bat2_duer2"));
                DelayCommand(7.0, RespawnCreature("q2a_bat2_duer1"));
                DelayCommand(8.0, RespawnCreature("q2a_bat2_duer1"));
                DelayCommand(9.0, RespawnCreature("q2a_bat2_duer1"));

                //if (GetGlobalInt("x2_plot_undead_out") == 0)
               // {
               //     DelayCommand(10.0, RespawnCreature("q2a_bat2_undead3"));
               // }

                SetLocalInt(OBJECT_SELF, "nWave2TimesRespawned", 1);
            }
            else
            {
                //Spawn in soldiers

                RespawnCreature("q2a_bat2_duer2");
                DelayCommand(1.0, RespawnCreature("q2a_bat2_duer2"));
                DelayCommand(2.0, RespawnCreature("q2a_bat2_duer1"));
                DelayCommand(3.0, RespawnCreature("q2a_bat2_duer1"));
                DelayCommand(4.0, RespawnCreature("q2a_bat2_duer1"));
                DelayCommand(5.0, RespawnCreature("q2a_bat2_duer2"));
                DelayCommand(6.0, RespawnCreature("q2a_bat2_duer2"));
                DelayCommand(7.0, RespawnCreature("q2a_bat2_duer1"));
                DelayCommand(8.0, RespawnCreature("q2a_bat2_duer1"));
                DelayCommand(9.0, RespawnCreature("q2a_bat2_duer1"));

                //if (GetGlobalInt("x2_plot_undead_out") == 0)
                //{
                //    DelayCommand(10.0, RespawnCreature("q2a_bat2_undead3"));
                //}

                SetLocalInt(OBJECT_SELF, "nWave2TimesRespawned", 2);
            }
        }
        //Cause the Drow to fall back and retreat after a certain amount of them have been
        //killed in Wave 3
        else if (nEvent == BATTLEMASTER_SIGNAL_WAVE3_RETREAT)
        {

            object oArea = GetArea(OBJECT_SELF);
            object oWave2Retreat = GetWaypointByTag("wp_bat2_wave3_retreat");
            object oCreature = GetFirstObjectInArea(oArea);
            while (oCreature != OBJECT_INVALID)
            {
                if (GetObjectType(oCreature) == OBJECT_TYPE_CREATURE)
                {
                    string szTag = GetTag(oCreature);
                    if (GetStringLeft(szTag, 9) == "bat2_drow")
                    {
                        SetLocalInt(oCreature, "nRetreat", 1);
                        SetLocalObject(oCreature,"oTarget", oWave2Retreat);
                        AssignCommand(oCreature, ClearAllActions(TRUE));
                        DelayCommand(0.3, AssignCommand(oCreature, ActionForceMoveToObject(oWave2Retreat, TRUE)));
                        DelayCommand(0.6, AssignCommand(oCreature, ActionDoCommand(SetCommandable(FALSE, oCreature))));
                        DestroyObject(oCreature, 15.0);
                    }
                }
                oCreature = GetNextObjectInArea(oArea);
            }
        }
        //Once the Drow have retreated in Wave 3 - Speak with the Seer again
        else if (nEvent == BATTLE2_PLAYER_WAVE3_VICTORY)
        {
            //only do this event once..
            if (GetLocalInt(OBJECT_SELF, "X2_Q2Battle2Wave3Over") == 1)
                return;

            //Change the Background battle noises
            object oArea = GetArea(OBJECT_SELF);
            AmbientSoundStop(oArea);
            AmbientSoundChangeDay(oArea, 30);
            AmbientSoundChangeNight(oArea, 30);
            AmbientSoundPlay(oArea);

            //Seer stops casting
            object oSeer = GetObjectByTag("q2aseer");
            object oNearSeer = GetWaypointByTag("wp_bat2_pcseertalk");
            SetLocalInt(oSeer, "Q2B_CASTING", 0);

            //Battle Variables
            SetLocalInt(OBJECT_SELF, "X2_Q2Battle2Wave3Over", 1);
            SetLocalInt(GetModule(), "X2_Q2Battle2Wave3Over", 1);
            SetLocalInt(oSeer, "X2_Q2Battle2Wave3Over", 1);

            //Battle Over Sound
            object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oSeer);
            AssignCommand(oPC, PlaySound("as_pl_comyaygrp2"));
            AssignCommand(oPC, ClearAllActions(TRUE));

            //Move PC to speak with Seer
            SetCutsceneMode(oPC, TRUE);
            DelayCommand(2.0, AssignCommand(oPC, ActionMoveToObject(oSeer, TRUE)));
            FadeToBlack(oPC, FADE_SPEED_FAST);
            DelayCommand(6.0, AssignCommand(oPC, ClearAllActions(TRUE)));
            DelayCommand(6.2, AssignCommand(oPC, JumpToObject(oNearSeer)));
            AssignCommand(oSeer, ClearAllActions(TRUE));
            DelayCommand(6.5, FadeFromBlack(oPC, FADE_SPEED_FASTEST));
            DelayCommand(7.0, AssignCommand(oSeer, ActionStartConversation(oPC)));
            DelayCommand(7.0, SetCutsceneMode(oPC, FALSE));
            //Keep still, darn players
            DelayCommand(7.2, ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectCutsceneImmobilize(), oPC));

            DelayCommand(7.0, ReturnRebelsToPositions());
        }
        //Signal Formation 1 to protect the seer all other rebel troops to advance to the port
        else if (nEvent == BATTLE2_WAVE3_REBEL_ADVANCE)
        {

            string szRebel = "q2abat2reb";
            string szUnique, szFormation, szTag;
            object oMoveTo;
            object oArea = GetArea(OBJECT_SELF);
            object oCreature = GetFirstObjectInArea(oArea);
            while (oCreature != OBJECT_INVALID)
            {
                if (GetObjectType(oCreature) == OBJECT_TYPE_CREATURE)
                {
                    szTag = GetTag(oCreature);
                    if (GetStringLeft(szTag, 10) == szRebel)
                    {
                        szUnique = GetStringRight(szTag, 2);
                        szFormation = GetStringLeft(szUnique, 1);
                        //Formation 1 will go to guard seer positions
                        if(szFormation == "1")
                        {
                            string szNumber = GetStringRight(GetTag(oCreature), 1);
                            AssignCommand(oCreature, ActionForceMoveToObject(GetWaypointByTag("wp_bat2seerpost" + szNumber), TRUE, 5.0));
                            DelayCommand(6.0, SignalEvent(oCreature, EventUserDefined(UNIT_ORDER_STAND_POST)));
                        }
                        else
                        {
                            oMoveTo = GetObjectByTag("wp_bat2_wave3_rebel" + IntToString(Random(2) + 1));
                            SetLocalObject(oCreature, "oMoveTarget", oMoveTo);
                            AssignCommand(oCreature, ActionMoveToObject(oMoveTo, TRUE));
                            DelayCommand(6.0, SignalEvent(oCreature, EventUserDefined(UNIT_MOVE_TO_TARGET)));
                        }
                    }
                }
                oCreature = GetNextObjectInArea(oArea);
            }
            //Imloth moves into position
            object oImloth = GetObjectByTag("q2arebimloth");
            object oImTarget = GetWaypointByTag("wp_bat2_pcseertalk");
            AssignCommand(oImloth, ActionMoveToObject(oImTarget));
        }
        else if (nEvent == BATTLEMASTER_RESPAWN_WAVE_WAVE3)
        {
            //Respawn some Drow for Wave 3
            if (GetLocalInt(OBJECT_SELF, "nWave3TimesRespawned") == 0)
            {
               //Spawn in soldiers

                RespawnCreature("bat2_drow1");
                DelayCommand(1.0, RespawnCreature("bat2_drow2"));
                DelayCommand(2.0, RespawnCreature("bat2_drow1"));
                DelayCommand(3.0, RespawnCreature("bat2_drow1"));
                DelayCommand(4.0, RespawnCreature("bat2_drow1"));
                DelayCommand(5.0, RespawnCreature("bat2_drow2"));

                DelayCommand(8.0, RespawnCreature("bat2_drow1"));
                DelayCommand(9.0, RespawnCreature("bat2_drow1"));

                SetLocalInt(OBJECT_SELF, "nWave3TimesRespawned", 1);
            }
            else
            {
                //Spawn in soldiers

                RespawnCreature("bat2_drow1");
                DelayCommand(1.0, RespawnCreature("bat2_drow2"));
                DelayCommand(2.0, RespawnCreature("bat2_drow1"));
                DelayCommand(3.0, RespawnCreature("bat2_drow1"));
                DelayCommand(4.0, RespawnCreature("bat2_drow1"));
                DelayCommand(5.0, RespawnCreature("bat2_drow2"));

                DelayCommand(8.0, RespawnCreature("bat2_drow1"));
                DelayCommand(9.0, RespawnCreature("bat2_drow1"));

                SetLocalInt(OBJECT_SELF, "nWave3TimesRespawned", 2);
            }
        }
    //Cause the Beholders and Mindflayers to fall back and retreat after a certain amount of them have been
        //killed in Wave 4
        else if (nEvent == BATTLEMASTER_SIGNAL_WAVE4_RETREAT)
        {

            object oArea = GetArea(OBJECT_SELF);
            object oWave4Retreat = GetWaypointByTag("wp_bat2_wave3_retreat");
            object oCreature = GetFirstObjectInArea(oArea);
            while (oCreature != OBJECT_INVALID)
            {
                if (GetObjectType(oCreature) == OBJECT_TYPE_CREATURE)
                {
                    string szTag = GetTag(oCreature);
                    if (GetStringLeft(szTag, 8) == "q2a_bat2")
                    {
                        SetLocalInt(oCreature, "nRetreat", 1);
                        SetLocalObject(oCreature,"oTarget", oWave4Retreat);

                        AssignCommand(oCreature, ClearAllActions(TRUE));
                        DelayCommand(0.3, AssignCommand(oCreature, ActionForceMoveToObject(oWave4Retreat, TRUE)));
                        DelayCommand(0.6, AssignCommand(oCreature, ActionDoCommand(SetCommandable(FALSE, oCreature))));
                        DestroyObject(oCreature, 10.0);
                    }
                }
                oCreature = GetNextObjectInArea(oArea);
            }
        }
        //Once the Beholders/Mindflayers have retreated in Wave 4 - Speak with the Seer again
        else if (nEvent == BATTLE2_PLAYER_WAVE4_VICTORY)
        {
            //only do this event once..
            if (GetLocalInt(OBJECT_SELF, "X2_Q2Battle2Wave4Over") == 1)
                return;

            //Change the Background battle noises
            object oArea = GetArea(OBJECT_SELF);
            AmbientSoundStop(oArea);
            AmbientSoundChangeDay(oArea, 30);
            AmbientSoundChangeNight(oArea, 30);
            AmbientSoundPlay(oArea);


            //Stop the seer from casting
            object oSeer = GetObjectByTag("q2aseer");
            object oNearSeer = GetWaypointByTag("wp_bat2_pcseertalk");
            SetLocalInt(oSeer, "Q2B_CASTING", 0);

            SetLocalInt(OBJECT_SELF, "X2_Q2Battle2Wave4Over", 1);
            SetLocalInt(oSeer, "X2_Q2Battle2Wave4Over", 1);
            SetLocalInt(GetModule(), "X2_Q2Battle2Wave4Over", 1);
            object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oSeer);
            AssignCommand(oPC, PlaySound("as_pl_comyaygrp2"));
            AssignCommand(oPC, ClearAllActions(TRUE));
            AssignCommand(oSeer, ClearAllActions(TRUE));
            //Remove bad effects from the PC

            SetCutsceneMode(oPC, TRUE);
            DelayCommand(2.0, AssignCommand(oPC, ActionMoveToObject(oSeer, TRUE)));
            FadeToBlack(oPC, FADE_SPEED_FAST);
            DelayCommand(6.0, AssignCommand(oPC, ClearAllActions(TRUE)));
            DelayCommand(6.0, AssignCommand(oSeer, ClearAllActions(TRUE)));
            DelayCommand(6.2, AssignCommand(oPC, JumpToObject(oNearSeer)));
            AssignCommand(oSeer, ClearAllActions(TRUE));
            DelayCommand(6.5, FadeFromBlack(oPC, FADE_SPEED_FASTEST));
            DelayCommand(7.0, AssignCommand(oSeer, ActionStartConversation(oPC)));
            DelayCommand(7.0, SetCutsceneMode(oPC, FALSE));
            //Keep still, darn players
            DelayCommand(7.2, ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectCutsceneImmobilize(), oPC));

            DelayCommand(7.0, ReturnRebelsToPositions());

            SetLocalInt(GetModule(), "X2_Q2ABattle2Started", 2);
        }
        //Signal Formation 1 to protect the seer all other rebel troops to advance to the port
        else if (nEvent == BATTLE2_WAVE4_REBEL_ADVANCE)
        {

            string szRebel = "q2abat2reb";
            object oMoveTo;
            object oArea = GetArea(OBJECT_SELF);
            object oCreature = GetFirstObjectInArea(oArea);
            while (oCreature != OBJECT_INVALID)
            {
                if (GetObjectType(oCreature) == OBJECT_TYPE_CREATURE)
                {
                    if (GetStringLeft(GetTag(oCreature), 10) == szRebel)
                    {
                        //All Formations will go to guard seer positions

                        string szNumber = GetStringRight(GetTag(OBJECT_SELF), 1);
                        AssignCommand(oCreature, ActionForceMoveToObject(GetWaypointByTag("wp_bat2seerpost" + szNumber), TRUE, 5.0));
                        DelayCommand(6.0, SignalEvent(oCreature, EventUserDefined(UNIT_ORDER_STAND_POST)));

                    }
                }
                oCreature = GetNextObjectInArea(oArea);
            }
            //Imloth moves into position
            object oImloth = GetObjectByTag("q2arebimloth");
            object oImTarget = GetWaypointByTag("wp_bat2_pcseertalk");
            AssignCommand(oImloth, ActionMoveToObject(oImTarget));
        }
}

int CheckGroupCount(object oLeader)
{
    int nFormation = GetLocalInt(oLeader, "nFormation");
    string szResRef = GetResRef(oLeader);
    int nCount = 1;
    int nTotal = 0;
    object oGroupMember;
    for (nCount = 1; nCount < 6; nCount++)
    {
        oGroupMember = GetObjectByTag(szResRef + IntToString(nFormation) + IntToString(nCount));
        if (GetIsObjectValid(oGroupMember) && GetIsDead(oGroupMember) == FALSE)
        {
            nTotal++;
        }
    }
    return nTotal;
}

void SpawnDrowGroupAt(int nFormation, string szResRef, object oTarget, location lSpawn)
{
    //object oPC = GetFirstPC();
    if (GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetObjectByTag("q2ainnergate");
    object oBattleMaster = OBJECT_SELF;
    //Track how many Drow formations have been created (for retreat purposes)

    SetLocalInt(oBattleMaster, "nBattle1DrowFormCount", GetLocalInt(oBattleMaster, "nBattle1DrowFormCount") + 1);

    //location lSpawn = GetLocation(GetWaypointByTag("wp_bat1_drowspawn" + IntToString(Random(3) + 1)));
    int nCount;
    object oCreature;
    for (nCount = 1; nCount < 6; nCount++)
    {
        oCreature = CreateObject(OBJECT_TYPE_CREATURE, szResRef, lSpawn, TRUE, szResRef + IntToString(nFormation) + IntToString(nCount));
        if (nCount == 1)
        {
            //Store a pointer to the leader of each group on the battlemaster
            SetLocalObject(oBattleMaster, "oFormationLeader" + IntToString(nFormation), oCreature);

            SetLocalInt(oCreature, "nLeader", 1);                     //ADVANCE
            DelayCommand(2.0, SignalEvent(oCreature, EventUserDefined(5000)));
        }
        SetLocalInt(oCreature, "nFormation", nFormation);
        SetLocalObject(oCreature, "oTarget", oTarget);

    }
    SetFormation(nFormation, szResRef);
}

void RespawnCreature(string szResRef)
{
    //The Seer
    object oSeer = GetObjectByTag("q2aseer");
    location lSpawn = GetLocation(GetWaypointByTag("bat2wp_wave2spawn3"));
    if (GetStringLeft(szResRef, 9) == "bat2_drow")
        lSpawn = GetLocation(GetWaypointByTag("wp_bat2_wave3_spawn3"));
    object oCreature = CreateObject(OBJECT_TYPE_CREATURE, szResRef, lSpawn);
    SetLocalObject(oCreature, "oTarget", oSeer);
    AssignCommand(oCreature, ActionMoveToObject(oSeer, TRUE));
    DelayCommand(6.0 + IntToFloat(Random(4)), SignalEvent(oCreature, EventUserDefined(5000)));
}

//Return the rebel forces to their start positions neer the Seer
void ReturnRebelsToPositions()
{
    string szTarget = "wp_bat2_rebmoveto";
    string szRebel = "q2abat2reb";
    string szUnique, szFormation, szCount;
    string szTag;
    object oMoveTo;
    object oArea = GetArea(OBJECT_SELF);
    object oCreature = GetFirstObjectInArea(oArea);
    while (oCreature != OBJECT_INVALID)
    {
        if (GetObjectType(oCreature) == OBJECT_TYPE_CREATURE)
        {
            szTag = GetTag(oCreature);
            if (GetStringLeft(szTag, 10) == szRebel)
            {
                szUnique = GetStringRight(szTag, 2);
                szFormation = GetStringLeft(szUnique, 1);
                szCount = GetStringRight(szUnique, 1);
                //Formation 1 will go to guard seer positions
                oMoveTo = GetWaypointByTag(szTarget + szFormation + "_" + szCount);
                AssignCommand(oCreature, ActionForceMoveToObject(oMoveTo, TRUE, 5.0));
                DelayCommand(6.0, SignalEvent(oCreature, EventUserDefined(UNIT_ORDER_STAND_POST)));

            }
        }
        oCreature = GetNextObjectInArea(oArea);
    }
}
// * removes all negative effects
void RemoveBadEffects(object oPC)
{
    //Declare major variables
    object oTarget = oPC;

    int bValid;

    effect eBad = GetFirstEffect(oTarget);
    //Search for negative effects
    while(GetIsEffectValid(eBad))
    {
        if (GetEffectType(eBad) == EFFECT_TYPE_ABILITY_DECREASE ||
            GetEffectType(eBad) == EFFECT_TYPE_AC_DECREASE ||
            GetEffectType(eBad) == EFFECT_TYPE_ATTACK_DECREASE ||
            GetEffectType(eBad) == EFFECT_TYPE_DAMAGE_DECREASE ||
            GetEffectType(eBad) == EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE ||
            GetEffectType(eBad) == EFFECT_TYPE_SAVING_THROW_DECREASE ||
            GetEffectType(eBad) == EFFECT_TYPE_SPELL_RESISTANCE_DECREASE ||
            GetEffectType(eBad) == EFFECT_TYPE_SKILL_DECREASE ||
            GetEffectType(eBad) == EFFECT_TYPE_BLINDNESS ||
            GetEffectType(eBad) == EFFECT_TYPE_DEAF ||
            GetEffectType(eBad) == EFFECT_TYPE_PARALYZE ||
            GetEffectType(eBad) == EFFECT_TYPE_NEGATIVELEVEL ||
            GetEffectType(eBad) == EFFECT_TYPE_FRIGHTENED ||
            GetEffectType(eBad) == EFFECT_TYPE_DAZED ||
            GetEffectType(eBad) == EFFECT_TYPE_CONFUSED ||
            GetEffectType(eBad) == EFFECT_TYPE_POISON ||
            GetEffectType(eBad) == EFFECT_TYPE_DISEASE
                )
            {
                //Remove effect if it is negative.
                RemoveEffect(oTarget, eBad);
            }
        eBad = GetNextEffect(oTarget);
    }
    //Fire cast spell at event for the specified target
    //SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_RESTORATION, FALSE));

}
