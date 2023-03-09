void Befriend(object oCreature)
{
    ClearPersonalReputation(oCreature, OBJECT_SELF);
    SetIsTemporaryFriend(oCreature, OBJECT_SELF);
    SetIsTemporaryFriend(OBJECT_SELF, oCreature);
}

void main()
{
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_NATURES_BALANCE), GetLocation(OBJECT_SELF));

    object oPC = GetFirstPC();

    if (!GetIsObjectValid(oPC))
        return;

    int nAssociateType;
    while (GetIsObjectValid(oPC))
    {
        Befriend(oPC);
        for (nAssociateType=1; nAssociateType<=5; nAssociateType++)
        {
            int n=1;
            object oTest;
            while (1)
            {
                oTest = GetAssociate(nAssociateType, oPC, n);
                if (!GetIsObjectValid(oTest))
                {
                    break;
                }
                Befriend(oTest);
                n++;
            }
        }
        oPC = GetNextPC();
    }
    
    DeleteLocalObject(OBJECT_SELF, "GS_CB_ATTACK_TARGET");
    if (GetCurrentAction(OBJECT_SELF) == ACTION_ATTACKOBJECT)
    {
        object oTarget = GetAttackTarget();
        if (GetIsPC(oTarget) || GetIsPC(GetMaster(oTarget)))
        {
            ClearAllActions(1);
        }
    }
}
