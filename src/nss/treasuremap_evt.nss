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
        if (GetItemPossessor(oMap) != oPC)
        {
            SendMessageToPC(oPC, "You no longer own this map.");
            NuiDestroy(oPC, nToken);
            return;
        }
        if (!GetIsObjectValid(oMap))
        {
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
        if (nNow - nLast < 6)
        {
            return;
        }
        SetLocalInt(oPC, "treasuremap_last_search", nNow);
        
        if (!GetIsObjectValid(oMap) || GetItemPossessor(oMap) != oPC)
        {
            SendMessageToPC(oPC, "You no longer own this map.");
            NuiDestroy(oPC, nToken);
            return;
        }
        
        if (GetIsInCombat(oPC))
        {
            SendMessageToPC(oPC, "You cannot search for treasure while in combat.");
            return;
        }
        
        if (GetIsMounted(oPC))
        {
            SendMessageToPC(oPC, "You cannot search the ground beneath your feet while on horseback.");
            return;
        }
        
        
        location lSelf = GetLocation(oPC);
        int nSurfacemat = GetSurfaceMaterial(lSelf);
        if (!GetIsSurfacematDiggable(nSurfacemat))
        {
            AssignCommand(oPC, ClearAllActions());
            AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_GET_LOW));
            FadeToBlack(oPC, FADE_SPEED_MEDIUM);
            DelayCommand(2.0, FadeFromBlack(oPC, FADE_SPEED_MEDIUM));
            if (DoesLocationCompleteMap(oMap, lSelf))
            {
                NuiDestroy(oPC, nToken);
                string sMessage = "You look carefully beneath your feet and find the hidden treasure!";
                if (nSurfacemat == 4 || nSurfacemat == 22)
                {
                    sMessage = "After a careful search, you find the hidden treasure beneath a loose stone!";
                }
                else if (nSurfacemat == 5)
                {
                    sMessage = "After a careful search, you find the hidden treasure beneath a loose plank!";
                }
                else if (nSurfacemat == 9)
                {
                    sMessage = "After a careful search, you find the hidden treasure stashed beneath the carpet!";
                }
                DelayCommand(4.0, FloatingTextStringOnCreature(sMessage, oPC));
                DelayCommand(2.0, CompleteTreasureMap(oMap));
            }
            else
            {
                DelayCommand(4.0, SendMessageToPC(oPC, "The ground here is too hard to dig. Despite searching carefully, you find no sign of the treasure here."));
            }
        }
        else
        {
            ExecuteScript("is_shovel", oPC);
        }
        
    }
}