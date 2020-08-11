#include "inc_debug"
#include "nwnx_area"
#include "nwnx_player"

// thanks for the fix, BlakBat
void AREA_FIXME(object oPC)
{
  object oArea = GetArea(oPC);
  string sData = NWNX_Player_GetAreaExplorationState(oPC, oArea);

  ExploreAreaForPlayer(oArea, oPC, FALSE);
  NWNX_Player_SetAreaExplorationState(oPC, oArea, sData);
}

int CheckLinkThenDestroyArea(object oArea)
{
    int bPlayersInLinkedArea = FALSE;

    object oLink1 = GetObjectByTag(GetLocalString(oArea, "link1"));
    object oLink2 = GetObjectByTag(GetLocalString(oArea, "link2"));
    object oLink3 = GetObjectByTag(GetLocalString(oArea, "link3"));

    if (NWNX_Area_GetNumberOfPlayersInArea(oLink1) > 0)  bPlayersInLinkedArea = TRUE;
    if (NWNX_Area_GetNumberOfPlayersInArea(oLink2) > 0)  bPlayersInLinkedArea = TRUE;
    if (NWNX_Area_GetNumberOfPlayersInArea(oLink3) > 0)  bPlayersInLinkedArea = TRUE;

    int bPlayerInInvalidArea = FALSE;

    object oPC = GetFirstPC();

    while (GetIsObjectValid(oPC))
    {
        if (!GetIsObjectValid(GetArea(oPC))) { bPlayerInInvalidArea = TRUE; break; }
        oPC = GetNextPC();
    }

    if (bPlayerInInvalidArea)
    {
        SendDebugMessage("cannot reset area "+GetResRef(oArea)+" because player is in invalid area", TRUE);
        return -4;
    }
    else if (bPlayersInLinkedArea)
    {
        SendDebugMessage("cannot reset area "+GetResRef(oArea)+" because player is in linked area", TRUE);
        return -3;
    }
    else
    {
        int nDestroy = DestroyArea(oArea);

        object oPCFix = GetFirstPC();
        while (oPCFix != OBJECT_INVALID)
        {
           DelayCommand(0.0f, AREA_FIXME(oPCFix));
           oPCFix = GetNextPC();
        }

        return nDestroy;
    }
}

void main()
{
    string sResRef = GetLocalString(OBJECT_SELF, "resref");
    object oArea = GetObjectByTag(sResRef);


// only start counting if the area exists and the refresh counter is there
    int nRefresh = GetLocalInt(OBJECT_SELF, "refresh");
    if (GetIsObjectValid(oArea) && nRefresh > 0)
    {
        SetLocalInt(OBJECT_SELF, "refresh", nRefresh+1);

        if (nRefresh >= 300)
        {
             int nStatus = CheckLinkThenDestroyArea(oArea);
             SendDebugMessage("destroying area "+sResRef+": "+IntToString(nStatus), TRUE);
// reset the count
             if (nStatus == 1)
             {
                SendDebugMessage("creating area "+sResRef, TRUE);
                object oNewArea = CreateArea(sResRef);
                ExecuteScript("area_init", oNewArea);

                DeleteLocalInt(OBJECT_SELF, "refresh");
             }
             else if (nStatus == -2)
             {
                SetLocalInt(OBJECT_SELF, "refresh", 200);
             }
        }
    }
// create the area if it doesn't exist
    else if (!GetIsObjectValid(oArea))
    {
        SendDebugMessage("creating area "+sResRef, TRUE);
        object oNewArea = CreateArea(sResRef);
        ExecuteScript("area_init", oNewArea);
    }
}

