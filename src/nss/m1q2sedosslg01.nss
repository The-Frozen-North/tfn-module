void main()
{
    if(GetLocalInt(OBJECT_SELF,"NW_L_RewardGiven"))
    {
        ClearAllActions();
        ActionForceMoveToObject(GetNearestObjectByTag("m1q2G_m1q2A"));
        ActionDoCommand(DestroyObject(OBJECT_SELF));
        SetCommandable(FALSE);
    }
}
