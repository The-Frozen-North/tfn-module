
#include "util_i_color"
#include "util_i_varlists"
#include "nwnx_events"

void main()
{
    string PARTY_CHAT_COLOR = "PARTY_CHAT_COLOR";
    string PARTY_CHAT_COLORS = "PARTY_CHAT_COLORS";

    if (GetLocalInt(GetModule(), PARTY_CHAT_COLORS) == FALSE)
    {
        object oMod = GetModule();
        string sList = PARTY_CHAT_COLORS;
        AddListInt(oMod, COLOR_BLUE, sList);
        AddListInt(oMod, COLOR_ORANGE, sList);
        AddListInt(oMod, COLOR_GOLD, sList);
        AddListInt(oMod, COLOR_BLUE_LIGHT, sList);
        AddListInt(oMod, COLOR_VIOLET_LIGHT, sList);
        AddListInt(oMod, COLOR_YELLOW_LIGHT, sList);
        AddListInt(oMod, COLOR_CYAN, sList);

        SetLocalInt(oMod, PARTY_CHAT_COLORS, TRUE);
    }

    object oPC;
    string sEvent = NWNX_Events_GetCurrentEvent();
    if (sEvent == "NWNX_ON_PARTY_ACCEPT_INVITATION_AFTER")
    {
        oPC = StringToObject(NWNX_Events_GetEventData("INVITED_BY"));
        
        object oParty = GetFirstFactionMember(oPC, TRUE);
        while (GetIsObjectValid(oParty))
        {
            if (GetIsPC(oParty) && GetLocalInt(oPC, PARTY_CHAT_COLOR) == 0)
            {
                int nColors = CountIntList(GetModule(), PARTY_CHAT_COLORS);
                int nColor = GetListInt(GetModule(), Random(nColors) - 1, PARTY_CHAT_COLORS);
                SetLocalInt(oPC, PARTY_CHAT_COLOR, nColor);
                RemoveListInt(GetModule(), nColor, PARTY_CHAT_COLORS);
            }
            oParty = GetNextFactionMember(oPC, TRUE);            
        }

        return;
    }
    else if (sEvent == "NWNX_ON_PARTY_LEAVE")
        oPC = StringToObject(NWNX_Events_GetEventData("LEAVING"));
    else if (sEvent == "NWNX_ON_PARTY_KICK")
        oPC = StringToObject(NWNX_Events_GetEventData("KICKED"));
    else if (sEvent == "NWNX_ON_CLIENT_DISCONNECT_BEFORE")
        oPC = OBJECT_SELF;

    if (GetIsObjectValid(oPC))
    {
        int nColor = GetLocalInt(oPC, PARTY_CHAT_COLOR);
        if (nColor != 0)
            AddListInt(GetModule(), nColor, PARTY_CHAT_COLORS);
        
        DeleteLocalInt(oPC, PARTY_CHAT_COLOR);
    }
}