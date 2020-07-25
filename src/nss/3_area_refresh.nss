#include "1_inc_debug"

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
             int nStatus = DestroyArea(oArea);
             SendDebugMessage("destroying area "+sResRef+": "+IntToString(nStatus), TRUE);
// reset the count
             if (nStatus == 1)
             {
                SendDebugMessage("creating area "+sResRef, TRUE);
                object oNewArea = CreateArea(sResRef);
                ExecuteScript("3_area_init", oNewArea);

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
        ExecuteScript("3_area_init", oNewArea);
    }
}

