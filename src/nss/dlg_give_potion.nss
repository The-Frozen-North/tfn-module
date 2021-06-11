void main()
{
     object oPC = GetPCSpeaker();
     object oItem = GetItemPossessedBy(oPC, GetScriptParam("tag"));

     if (GetIsObjectValid(oItem))
     {
        ActionPauseConversation();

        int nStack = GetItemStackSize(oItem);

        if (nStack == 0)
        {
            DestroyObject(oItem);
        }
        else
        {
            SetItemStackSize(oItem, nStack - 1);
        }

        object oGivenItem = CopyItem(oItem, OBJECT_SELF);
        SetItemStackSize(oGivenItem, 1);

        AssignCommand(OBJECT_SELF, ActionUseItemOnObject(oGivenItem, GetFirstItemProperty(oGivenItem), OBJECT_SELF));

        ActionResumeConversation();
     }
}
