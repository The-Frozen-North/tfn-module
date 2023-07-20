void main()
{
    object oPC = GetPlaceableLastClickedBy();
    if (GetIsPC(oPC) && GetDistanceToObject(oPC) <= 15.0)
    {
        ActionStartConversation(GetPlaceableLastClickedBy(), "", TRUE);
    }
}
