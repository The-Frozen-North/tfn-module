void main()
{
    object oUser = GetLastUsedBy();

    if (!GetIsPC(oUser))
        return;

    ActionStartConversation(oUser, "alterator", TRUE);
}
