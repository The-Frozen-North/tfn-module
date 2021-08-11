//::///////////////////////////////////////////////
//:: Name q2_inc_battle
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Battle for Lith My'athar Include file
*/
//:://////////////////////////////////////////////
//:: Created By:  Keith Warner
//:: Created On: August 19/03
//:://////////////////////////////////////////////
#include "nw_i0_generic"
#include "nw_i0_plot"

//CONSTANTS ******************************
const int UNIT_MOVE_TO_TARGET = 5100;
const int LEADER_ORDER_FOLLOW_LEADER = 5101;
const int UNIT_ORDER_MAKE_ME_LEADER = 5102;
const int DROW_UNIT_MOVE_TO_INITIAL_TARGET = 5103;
const int UNIT_ORDER_PATROL_CURRENT_LOCATION = 5104;
const int LEADER_ORDER_CHECK_FOR_ENEMIES = 5105;
const int HOTSPOT_CHECK = 5106;
const int DROW_ORDER_DEFEND_HOTSPOT = 5107;
const int BATTLE1_DROW_VICTORY = 5108;
const int HEALER_ORDER_HEAL_REBELS = 5109;
const int UNIT_ORDER_PATROL_TOWER = 5110;
const int BATTLEMASTER_FIND_NEW_GATE_ATTACKER = 5111;
const int BATTLEMASTER_SIGNAL_RETREAT = 5112;
const int BATTLEMASTER_SIGNAL_ALL_ADVANCE = 5113;
const int BATTLEMASTER_RESPAWN_WAVE = 5114;
const int BATTLE2_PLAYER_VICTORY = 5115;
const int BATTLE2_PLAYER_DEFEAT = 5116;
const int BATTLEMASTER_SIGNAL_WAVE2_RETREAT = 5117;
const int BATTLE2_PLAYER_WAVE2_VICTORY = 5118;
const int BATTLE2_WAVE2_REBEL_ADVANCE = 5119;
const int BATTLEMASTER_RESPAWN_WAVE_WAVE2 = 5120;
const int UNIT_ORDER_STAND_POST = 5121;
const int BATTLEMASTER_SIGNAL_WAVE3_RETREAT = 5122;
const int BATTLE2_PLAYER_WAVE3_VICTORY = 5123;
const int BATTLE2_WAVE3_REBEL_ADVANCE = 5124;
const int BATTLEMASTER_RESPAWN_WAVE_WAVE3 = 5125;
const int BATTLEMASTER_SIGNAL_WAVE4_RETREAT = 5126;
const int BATTLE2_PLAYER_WAVE4_VICTORY = 5127;
const int BATTLE2_WAVE4_REBEL_ADVANCE = 5128;

const int BATTLE1_RETREAT_NUMBER = 6;
//FUNCTION DEFINITIONS **************************************

//A leader unit calls this function to order all troops in his formation to
//move to his target object
void BattleOrder_MoveTroopsToTarget(object oTarget);

//Specify a fraction if you want a fraction of a second delay
//Max Seconds divided by nDivisor
float GetRandomDelay2(int nMaxSeconds, float fFraction = 1.0);

//A formation leader has died so elect a new one.
void Formation_ElectNewLeader(int nFormNumber);

//Spawn in Rebels
//Create a formation of 5 of the specified creatures and move them to oTarget
//Make one of the creatures a leader.
void CreateRebelFormation(int nFormNumber, string szResRef, location lSpawn, object oTarget);

//Create 1 rebel cleric and move them to oTarget
void CreateRebelCleric(string szResRef, location lSpawn, object oTarget);

//The leader of a formation has seen the enemy so formation will attack
void BattleOrder_FormationAttack(object oEnemy);

//A leader unit calls this function to order all troops in his formation to
//attack this target location
void BattleOrder_TroopsAttackTarget(object oTarget);

//Drow Catapult picking a target trigger in which to look for a target
object DrowCatapult_PickTargetArea();

//DrowCatapult picking a target unit in a target area;
object DrowCatapult_PickTargetUnit(object oTargetLocation);

//Drow Catapult has no specific target - so get a random location near the target trigger
location DrowCatapult_PickRandomLocation(object oTargetLocation);

//Create a drow catapult team at the given location
void CreateDrowCatapult(location lCatapult1);

//Check to see if the Drow Catapult Fire team is alive
int DrowCatapult_FireTeamAlive(object oBallista);

//Check to see if the Rebel Catapult Fire team is alive
int RebelCatapult_FireTeamAlive(object oBallista);

//Spawn a group of attackers at a specific location
void SpawnGroupAt(int nFormation, string szResRef, object oTarget, location lSpawn);

//All group members should know of each other group member.
void SetFormation(int nFormation, string szResRef);

//FUNCTIONS ****************************
//A leader unit calls this function to order all troops in his formation to
//move to his target object
void BattleOrder_MoveTroopsToTarget(object oTarget)
{
    object oPC = GetFirstPC();
    int nFormNumber = GetLocalInt(OBJECT_SELF, "nFormation");
    //SendMessageToPC(oPC, "Formation Number :" + IntToString(nFormNumber));
    string szTag = GetResRef(OBJECT_SELF);
    string szUnit;
    //SendMessageToPC(oPC, "szTag :" + szTag);
    float fDelay;
    int nCount;
    object oUnit;
    for (nCount = 1; nCount < 6; nCount++)
    {
        szUnit = szTag + IntToString(nFormNumber) + IntToString(nCount);
        //SendMessageToPC(oPC, "Looking for Tag :" + szUnit);
        oUnit = GetObjectByTag(szUnit);
        if (GetIsObjectValid(oUnit) == TRUE)
        {
            //SendMessageToPC(oPC, "Unit Valid");
            SetLocalObject(oUnit, "oMoveTarget", oTarget);

            //Allow Patrolling to commence
            SetLocalInt(oUnit, "nFirstOrders", 1);

            AssignCommand(oUnit, ClearAllActions());
            fDelay = GetRandomDelay2(2, 0.9);
            DelayCommand(fDelay, AssignCommand(oUnit, ActionPlayAnimation(ANIMATION_FIREFORGET_SALUTE)));
            if (Random(3) == 2)
                DelayCommand(fDelay + 0.1, AssignCommand(oUnit, PlaySpeakSoundByStrRef(85762)));//"Yes Sir!"
            DelayCommand(2.0, AssignCommand(oUnit, ActionForceMoveToObject(oTarget, TRUE, 1.0, 12.0)));
            DelayCommand(5.0, SignalEvent(oUnit, EventUserDefined(UNIT_MOVE_TO_TARGET)));
        }
        //else
            //SendMessageToPC(oPC, "Unit INValid");
    }
}


//Specify a divisor if you want a fraction of a second delay
//Max Seconds divided by nDivisor
float GetRandomDelay2(int nMaxSeconds, float fFraction = 1.0)
{
    float fRandom = IntToFloat(Random(nMaxSeconds + 1)) * fFraction;

    return fRandom;
}

//A formation leader has died so elect a new one.
void Formation_ElectNewLeader(int nFormNumber)
{
    string szDeadUnitTag = GetTag(OBJECT_SELF);
    string szTag = GetStringLeft(GetTag(OBJECT_SELF), 11);
    string szUnit;
    effect eVis = EffectVisualEffect(VFX_DUR_FLAG_GOLD);
    int nCount;
    int bFound = FALSE;
    object oUnit;
    //Cycle through the units until one is found alive -make him the new leader.
    for (nCount = 1; nCount < 6 && bFound == FALSE; nCount++)
    {
        szUnit = szTag + IntToString(nFormNumber) + IntToString(nCount);

        oUnit = GetObjectByTag(szUnit);
        if (GetIsObjectValid(oUnit) == TRUE)
        {
            if (GetTag(oUnit) != szDeadUnitTag)
            {
                SetLocalInt(oUnit, "nLeader", 1);
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, eVis, oUnit);
                SignalEvent(oUnit, EventUserDefined(UNIT_ORDER_MAKE_ME_LEADER));
                bFound = TRUE;
            }
        }

    }
}

//Spawn in Rebels
//Create a formation of 5 of the specified creatures and move them to oTarget
//Make one of the creatures a leader.
void CreateRebelFormation(int nFormNumber, string szResRef, location lSpawn, object oTarget)
{
    int nCount;
    for (nCount = 1; nCount < 6; nCount++)
    {
        object oUnit = CreateObject(OBJECT_TYPE_CREATURE, szResRef, lSpawn, FALSE, szResRef + IntToString(nFormNumber) + IntToString(nCount));
        if (nCount == 1)
        {
            SetLocalInt(oUnit, "nLeader", 1);
            effect eVis = EffectVisualEffect(VFX_DUR_FLAG_GOLD);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eVis, oUnit);
            object oHelm = CreateItemOnObject("q2arebleadhelm", oUnit);
            SetDroppableFlag(oHelm, FALSE);
            AssignCommand(oUnit, ActionEquipItem(oHelm, INVENTORY_SLOT_HEAD));
        }
        SetLocalInt(oUnit, "nFormation", nFormNumber);
        SetLocalObject(oUnit, "oMoveTarget", oTarget);
        DelayCommand(0.5, AssignCommand(oUnit, ActionForceMoveToObject(oTarget, TRUE, 1.0, 10.0)));
        DelayCommand(6.0, SignalEvent(oUnit, EventUserDefined(UNIT_MOVE_TO_TARGET)));
    }

}
//Create 1 rebel cleric and move them to oTarget
void CreateRebelCleric(string szResRef, location lSpawn, object oTarget)
{
    object oUnit = CreateObject(OBJECT_TYPE_CREATURE, szResRef, lSpawn);

    SetLocalObject(oUnit, "oMoveTarget", oTarget);
    AssignCommand(oUnit, ActionForceMoveToObject(oTarget, TRUE));
    SignalEvent(oUnit, EventUserDefined(UNIT_MOVE_TO_TARGET));
}

//The leader of a formation has seen the enemy so formation will attack
void BattleOrder_FormationAttack(object oEnemy)
{
    int nCount;
    string szUnit;
    string szTag = GetStringLeft(GetTag(OBJECT_SELF), 11);
    object oUnit;
    int nFormNumber = GetLocalInt(OBJECT_SELF, "nFormation");
    //Cycle through the units until one is found alive -make him the new leader.
    for (nCount = 1; nCount < 6; nCount++)
    {
        szUnit = szTag + IntToString(nFormNumber) + IntToString(nCount);

        oUnit = GetObjectByTag(szUnit);
        if (GetIsObjectValid(oUnit) == TRUE)
        {
            SetLocalInt(oUnit, "nEngageEnemy", 1);
            AssignCommand(oUnit, DetermineCombatRound());
        }

    }
}

//A leader unit calls this function to order all troops in his formation to
//attack this target location
void BattleOrder_TroopsAttackTarget(object oTarget)
{
    object oPC = GetFirstPC();
    //SendMessageToPC(oPC, "Troops Attacking Target");
    int nFormNumber = GetLocalInt(OBJECT_SELF, "nFormation");
    string szTag = GetStringLeft(GetTag(OBJECT_SELF), 16); //x2_q2drowarcher2
    string szUnit;                                         //x2_q2drowwarrio2

    float fDelay;
    int nCount;
    object oUnit;
    for (nCount = 1; nCount < 6; nCount++)
    {
        szUnit = szTag + IntToString(nFormNumber) + IntToString(nCount);

        oUnit = GetObjectByTag(szUnit);
        if (GetIsObjectValid(oUnit) == TRUE)
        {

            SetLocalObject(oUnit, "oMoveTarget", oTarget);
            //SetLocalInt(oUnit, "nTargetPicked", 1);
            if (GetIsInCombat(oUnit) == FALSE)
            {
                AssignCommand(oUnit, ActionMoveToObject(oTarget, TRUE));
            }
            DelayCommand(5.0, SignalEvent(oUnit, EventUserDefined(UNIT_MOVE_TO_TARGET)));
        }
        //else
            //SendMessageToPC(oPC, "Unit INValid");
    }
}

//Drow Catapult picking a target trigger in which to look for a target
object DrowCatapult_PickTargetArea()
{
    int nRandom = Random(6) + 1;
    object oTarget = GetObjectByTag("bat1_cattarget" + IntToString(nRandom));
    return oTarget;
}

//DrowCatapult picking a target unit in a target area;
object DrowCatapult_PickTargetUnit(object oTargetLocation)
{
    object oFireTarget = OBJECT_INVALID;
    int bFound = FALSE;
    object oTarget = GetFirstInPersistentObject(oTargetLocation);
    while (oTarget != OBJECT_INVALID && bFound == FALSE)
    {
        //Will pick either a rebel drow or the PC
        if (GetStringLeft(GetTag(oTarget), 10) == "q2abat1reb" || GetIsPC(oTarget) == TRUE)
        {
            oFireTarget = oTarget;
            bFound = TRUE;
        }
        oTarget = GetNextInPersistentObject(oTargetLocation);
    }
    return oFireTarget;
}

//Drow Catapult has no specific target - so get a random location near the target trigger
location DrowCatapult_PickRandomLocation(object oTargetLocation)
{
    object oArea = GetArea(oTargetLocation);

    vector vStart = GetPosition(oTargetLocation);
    float fAngle = IntToFloat(Random(360));
    float fDistance = IntToFloat(Random(10)+1);
    float fNewx = cos(fAngle)*fDistance + vStart.x;
    float fNewy = sin(fAngle)*fDistance + vStart.y;

    vector vNew = Vector(fNewx, fNewy, vStart.z);
    location lTarget = Location(oArea, vNew, 0.0);

    return lTarget;
}

//Check to see if the Drow Catapult Fire team is alive
int DrowCatapult_FireTeamAlive(object oBallista)
{
    object oDrow = GetNearestObjectByTag("q2a_drowcatteam", oBallista);
    if (GetIsObjectValid(oDrow) == TRUE)
    {
        if (GetDistanceBetween(oBallista, oDrow) < 5.0)
            return TRUE;
    }
    return FALSE;
}

//Check to see if the Rebel Catapult Fire team is alive
int RebelCatapult_FireTeamAlive(object oBallista)
{
    object oDrow = GetNearestObjectByTag("q2a_rebcatteam", oBallista);
    if (GetIsObjectValid(oDrow) == TRUE)
    {
        if (GetDistanceBetween(oBallista, oDrow) < 5.0)
            return TRUE;
    }
    return FALSE;
}

//Create a drow catapult team at the given location
void CreateDrowCatapult(location lCatapult)
{

    object oCat = CreateObject(OBJECT_TYPE_PLACEABLE, "q2a_bat1drowcat", lCatapult);

    CreateObject(OBJECT_TYPE_CREATURE, "q2a_drowcatteam", lCatapult);
    CreateObject(OBJECT_TYPE_CREATURE, "q2a_drowcatteam", lCatapult);
}

//Spawn a group of attackers at a specific spot.
void SpawnGroupAt(int nFormation, string szResRef, object oTarget, location lSpawn)
{
    //object oPC = GetFirstPC();
    if (GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetObjectByTag("q2ainnergate");
    object oBattleMaster = GetObjectByTag("bat1_battlemaster");
    //Track how many Drow formations have been created (for retreat purposes)

    SetLocalInt(oBattleMaster, "nBattle1DrowFormCount", GetLocalInt(oBattleMaster, "nBattle1DrowFormCount") + 1);

    //location lSpawn = GetLocation(GetWaypointByTag("wp_bat1_drowspawn" + IntToString(Random(3) + 1)));
    int nCount;
    object oCreature;
    object oGate = GetObjectByTag("q2acitygate");
    int nAdvance = TRUE;
    if (GetIsObjectValid(oGate) == TRUE)
        nAdvance = FALSE;
    for (nCount = 1; nCount < 6; nCount++)
    {
        oCreature = CreateObject(OBJECT_TYPE_CREATURE, szResRef, lSpawn, FALSE, szResRef + IntToString(nFormation) + IntToString(nCount));
        if (nCount == 1)
        {
            //Store a pointer to the leader of each group on the battlemaster
            SetLocalObject(oBattleMaster, "oFormationLeader" + IntToString(nFormation), oCreature);

            SetLocalInt(oCreature, "nLeader", 1);                     //ADVANCE
            DelayCommand(2.0, SignalEvent(oCreature, EventUserDefined(5000)));
        }
        SetLocalInt(oCreature, "nFormation", nFormation);
        SetLocalObject(oCreature, "oTarget", oTarget);
        //KLUDGE ATTEMPT
        if (nAdvance == TRUE)
            DelayCommand(IntToFloat(nCount), AssignCommand(oCreature, ActionMoveToObject(oTarget, TRUE)));
        //SendMessageToPC(oPC, GetTag(oCreature));
    }
    SetFormation(nFormation, szResRef);
}

//All group members should know of each other group member.
void SetFormation(int nFormation, string szResRef)
{
//    all members of the formation will have pointers to all other members stored locally
    object oPC = GetFirstPC();
    int nCount = 1;
    int nCount2 = 1;
    object oFormMember;
    object oPointer;
    for (nCount = 1; nCount < 6; nCount++)
    {
        oFormMember = GetObjectByTag(szResRef + IntToString(nFormation) + IntToString(nCount));
        //SendMessageToPC(oPC, "oFormMember" + IntToString(nCount) + " gets:");

        for (nCount2 = 1; nCount2 < 6; nCount2++)
        {
            oPointer = GetObjectByTag(szResRef + IntToString(nFormation) + IntToString(nCount2));
            SetLocalObject(oFormMember, "oFormMember" + IntToString(nCount2), oPointer);
            //SendMessageToPC(oPC, GetTag(oPointer));
        }
    }

}
