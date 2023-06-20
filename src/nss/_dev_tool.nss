void main()
{
    object oPC = GetItemActivator();
    AssignCommand(oPC, ActionStartConversation(oPC, "_dev_tool", TRUE));
}
