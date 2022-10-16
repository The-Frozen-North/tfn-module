void main()
{
    if (GetIsPC(GetLastUsedBy()))
    {
        ActionStartConversation(GetLastUsedBy());
    }
}
