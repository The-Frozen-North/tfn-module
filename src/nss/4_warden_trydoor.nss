void main()
{
    object oWarden = GetNearestObjectByTag(GetLocalString(OBJECT_SELF, "warden"));

    object oPC = GetClickingObject();

    if (!GetIsPC(oPC)) return;

    if (IsInConversation(oWarden)) return;

    //SendMessageToPC(GetFirstPC(), "found "+GetName(oWarden));

    AssignCommand(oPC,ClearAllActions());
    AssignCommand(oWarden,ClearAllActions());
    AssignCommand(oWarden,ActionMoveToObject(oPC));
    AssignCommand(oWarden,ActionStartConversation(oPC));
}
