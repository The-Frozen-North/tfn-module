#include "nw_inc_nui"

void DisplayUI(object oItem, object oPC)
{
	json jLayout = JsonArray();
    
    json jLabel = NuiLabel(JsonString("Enter name for container (blank to reset):"), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE));
    jLabel = NuiWidth(jLabel, 300.0);
    jLayout = JsonArrayInsert(jLayout, jLabel);
    jLayout = JsonArrayInsert(jLayout, NuiTextEdit(JsonString(""), NuiBind("name"), 30, 0));
    json jButton = NuiId(NuiButton(JsonString("Rename")), "button");
    jLayout = JsonArrayInsert(jLayout, jButton);
    json root = NuiCol(jLayout);
    json nui = NuiWindow(
        root,
        JsonString("Rename Container"),
        NuiBind("geometry"),
        JsonBool(FALSE), // resize
        JsonBool(FALSE), // collapse
        JsonBool(TRUE), // closable
        JsonBool(FALSE), // transparent
        JsonBool(TRUE)); // border
    
    int token = NuiCreate(oPC, nui, "rename_bag");
    NuiSetBind(oPC, token, "geometry", NuiRect(500.0, 210.0, 350.0, 200.0));
    SetLocalObject(oPC, "rename_bag_item", oItem);
}


void main()
{
	object oItem = GetItemActivated();
	object oPC = GetItemPossessor(oItem);
    DisplayUI(oItem, oPC);
}