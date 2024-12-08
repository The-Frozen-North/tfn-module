#include "nw_inc_nui"
#include "inc_sqlite_time"
#include "inc_treasuremap"
#include "inc_horse"

void main()
{
    object oPC = NuiGetEventPlayer();
    string sEvent = NuiGetEventType();
    int nToken = NuiGetEventWindow();
    string sElement = NuiGetEventElement();
    object oMap = GetLocalObject(oPC, "opened_treasuremap");
    if (sEvent == "close")
    {
        if (!GetIsObjectValid(oMap))
        {
            return;
        }
        if (GetItemPossessor(oMap) != oPC)
        {
            SendMessageToPC(oPC, "You no longer own this map.");
            NuiDestroy(oPC, nToken);
            return;
        }
        string sNote = JsonGetString(NuiGetBind(oPC, nToken, "tmap_notes"));
        SetLocalString(oMap, "treasuremap_notes", sNote);
        if (sNote != "")
        {
            SetName(oMap, "Treasure Map - " + sNote);
        }
        else
        {
            SetName(oMap, "Treasure Map");
        }
    }
    if (sElement == "digbutton" && sEvent == "click")
    {
        int nNow = SQLite_GetTimeStamp();
        int nLast = GetLocalInt(oPC, "treasuremap_last_search");
        int nDiff = nNow - nLast;
        if (nNow < nLast)
        {
            return;
        }
        SetLocalInt(oPC, "treasuremap_last_search", nNow+6);
        
        if (!GetIsObjectValid(oMap) || GetItemPossessor(oMap) != oPC)
        {
            SendMessageToPC(oPC, "You no longer own this map.");
            NuiDestroy(oPC, nToken);
            return;
        }
        
        if (GetIsInCombat(oPC))
        {
            SendMessageToPC(oPC, "You cannot search for treasure while in combat.");
            SetLocalInt(oPC, "treasuremap_last_search", nNow+2);
            return;
        }
        
        if (GetIsMounted(oPC))
        {
            SendMessageToPC(oPC, "You cannot search the ground beneath your feet while on horseback.");
            SetLocalInt(oPC, "treasuremap_last_search", nNow+2);
            return;
        }
        
        DigForTreasure(oPC);
        
    }
}