#include "nw_inc_nui"

void main()
{
    
    json jLeftDrawListCoords = NuiBind("leftdrawlist");
    json jLeftDrawList = NuiDrawListPolyLine(JsonBool(1), NuiColor(200, 200, 200), JsonBool(0), JsonFloat(5.0), jLeftDrawListCoords);
    json jLeftDrawListArray = JsonArray();
    jLeftDrawListArray = JsonArrayInsert(jLeftDrawListArray, jLeftDrawList);
    
    json jRightDrawListCoords = NuiBind("rightdrawlist");
    json jRightDrawList = NuiDrawListPolyLine(JsonBool(1), NuiColor(200, 200, 200), JsonBool(0), JsonFloat(5.0), jRightDrawListCoords);
    json jRightDrawListArray = JsonArray();
    jRightDrawListArray = JsonArrayInsert(jRightDrawListArray, jRightDrawList);
    
    json jLabelLeft = NuiLabel(JsonString(""), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE));
    jLabelLeft = NuiDrawList(jLabelLeft, JsonBool(0), jLeftDrawListArray);
    
    json jLabelRight = NuiLabel(JsonString(""), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE));
    jLabelRight = NuiDrawList(jLabelRight, JsonBool(0), jRightDrawListArray);
    
    
    json jFirstPlus = NuiId(NuiHeight(NuiButton(JsonString("+")), 40.0), "firstplus");
    json jSecondPlus = NuiId(NuiHeight(NuiButton(JsonString("+")), 40.0), "secondplus");
    json jFirstMinus = NuiId(NuiHeight(NuiButton(JsonString("-")), 40.0), "firstminus");
    json jSecondMinus = NuiId(NuiHeight(NuiButton(JsonString("-")), 40.0), "secondminus");
    
    json jLabelArray = JsonArray();
    jLabelArray = JsonArrayInsert(jLabelArray, jLabelLeft);
    //jLabelArray = JsonArrayInsert(jLabelArray, jLabelRight);
    
    json jPlusButtons = JsonArray();
    jPlusButtons = JsonArrayInsert(jPlusButtons, jFirstPlus);
    jPlusButtons = JsonArrayInsert(jPlusButtons, jSecondPlus);
    
    json jMinusButtons = JsonArray();
    jMinusButtons = JsonArrayInsert(jMinusButtons, jFirstMinus);
    jMinusButtons = JsonArrayInsert(jMinusButtons, jSecondMinus);
    
    json jBottomButton = NuiId(NuiHeight(NuiButton(JsonString("-")), 40.0), "action");
    json jDrawListElements = JsonArray();
    json jPoints = JsonArray();
    jPoints = JsonArrayInsert(jPoints, JsonFloat(4.0));
    jPoints = JsonArrayInsert(jPoints, JsonFloat(4.0));
    
    jPoints = JsonArrayInsert(jPoints, JsonFloat(36.0));
    jPoints = JsonArrayInsert(jPoints, JsonFloat(4.0));
    
    jPoints = JsonArrayInsert(jPoints, JsonFloat(36.0));
    jPoints = JsonArrayInsert(jPoints, JsonFloat(36.0));
    
    jPoints = JsonArrayInsert(jPoints, JsonFloat(4.0));
    jPoints = JsonArrayInsert(jPoints, JsonFloat(36.0));
    
    jDrawListElements = JsonArrayInsert(jDrawListElements, NuiDrawListPolyLine(JsonBool(1), NuiColor(100, 0, 0), JsonBool(1), JsonFloat(0.0), jPoints));
    jBottomButton = NuiDrawList(jBottomButton, JsonBool(0), jDrawListElements);
    
    json jBottomButtonArray = JsonArray();
    jBottomButtonArray = JsonArrayInsert(jBottomButtonArray, jBottomButton);
    
    json jLayout = JsonArray();
    jLayout = JsonArrayInsert(jLayout, NuiRow(jLabelArray));
    jLayout = JsonArrayInsert(jLayout, NuiRow(jPlusButtons));
    jLayout = JsonArrayInsert(jLayout, NuiRow(jMinusButtons));
    jLayout = JsonArrayInsert(jLayout, NuiRow(jBottomButtonArray));
    
    json root = NuiCol(jLayout);

    json nui = NuiWindow(
        root,
        JsonString("Maker Machine"),
        NuiBind("geometry"),
        JsonBool(FALSE), // resize
        JsonBool(FALSE), // collapse
        JsonBool(TRUE), // closable
        JsonBool(FALSE), // transparent
        JsonBool(TRUE)); // border
        
    object oPC = GetLastUsedBy();
    NuiDestroy(oPC, NuiFindWindow(oPC, "maker2cntrl"));
    int token = NuiCreate(GetLastUsedBy(), nui, "maker2cntrl");
    
    float fMidX = IntToFloat(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_WIDTH)/2);
    float fMidY = IntToFloat(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_HEIGHT)/2);
    
    NuiSetBind(oPC, token, "geometry", NuiRect(fMidX, fMidY, IntToFloat(350) + 20.0, IntToFloat(400) + 50.0 + 53.0));
    NuiSetBind(oPC, token, "codelabel", JsonString("00"));
    
}
