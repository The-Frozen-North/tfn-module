#include "inc_webhook"

void BeUnlocked()
{
    SetLocked(OBJECT_SELF, FALSE);
    SetLockKeyRequired(OBJECT_SELF, FALSE);
    ActionOpenDoor(OBJECT_SELF);
    SpeakString("The power sealing the door has been released, and the door slowly creaks open.");
}

void UnlockTheDoor()
{
    object oArea = GetArea(OBJECT_SELF);
    object oDoor;
    if (!GetIsObjectValid(GetLocalObject(oArea, "interiordoor")))
    {
        oDoor = GetObjectByTag("HH_LichInteriorDoor");
        SetLocalObject(oArea, "interiordoor", oDoor);
    }
    if (GetLocked(oDoor))
    {
        AssignCommand(oDoor, BeUnlocked());
    }
}

void KillTheSkeles()
{
    object oArea = GetArea(OBJECT_SELF);
    int i;
    for (i=1; i<=10; i++)
    {
        object oSkele = GetLocalObject(oArea, "hh_skeletons_" + IntToString(i));
        if (GetIsObjectValid(oSkele) && !GetIsDead(oSkele))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DEATH_L), oSkele);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(9999), oSkele);
        }
    }
}

void RespawnLichDelay(location lLoc)
{
    object oLich = CreateObject(OBJECT_TYPE_CREATURE, "lich_hh", lLoc);
    // Respawn with 40-60% hp left
    int nMax = 72;
    float fTargetPercentage = IntToFloat(40 + Random(20));
    int nTarget = FloatToInt(fTargetPercentage*IntToFloat(nMax)/100.0);
    int nDamage = nMax - nTarget;
    //SendMessageToAllDMs("target = " + IntToString(nTarget) + ", damage = " + IntToString(nDamage) + ", max = " + IntToString(nMax));
    DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage), oLich));
}

void RespawnLich()
{
    object oWP = GetWaypointByTag("HH_LichSpawn");
    object oCentre = GetObjectByTag("HH_LichCentralPoint");
    object oPhylactery = GetObjectByTag("HH_LichPhylactery");
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DEATH_L), oPhylactery);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectBeam(VFX_BEAM_EVIL, oPhylactery, BODY_NODE_CHEST), oCentre, 3.0);
    location lLoc = GetLocation(oWP);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_RAISE_DEAD), lLoc);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_LOS_EVIL_20), lLoc);
    AssignCommand(GetModule(), DelayCommand(2.0, RespawnLichDelay(lLoc)));
}

void SpawnTheLoot()
{
    object oWP = GetWaypointByTag("HH_LichSpawn");
    location lLoc = GetLocation(oWP);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_IMPLOSION), lLoc);
    object oLoot = CreateObject(OBJECT_TYPE_PLACEABLE, "treas_treasure_h", lLoc, FALSE, "HH_LichLoot");
    SetLocalInt(oLoot, "boss", 1);
    ExecuteScript("treas_init", oLoot);
}

void main()
{
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DEATH_L), OBJECT_SELF);
    object oPhylactery = GetObjectByTag("HH_LichPhylactery");
    int bPhylacteryDestroyed = GetIsDead(oPhylactery) || !GetIsObjectValid(oPhylactery);
    if (!bPhylacteryDestroyed)
    {
        DestroyObject(OBJECT_SELF);
        RespawnLich();
    }
    else
    {
        object oKiller = GetLastKiller();
        BossDefeatedWebhook(oKiller, OBJECT_SELF);
        // Now you spawn loot.
        DeleteLocalInt(OBJECT_SELF, "no_credit");
        ExecuteScript("party_credit", OBJECT_SELF);
        UnlockTheDoor();
        KillTheSkeles();
        SpawnTheLoot();
    }
}