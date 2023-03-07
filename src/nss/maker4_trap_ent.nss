// Trap trigger on-enter:
// Maker sanctum trap

const int NUM_RINGS = 21;
const int CHARGE_TIME = 70;
const int CHARGE_DAMAGE_TIME_DRAINED = 20;

void StartVisualEffects()
{
    int i, j;
    string sTag;
    object oObject;
    effect eVis = EffectVisualEffect(VFX_DUR_PARALYZED);
    for(i = 1; i <= 4; i++)
    {
        sTag = "maker4_mirror" + IntToString(i);
        oObject = GetObjectByTag(sTag);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eVis, oObject);
        for (j=1; j<=2; j++)
        {
            object oPillar = GetObjectByTag("maker4_pillar" + IntToString(j));
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(VFX_BEAM_LIGHTNING, oPillar, BODY_NODE_CHEST), oObject);
        }
    }
}

void DoExplosion(object oSource, object oTest)
{
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectBeam(VFX_BEAM_ODD, oSource, BODY_NODE_CHEST, FALSE, 3.0), oTest, 2.0);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGBLUE), oTest);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d6(5)), oTest);
}


void TrapMonitor()
{
    // Make sure there are PCs in the area
    object oArea = GetArea(OBJECT_SELF);
    object oTest = GetFirstObjectInArea(oArea);
    int bPCsInArea = 0;
    while (GetIsObjectValid(oTest))
    {
        if (!GetIsDead(oTest) && (GetIsPC(oTest) || GetIsPC(GetMaster(oTest))))
        {
            bPCsInArea = 1;
            break;
        }
        oTest = GetNextObjectInArea(oArea);
    }

    int bActive = GetLocalInt(oArea, "trap_active");
    int i;
    if (!bPCsInArea)
    {
        bActive = 0;
        SetLocalInt(oArea, "trap_active", 0);
        SetLocalInt(oArea, "trap_charge", 0);
        // reset if it wasn't completed
        SetLocalInt(oArea, "trap_fired", 0);
        for (i=1; i<=4; i++)
        {
            SetLocalInt(oArea, "hitmirror" + IntToString(i), 0);
        }
    }
    // Check to see if mirrors are hit
    int bAllMirrorsHit = 1;
    for (i=1; i<=4; i++)
    {
        if (!GetLocalInt(oArea, "hitmirror" + IntToString(i)))
        {
            bAllMirrorsHit = 0;
        }
    }

    if (bAllMirrorsHit)
    {
        bActive = 0;
        SetLocalInt(oArea, "trap_active", 0);
        SetLocalInt(oArea, "trap_charge", 0);
        object oProgDoor = GetObjectByTag("maker4_trapdoor");
        SetLocked(oProgDoor, 0);
        AssignCommand(oProgDoor, ActionOpenDoor(oProgDoor));
        for (i=1; i<=2; i++)
        {
            object oSource = GetObjectByTag("maker4_beamsource" + IntToString(i));
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectBeam(VFX_BEAM_LIGHTNING, oSource, BODY_NODE_CHEST, FALSE, 0.3), oProgDoor, 2.0);
        }
    }

    int nNumMirrorsActive = 0;
    for (i=1; i<=4; i++)
    {
        if (!GetLocalInt(oArea, "hitmirror" + IntToString(i)))
        {
            nNumMirrorsActive++;
        }
    }

    // Remove remaining visuals if something ended the effect
    if (!bActive)
    {
        for (i=1; i<=4; i++)
        {
            string sTag = "maker4_mirror" + IntToString(i);
            object oMirror = GetObjectByTag(sTag);
            effect eTest = GetFirstEffect(oMirror);
            while (GetIsEffectValid(eTest))
            {
                DelayCommand(0.0, RemoveEffect(oMirror, eTest));
                eTest = GetNextEffect(oMirror);
            }
        }
    }

    int nCharge = GetLocalInt(oArea, "trap_charge");
    if (bActive) { nCharge += 4+nNumMirrorsActive; }


    // PCs shouldn't be able to get out of the area very easily
    // Force the door to be shut and locked
    object oDoor = GetObjectByTag("Maker4ToMaker3");
    if (bActive)
    {
        if (GetIsOpen(oDoor))
        {
            AssignCommand(oDoor, ActionCloseDoor(oDoor));
        }
        AssignCommand(oDoor, SetLocked(oDoor, 1));
    }
    else
    {
        AssignCommand(oDoor, SetLocked(oDoor, 0));
        if (!GetIsOpen(oDoor))
        {
            AssignCommand(oDoor, ActionOpenDoor(oDoor));
        }
    }

    // Blast everything PC related in the area if it's time to do that
    if (bActive && nCharge >= CHARGE_TIME)
    {
        nCharge -= CHARGE_DAMAGE_TIME_DRAINED;
        oTest = GetFirstObjectInArea(oArea);
        while (GetIsObjectValid(oTest))
        {
            if (!GetIsDead(oTest) && (GetIsPC(oTest) || GetIsPC(GetMaster(oTest))))
            {
                for (i=1; i<=2; i++)
                {
                    object oSource = GetObjectByTag("maker4_beamsource" + IntToString(i));
                    object oPillar = GetObjectByTag("maker4_pillar" + IntToString(i));
                    // Make damage come from pillars
                    AssignCommand(oPillar, DoExplosion(oSource, oTest));
                }
            }
            oTest = GetNextObjectInArea(oArea);
        }
    }

    // Make charge rings
    // Pillars are ~8.4 tall

    if (bActive)
    {
        int nChargesPerRing = CHARGE_TIME/(NUM_RINGS-1);
        float fHeightPerRing = 8.4/NUM_RINGS;
        float fScalePerRing = 0.4/NUM_RINGS;
        int nRings = 1 + (nCharge / nChargesPerRing);
        for (i=1; i<=2; i++)
        {
            object oPillar = GetObjectByTag("maker4_pillar" + IntToString(i));
            int j;
            vector vPillar = GetPosition(oPillar);
            for (j=0; j<nRings; j++)
            {
                vector vRing = vPillar;
                vRing.z += IntToFloat(j) * fHeightPerRing;
                location lRing = Location(oArea, vRing, 0.0);
                ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_SPELLTURNING, FALSE, 1.2 - fScalePerRing*j), lRing, 2.7);
            }

        }
    }


    SetLocalInt(oArea, "trap_charge", nCharge);


    if (bActive)
    {
        DelayCommand(3.0, TrapMonitor());
    }
}

void main()
{
    object oPC = GetEnteringObject();
    int nActive = GetLocalInt(GetArea(OBJECT_SELF), "trap_fired");
    if(nActive != 0 || !GetIsPC(oPC))
        return;
    SetLocalInt(GetArea(OBJECT_SELF), "trap_fired", 1);
    SetLocalInt(GetArea(OBJECT_SELF), "trap_active", 1);
    SetLocalInt(GetArea(OBJECT_SELF), "trap_charge", 0);
    TrapMonitor();
    StartVisualEffects();
}

