#include "nui_playerstats"
#include "inc_general"
#include "inc_xp"

string FormatTime(int nSeconds)
{
    int nDays = nSeconds / 86400;
    nSeconds = nSeconds - (nDays * 86400);
    int nHours = nSeconds / 3600;
    nSeconds = nSeconds - (nHours * 3600);
    int nMinutes = nSeconds / 60;
    nSeconds = nSeconds - (nMinutes * 60);
    string sOut = "";
    if (nDays > 0)
    {
        sOut = IntToString(nDays) + "d ";
    }
    if (nHours > 0)
    {
        sOut += IntToString(nHours) + "h ";
    }
    if (nMinutes > 0)
    {
        sOut += IntToString(nMinutes) + "m";
    }
    if (nMinutes < 1)
    {
        sOut += IntToString(nSeconds) + "s";
    }
    return sOut;
}

void _UpdateBind(object oPC, int nToken, string sBind, int bCDKeyDB=0)
{
    json jBindValue;
    // These ones will get updated more times than they needed to.
    // Which is unfortunate.
    if (sBind == "enemies_killed" || sBind == "enemies_killed_with_credit")
    {
        _UpdateBind(oPC, nToken, "percentage_kills_in_party", bCDKeyDB);
    }
    else if (sBind == "kill_xp_value" || sBind == "total_xp_from_partys_kills")
    {
        _UpdateBind(oPC, nToken, "percentage_xp_value_kills_in_party", bCDKeyDB);
    }
    
    if (sBind == "most_powerful_killed")
    {
        jBindValue = JsonString(GetPlayerStatisticString(oPC, sBind, bCDKeyDB));
    }
    else if (sBind == "percentage_kills_in_party")
    {
        int nPlayerKills = GetPlayerStatistic(oPC, "enemies_killed", bCDKeyDB);
        int nPartyKills = GetPlayerStatistic(oPC, "enemies_killed_with_credit", bCDKeyDB);
        if (nPartyKills == 0) { nPartyKills = 1; }
        string sPercent = NeatFloatToString(100.0*IntToFloat(nPlayerKills)/IntToFloat(nPartyKills));
        jBindValue = JsonString(sPercent + "%");
    }
    else if (sBind == "percentage_xp_value_kills_in_party")
    {
        int nPlayerKills = GetPlayerStatistic(oPC, "kill_xp_value", bCDKeyDB);
        int nPartyKills = GetPlayerStatistic(oPC, "total_xp_from_partys_kills", bCDKeyDB);
        if (nPartyKills == 0) { nPartyKills = 1; }
        string sPercent = NeatFloatToString(100.0*IntToFloat(nPlayerKills)/IntToFloat(nPartyKills));
        jBindValue = JsonString(sPercent + "%");
    }
    else if (sBind == "time_played" || sBind == "time_spent_in_house")
    {
        int nValue = GetPlayerStatistic(oPC, sBind, bCDKeyDB);
        jBindValue = JsonString(FormatTime(nValue));
    }
    else if (sBind == "kill_xp_value" || sBind == "total_xp_from_partys_kills")
    {
        // These values are saved x100 of the real one to get decimals in properly
        jBindValue = JsonInt(GetPlayerStatistic(oPC, sBind, bCDKeyDB)/100);
    }
    else
    {
        jBindValue = JsonInt(GetPlayerStatistic(oPC, sBind, bCDKeyDB));
    }
    NuiSetBind(oPC, nToken, sBind, jBindValue);
}

void main()
{
    object oPC = NuiGetEventPlayer();
    string sEvent = NuiGetEventType();
    int nToken = NuiGetEventWindow();
    string sElement = NuiGetEventElement();
    
    string sWindow = "pc_xpbar";
    
    // Do this first!
    HandleEditModeEvents();

    string sUpdateBind = GetScriptParam("updatebind");
    string sUpdateAllBinds = GetScriptParam("updateallbinds");

    if (sUpdateAllBinds != "" || sUpdateBind != "")
    {
        oPC = StringToObject(GetScriptParam("pc"));
        nToken = StringToInt(GetScriptParam("token"));
    }
    
    int bCDKeyDB = 0;
    json jUserData;
    if (sUpdateAllBinds != "" || sUpdateBind != "" || (sElement == "toggleallcharacters" && sEvent == "click"))
    {
        jUserData = NuiGetUserData(oPC, nToken);
        bCDKeyDB = JsonGetString(JsonObjectGet(jUserData, "activepanel")) == "player";
    }
    
    if (sEvent == "click" && sElement == "toggleallcharacters")
    {
        int nNow = SQLite_GetTimeStamp();
        if (JsonGetInt(JsonObjectGet(jUserData, "nextswitchtime")) <= nNow)
        {
            // Rate limit the switching
            // it has to set a lot of binds
            jUserData = JsonObjectSet(jUserData, "nextswitchtime", JsonInt(nNow+2));
            
            if (bCDKeyDB)
            {
                jUserData = JsonObjectSet(jUserData, "activepanel", JsonString("character"));
                NuiSetBind(oPC, nToken, "switchviewbuttontext", JsonString("View this Character's Stats"));
            }
            else
            {
                jUserData = JsonObjectSet(jUserData, "activepanel", JsonString("player"));
                NuiSetBind(oPC, nToken, "switchviewbuttontext", JsonString("View all Character Stats"));
            }
            bCDKeyDB = !bCDKeyDB;
            sUpdateAllBinds = "1";
            
            NuiSetUserData(oPC, nToken, jUserData);
        }
    }
    else if (sEvent == "click" && GetStringLeft(sElement, 9) == "category_")
    {
        jUserData = NuiGetUserData(oPC, nToken);
        string sCategory = GetSubString(sElement, 9, 99);
        if (sCategory != JsonGetString(JsonObjectGet(jUserData, "activecategory")))
        {
            int nNow = SQLite_GetTimeStamp();
            if (JsonGetInt(JsonObjectGet(jUserData, "nextcategorytime")) <= nNow)
            {
                // Rate limit the switching
                // it has to set a lot of binds
                jUserData = JsonObjectSet(jUserData, "nextcategorytime", JsonInt(nNow+1));
                json jContent = _PlayerStatsCategoryToNui(_GetPlayerStatsPanelBreakdown(), sCategory);
                NuiSetGroupLayout(oPC, nToken, "configarea", jContent);
                jUserData = JsonObjectSet(jUserData, "activecategory", JsonString(sCategory));
                NuiSetUserData(oPC, nToken, jUserData);
                sUpdateAllBinds = "1";
            }
        }
        
    }
    
    
    // do not change to else if
    // toggleallcharacters and category switches should do this as well
    if (sUpdateAllBinds != "")
    {
        json jPanel = _GetPlayerStatsPanelBreakdown();
        json jKeys = JsonObjectKeys(jPanel);
        int nLength = JsonGetLength(jKeys);
        int i;
        for (i=0; i<nLength; i++)
        {
            json jCategory = JsonArrayGet(jKeys, i);
            json jBinds = JsonObjectGet(jPanel, JsonGetString(jCategory));
            int nBindLength = JsonGetLength(jBinds);
            int j;
            for (j=0; j<nBindLength; j++)
            {
                json jBindData = JsonArrayGet(jBinds, j);
                string sBind = JsonGetString(JsonObjectGet(jBindData, "key"));
                _UpdateBind(oPC, nToken, sBind, bCDKeyDB);
            }
        }
    }
    else if (sUpdateBind != "")
    {
        _UpdateBind(oPC, nToken, sUpdateBind, bCDKeyDB);
    }
    
}
    
