void main()
{
    if (GetIsPC(GetLastUsedBy()))
    {
        ActionPlayAnimation(ANIMATION_PLACEABLE_OPEN);
        ActionStartConversation(GetLastUsedBy(), "", TRUE);
    }
}
