void main()
{
     object oItem = GetItemActivated();
     ExecuteScript(GetResRef(oItem), GetItemActivator());
     ExecuteScript("is_" + GetTag(oItem), GetItemActivator());
     
     // General item containers should run the rename script
     if (GetBaseItemType(oItem) == BASE_ITEM_LARGEBOX)
     {
         ExecuteScript("rename_bag");
     }
}
