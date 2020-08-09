int StartingConditional()
{
    object oMerchant = GetLocalObject(OBJECT_SELF, "travel_merchant");

    if (GetIsDead(oMerchant) || !GetIsObjectValid(oMerchant))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
