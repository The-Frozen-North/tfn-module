#include "nw_inc_nui"

void main()
{
    object oPC = GetLastUsedBy();
    if (!GetIsPC(oPC)) { return; }
    object oPrevUser = GetLocalObject(OBJECT_SELF, "last_user");
    if (GetIsObjectValid(oPrevUser))
    {
        int nPrevUserToken = NuiFindWindow(oPrevUser, "maker2cntrl");
        if (nPrevUserToken != 0)
        {
            int nPrevIsOkay = 1;
            if (GetArea(oPrevUser) != GetArea(OBJECT_SELF))
            {
                nPrevIsOkay = 0;
            }            
            else if (GetIsDead(oPrevUser))
            {
                nPrevIsOkay = 0;
            }
            else if (GetDistanceBetween(OBJECT_SELF, oPrevUser) > 10.0)
            {
                nPrevIsOkay = 0;
            }
            if (!nPrevIsOkay)
            {
                NuiDestroy(oPrevUser, nPrevUserToken);
            }
            else 
            {
                object oArea = GetArea(OBJECT_SELF);
                SendMessageToPC(oPC, "Someone else is using the controls right now, but you can see that the screen currently reads " + IntToString(GetLocalInt(oArea, "digit_left")) + IntToString(GetLocalInt(oArea, "digit_right")) + ".");
                return;
            }
        }
    }
    SetLocalObject(OBJECT_SELF, "last_user", oPC);
    
    json jLeftDrawListCoords = NuiBind("leftdrawlist");
    json jLeftDrawList = NuiDrawListPolyLine(JsonBool(1), NuiColor(200, 200, 200), JsonBool(0), JsonFloat(5.0), jLeftDrawListCoords);
    json jLeftDrawListArray = JsonArray();
    jLeftDrawListArray = JsonArrayInsert(jLeftDrawListArray, jLeftDrawList);
    
    json jRightDrawListCoords = NuiBind("rightdrawlist");
    json jRightDrawList = NuiDrawListPolyLine(JsonBool(1), NuiColor(200, 200, 200), JsonBool(0), JsonFloat(5.0), jRightDrawListCoords);
    json jRightDrawListArray = JsonArray();
    jRightDrawListArray = JsonArrayInsert(jRightDrawListArray, jRightDrawList);
    
    json jLabelLeft = NuiLabel(JsonString(""), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE));
    jLabelLeft = NuiDrawList(jLabelLeft, JsonBool(1), jLeftDrawListArray);
    
    json jLabelRight = NuiLabel(JsonString(""), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE));
    jLabelRight = NuiDrawList(jLabelRight, JsonBool(1), jRightDrawListArray);
    
    
    json jFirstPlus = NuiId(NuiHeight(NuiButton(JsonString("+")), 20.0), "firstplus");
    json jSecondPlus = NuiId(NuiHeight(NuiButton(JsonString("+")), 20.0), "secondplus");
    json jFirstMinus = NuiId(NuiHeight(NuiButton(JsonString("-")), 20.0), "firstminus");
    json jSecondMinus = NuiId(NuiHeight(NuiButton(JsonString("-")), 20.0), "secondminus");
    
    json jLabelArray = JsonArray();
    jLabelArray = JsonArrayInsert(jLabelArray, jLabelLeft);
    jLabelArray = JsonArrayInsert(jLabelArray, jLabelRight);
    
    json jPlusButtons = JsonArray();
    jPlusButtons = JsonArrayInsert(jPlusButtons, jFirstPlus);
    jPlusButtons = JsonArrayInsert(jPlusButtons, jSecondPlus);
    
    json jMinusButtons = JsonArray();
    jMinusButtons = JsonArrayInsert(jMinusButtons, jFirstMinus);
    jMinusButtons = JsonArrayInsert(jMinusButtons, jSecondMinus);
    
    float fBottomButtonHeight = 40.0;
    float fBottomButtonWidth = 200.0;
    
    json jBottomButton = NuiId(NuiWidth(NuiHeight(NuiButton(JsonString("-")), fBottomButtonHeight), fBottomButtonWidth), "action");
    json jDrawListElements = JsonArray();
    json jPoints = JsonArray();
    jPoints = JsonArrayInsert(jPoints, JsonFloat(4.0));
    jPoints = JsonArrayInsert(jPoints, JsonFloat(4.0));
    
    jPoints = JsonArrayInsert(jPoints, JsonFloat(fBottomButtonWidth - 4.0));
    jPoints = JsonArrayInsert(jPoints, JsonFloat(4.0));
    
    jPoints = JsonArrayInsert(jPoints, JsonFloat(fBottomButtonWidth - 4.0));
    jPoints = JsonArrayInsert(jPoints, JsonFloat(fBottomButtonHeight - 4.0));
    
    jPoints = JsonArrayInsert(jPoints, JsonFloat(4.0));
    jPoints = JsonArrayInsert(jPoints, JsonFloat(fBottomButtonHeight - 4.0));
    
    jDrawListElements = JsonArrayInsert(jDrawListElements, NuiDrawListPolyLine(JsonBool(1), NuiColor(100, 0, 0), JsonBool(1), JsonFloat(0.0), jPoints));
    jBottomButton = NuiDrawList(jBottomButton, JsonBool(0), jDrawListElements);
    
    json jBottomButtonArray = JsonArray();
    jBottomButtonArray = JsonArrayInsert(jBottomButtonArray, NuiSpacer());
    jBottomButtonArray = JsonArrayInsert(jBottomButtonArray, jBottomButton);
    jBottomButtonArray = JsonArrayInsert(jBottomButtonArray, NuiSpacer());
    
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
        
    NuiDestroy(oPC, NuiFindWindow(oPC, "maker2cntrl"));
    int token = NuiCreate(GetLastUsedBy(), nui, "maker2cntrl");
    
    float fWinSizeX = IntToFloat(310) + 20.0;
    float fWinSizeY = IntToFloat(350);
    
    float fMidX = IntToFloat(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_WIDTH)/2) - (fWinSizeX/2);
    float fMidY = IntToFloat(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_HEIGHT)/2) - (fWinSizeY/2);
    
    NuiSetBind(oPC, token, "geometry", NuiRect(fMidX, fMidY, fWinSizeX, fWinSizeY));
    NuiSetBind(oPC, token, "codelabel", JsonString("00"));
    
    SetScriptParam("pc", ObjectToString(oPC));
    SetScriptParam("token", IntToString(token));
    SetScriptParam("init", "init");
    ExecuteScript("maker2cntrl_evt");
}
