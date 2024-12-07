#include "inc_itemevent"

void main()
{
     object oItem = GetItemActivated();
     ExecuteScript(GetResRef(oItem), GetItemActivator());
     ItemEventCallEventOnItem(oItem, ITEM_EVENT_ACTIVATED, GetItemActivator(), TRUE);
     
     // General item containers should run the rename script
     if (GetBaseItemType(oItem) == BASE_ITEM_LARGEBOX)
     {
         ExecuteScript("rename_bag");
     }
}
