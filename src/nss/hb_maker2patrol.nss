#include "inc_ai_combat"

// Maker 2 golem patrol hb script
// This is set on patrollers when something enters the area
// so it can be self-clearing

object GetPatrolWPByIndex(int nIndex)
{
    if (nIndex > 16)
    {
        return GetPatrolWPByIndex(nIndex-16);
    }
    string sWP = "WP_q4b_scavenger_";
    // 0 padded waypoints are a headache and a half. Yikes.
    sWP = sWP + (nIndex <= 9 ? "0" : "") + IntToString(nIndex);
    return GetWaypointByTag(sWP);
}

void Restore(object oTarget)
{
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oTarget);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(9999), oTarget);
    DelayCommand(3.0, DeleteLocalObject(oTarget, "GS_CB_ATTACK_TARGET"));
    //DelayCommand(3.0, AssignCommand(oTarget, gsCBDetermineCombatRound()));
}

void main()
{
    if (GetIsInCombat(OBJECT_SELF))
    {
        return;
    }
    if (!GetCommandable())
    {
        return;
    }
    // This stops them trying to walk back to their original spawn location
    SetLocalInt(OBJECT_SELF, "ambient", 1);
    SetLocalInt(OBJECT_SELF, "no_wander", 1);
    // Check if PCs are in area
    int nPCInArea = 0;
    object oTest = GetFirstPC();
    object oArea = GetArea(OBJECT_SELF);
    while (GetIsObjectValid(oTest))
    {
        if (GetArea(oTest) == oArea)
        {
            nPCInArea = 1;
            break;
        }
        oTest = GetNextPC();
    }
    if (!nPCInArea)
    {
        int nCount = GetLocalInt(OBJECT_SELF, "no_pc_count");
        SetLocalInt(OBJECT_SELF, "no_pc_count", nCount+1);
        if (nCount > 50)
        {
            DeleteLocalInt(OBJECT_SELF, "no_pc_count");
            DeleteLocalString(OBJECT_SELF, "heartbeat_script");
        }
        
        return;
    }
    DeleteLocalInt(OBJECT_SELF, "no_pc_count");
    int bIsScavenger = GetResRef(OBJECT_SELF) == "maker2_scav";

    if (bIsScavenger)
    {
        location lSelf = GetLocation(OBJECT_SELF);
        object oTest = GetFirstObjectInShape(SHAPE_SPHERE, 20.0, lSelf);
        while (GetIsObjectValid(oTest))
        {
            if (GetLocalInt(oTest, "patrolgolem") && GetIsDead(oTest))
            {
                if (GetDistanceBetween(OBJECT_SELF, oTest) < 5.0)
                {
                    ClearAllActions();
                    ActionCastFakeSpellAtObject(SPELL_RESURRECTION, oTest);
                    ActionDoCommand(Restore(oTest));
                    return;
                }
                else
                {
                    ActionMoveToLocation(GetLocation(oTest), TRUE);
                    return;
                }
            }
            oTest = GetNextObjectInShape(SHAPE_SPHERE, 20.0, lSelf);
        }
    }



    int nLastWP = GetLocalInt(OBJECT_SELF, "patrolwaypoint");
    object oLastWP = GetPatrolWPByIndex(nLastWP);
    float fDist = GetDistanceBetween(OBJECT_SELF, oLastWP);
    if (fDist > 15.0)
    {
        // Something big might have happened (eg scav jumps), find the closest waypoint and take that to be the last
        float fClosest = 9999.0;
        int nBest;
        int i;
        object oWP;
        for (i=1; i<=16; i++)
        {
            oWP = GetPatrolWPByIndex(i);
            float fDist = GetDistanceBetween(OBJECT_SELF, oWP);
            if (fDist < fClosest)
            {
                fClosest = fDist;
                nBest = i;
            }                
        }
        //SpeakString("Large change, new = " + IntToString(nBest) + ", dist = " + FloatToString(fClosest));
        SetLocalInt(OBJECT_SELF, "patrolwaypoint", nBest);
        nLastWP = nBest;
        oLastWP = GetPatrolWPByIndex(nBest);
        fDist = fClosest;
    }
    
    
    
    if (fDist < 4.0)
    {
        ClearAllActions();
        int nNextWP = nLastWP + 1;
        if (nNextWP > 16) { nNextWP = 1; }
        SetLocalInt(OBJECT_SELF, "patrolwaypoint", nNextWP);
        ActionMoveToLocation(GetLocation(GetPatrolWPByIndex(nNextWP)));
        //SpeakString("Walk to next " + IntToString(nNextWP));
    }
    else
    {
        int nAction = GetCurrentAction();
        if (nAction == ACTION_INVALID || nAction == ACTION_WAIT || nAction == ACTION_MOVETOPOINT)
        {
            ClearAllActions();
            ActionMoveToLocation(GetLocation(oLastWP));
            //SpeakString("Walk to prev " + IntToString(nLastWP));
        }
    }
}
