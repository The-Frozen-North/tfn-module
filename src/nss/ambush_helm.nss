void SpawnAttacker(int nTarget, int nTargetKey)
{
    location lLocation = GetLocation(GetObjectByTag("WP_HELM_AMBUSH"+IntToString(nTarget)));

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_1), lLocation);
    object oCreature = CreateObject(OBJECT_TYPE_CREATURE, "helm_grunt", lLocation, FALSE, "helm_ambush");

    if (nTarget == nTargetKey)
    {
       object oKey = CreateItemOnObject("key", oCreature);
       SetPickpocketableFlag(oKey, TRUE);
       SetDroppableFlag(oKey, FALSE);
       SetName(oKey, "Temple of Helm Key");

       string sDescription = "This key was found in the Temple of Helm.";
       SetDescription(oKey, sDescription, FALSE);
       SetDescription(oKey, sDescription, TRUE);

       SetTag(oKey, "key_templeofhelm");
    }
}

void main()
{
    object oArea = GetObjectByTag("beg_helm1"); // get area by tag instead, because this script can be called from different areas

    if (GetLocalInt(oArea, "ambushed") == 1) return;

    SetLocalInt(oArea, "ambushed", 1);

    object oDoor = GetObjectByTag("HelmToBeggars");
    AssignCommand(oDoor, ActionCloseDoor(oDoor));
    SetLocked(oDoor, TRUE);
    SetLockKeyTag(oDoor, "key_templeofhelm");
    SetLockUnlockDC(oDoor, 21);


    object oLeorio = GetObjectByTag("leorio_tp");
    ChangeToStandardFaction(oLeorio, STANDARD_FACTION_HOSTILE);
    PlayVoiceChat(VOICE_CHAT_ATTACK, oLeorio);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_UNSUMMON), GetLocation(oLeorio));
    DestroyObject(oLeorio, 1.0);

    int nRandom = d3();


    DelayCommand(0.1, SpawnAttacker(1, nRandom));
    DelayCommand(0.2, SpawnAttacker(2, nRandom));
    DelayCommand(0.3, SpawnAttacker(3, nRandom));
}
