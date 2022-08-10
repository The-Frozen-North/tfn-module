void BeLocked()
{
    ActionCloseDoor(OBJECT_SELF);
    SetLocked(OBJECT_SELF, TRUE);
    SetLockKeyRequired(OBJECT_SELF, TRUE);
    SpeakString("There is a clattering sound from the door. It seems as though some power has sealed it.");
}

void LockTheDoor()
{
    object oArea = GetArea(OBJECT_SELF);
    object oDoor;
    if (!GetIsObjectValid(GetLocalObject(oArea, "interiordoor")))
    {
        oDoor = GetObjectByTag("HH_LichInteriorDoor");
        SetLocalObject(oArea, "interiordoor", oDoor);
    }
    if (!GetLocked(oDoor))
    {
        AssignCommand(oDoor, BeLocked());
    }
}

void SpawnSkeleton(string sResRef, location lLoc)
{
    object oArea = GetArea(OBJECT_SELF);
    int nSlot = -1;
    int i;
    for (i=1; i<=10; i++)
    {
        object oSkele = GetLocalObject(oArea, "hh_skeletons_" + IntToString(i));
        if (!GetIsObjectValid(oSkele) || GetIsDead(oSkele))
        {
            nSlot = i;
            break;
        }
    }
    if (nSlot == -1)
    {
        return;
    }
    string sVar = "hh_skeletons_" + IntToString(nSlot);
    DeleteLocalObject(oArea, sVar);
    object oNew = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lLoc);
    SetLocalInt(oNew, "no_credit", 1);
    SetLocalObject(oArea, sVar, oNew);
}

void SpawnSkeletons()
{
    int nCurrentHP = GetCurrentHitPoints();
    int nMaxHP = GetMaxHitPoints();
    int nSkeles = 2;
    if (nCurrentHP * 5 < nMaxHP)
    {
        nSkeles = 5;
    }
    else if (nCurrentHP * 5 < nMaxHP)
    {
        nSkeles = 4;
    }
    else if (nCurrentHP * 2 < nMaxHP)
    {
        nSkeles = 3;
    }
    object oPhylactery = GetObjectByTag("HH_LichPhylactery");
    int bPhylacteryDestroyed = GetIsDead(oPhylactery) || !GetIsObjectValid(oPhylactery);
    if (!bPhylacteryDestroyed)
    {
        SetLocalInt(OBJECT_SELF, "PhylacteryAlive", 1);
        object oArea = GetArea(OBJECT_SELF);
        int nNumAliveSkeles = 0;
        int i;
        for (i=1; i<=10; i++)
        {
            object oSkele = GetLocalObject(oArea, "hh_skeletons_" + IntToString(i));
            if (GetIsObjectValid(oSkele) && !GetIsDead(oSkele))
            {
                nNumAliveSkeles++;
            }
        }
        int nNumSkelesToSpawn = nSkeles - nNumAliveSkeles;
        //SpeakString("I have " + IntToString(nNumAliveSkeles) + " of " + IntToString(nSkeles) + " target skellies.");
        if (nNumSkelesToSpawn > 0)
        {
            object oCentre = GetObjectByTag("HH_LichCentralPoint");
            for (i=0; i<nNumSkelesToSpawn; i++)
            {
                if (Random(100) >= (nNumSkelesToSpawn*20)) { continue; }
                int bFurthest = 1;
                int nRoll = Random(6);
                string sResRef = "";
                
                if (nRoll <= 2)
                {
                    bFurthest = 0;
                    sResRef = "skeleton_warrior";
                }
                else if (nRoll == 3)
                {
                    sResRef = "skeleton_archer";
                }
                else if (nRoll == 4)
                {
                    sResRef = "skeleton_mage";
                }
                else
                {
                    sResRef = "skeleton_priest";
                }
                float fBestDistance = bFurthest ? -1.0 : 999999.0;
                location lBest;
                object oBeamTarget;
                object oBestWP;
                int j;
                for (j=1; j<=5; j++)
                {
                    object oWP = GetWaypointByTag("HH_LichSkeleSpawn" + IntToString(j));
                    if (GetLocalInt(oWP, "HH_WaypointUsed")) { continue; }
                    location lWP = GetLocation(oWP);
                    object oNearest = GetNearestCreatureToLocation(CREATURE_TYPE_IS_ALIVE, TRUE, lWP, 1, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
                    float fThisDistance = GetDistanceBetween(oWP, oNearest);
                    if (bFurthest)
                    {
                        if (fThisDistance > fBestDistance)
                        {
                            fBestDistance = fThisDistance;
                            lBest = lWP;
                            oBestWP = oWP;
                            oBeamTarget = GetLocalObject(oWP, "HH_LichBeamTarget");
                        }
                    }
                    else
                    {
                        if (fThisDistance < fBestDistance)
                        {
                            fBestDistance = fThisDistance;
                            lBest = lWP;
                            oBestWP = oWP;
                            oBeamTarget = GetLocalObject(oWP, "HH_LichBeamTarget");
                        }
                    }
                }
                if (fBestDistance >= 0.0 && fBestDistance <= 9999.0)
                {
                    SetLocalInt(oBestWP, "HH_WaypointUsed", 1);
                    AssignCommand(GetModule(), DelayCommand(2.0, DeleteLocalInt(oBestWP, "HH_WaypointUsed")));
                    DelayCommand(IntToFloat(i), ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_RAISE_DEAD), lBest));
                    DelayCommand(IntToFloat(i), ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectBeam(VFX_BEAM_EVIL, oCentre, BODY_NODE_CHEST), oBeamTarget, 1.0)); 
                    DelayCommand(IntToFloat(i), ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectBeam(VFX_BEAM_EVIL, oPhylactery, BODY_NODE_CHEST), oCentre, 1.0)); 
                    //vector vPos = GetPosition(oCentre);
                    //AssignCommand(oCentre, SpeakString(FloatToString(vPos.x) + ", " + FloatToString(vPos.y) + ", "+FloatToString(vPos.z)));
                    
                    DelayCommand(IntToFloat(i+1), SpawnSkeleton(sResRef, lBest));
                }
            }
        }
    }
    else
    {
        if (GetLocalInt(OBJECT_SELF, "PhylacteryAlive"))
        {
            DeleteLocalInt(OBJECT_SELF, "PhylacteryAlive");
            SpeakString("You'll pay for your insolence!");
            PlayVoiceChat(VOICE_CHAT_CUSS);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(EffectHaste()), OBJECT_SELF);
        }
        
    }
}



void main()
{
    LockTheDoor();
    SpawnSkeletons();
}