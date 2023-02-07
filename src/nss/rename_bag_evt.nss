#include "nw_inc_nui"

void main()
{
    object oPC = NuiGetEventPlayer();
    string sEvent = NuiGetEventType();
    int nToken = NuiGetEventWindow();
    string sElement = NuiGetEventElement();
    if (sElement == "button" && sEvent == "click")
    {
        string sNameString = JsonGetString(NuiGetBind(oPC, nToken, "name"));
        NuiDestroy(oPC, nToken);
        object oItem = GetLocalObject(oPC, "rename_bag_item");
        if (!GetIsObjectValid(oItem))
        {
            SendMessageToPC(oPC, "The item you tried to rename no longer exists.");
            return;
        }
        if (GetItemPossessor(oItem) != oPC)
        {
            SendMessageToPC(oPC, "You no longer own the item you tried to rename.");
            return;
        }
        
        SetName(oItem, "");
        string sBaseName = GetName(oItem);
        if (sNameString != "")
        {
            SetName(oItem, GetName(oItem) + " (" + sNameString + ")");
            SendMessageToPC(oPC, "Your " + sBaseName + " is now named " + GetName(oItem) + ".");
        }
        else
        {
            SendMessageToPC(oPC, "You reset the name of your " + sBaseName + ".");
        }
    }
}