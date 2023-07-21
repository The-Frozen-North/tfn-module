#include "nw_inc_nui"

string _ArrayToTextRows(json jArray)
{
    string sOut = "";
    int nLength = JsonGetLength(jArray);
    int i;
    for (i=0; i<nLength; i++)
    {
        sOut = sOut + JsonGetString(JsonArrayGet(jArray, i)) + "\n";
    }
    // Remove trailing newline
    sOut = GetStringLeft(sOut, GetStringLength(sOut)-1);
    return sOut;
}

void SpawnChild(object oPC, json jObjData)
{
    string sOld = _ArrayToTextRows(JsonObjectGet(jObjData, "oldprops"));
    string sNew = _ArrayToTextRows(JsonObjectGet(jObjData, "newprops"));
    
    string sBig = "Old Properties:\n\n" + sOld + "\n\nNew Properties:\n\n" + sNew;
    json jLayout = JsonArray();
    json jText = NuiText(JsonString(sBig), FALSE, NUI_SCROLLBARS_AUTO);
    jText = NuiWidth(jText, 375.0);
    jText = NuiHeight(jText, 350.0);
    jLayout = JsonArrayInsert(jLayout, jText);
    json jButtonRow = JsonArray();
    jButtonRow = JsonArrayInsert(jButtonRow, NuiSpacer());
    jButtonRow = JsonArrayInsert(jButtonRow, NuiWidth(NuiHeight(NuiId(NuiButton(JsonString("Close")), "closebut"), 35.0), 70.0));
    jButtonRow = JsonArrayInsert(jButtonRow, NuiSpacer());
    jLayout = JsonArrayInsert(jLayout, NuiRow(jButtonRow));
    string sName = JsonGetString(JsonObjectGet(jObjData, "name"));
    json jWindow = NuiWindow(NuiCol(jLayout), JsonString(sName), NuiRect(-1.0, -1.0, 400.0, 450.0), JsonBool(TRUE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(TRUE));
    int nToken = NuiCreate(oPC, jWindow, "itemchanges_child");
    // Use this file as the event script
    json jUserData = JsonObject();
    jUserData = JsonObjectSet(jUserData, "event_script", JsonString("itemchanges_evt"));
    NuiSetUserData(oPC, nToken, jUserData);
}

void main()
{
    object oPC = NuiGetEventPlayer();
    string sEvent = NuiGetEventType();
    int nToken = NuiGetEventWindow();
    string sElement = NuiGetEventElement();
    
    string sWindow = NuiGetWindowId(oPC, nToken);
    
    if (sWindow == "itemchanges")
    {
        if (sEvent == "click")
        {
            if (GetStringLeft(sElement, 8) == "inspect_")
            {
                string sObj = GetSubString(sElement, 8, 99);
                json jUserData = NuiGetUserData(oPC, nToken);
                json jObjData = JsonObjectGet(jUserData, sObj);
                SpawnChild(oPC, jObjData);
            }
        }
    }
    else if (sWindow == "itemchanges_child")
    {
        if (sEvent == "click" && sElement == "closebut")
        {
            NuiDestroy(oPC, nToken);
        }
    }
}