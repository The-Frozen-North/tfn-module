#include "nwnx_object"

void main()
{
    // Randomise the puzzle.
    // Work out how many bookcases they are, if we haven't done it already.
    // This could be hardcoded or done on init, but organisation dictates doing it here I guess?
    int i;
    if (!GetLocalInt(OBJECT_SELF, "num_bookcases_1"))
    {
        int j;
        i = 1;
        // Outer: rooms
        while (1)
        {
            j = 1;
            // Inner: bookcases in each room
            while (1)
            {
                string sBookCase = "maker2_bookcase" + IntToString(i) + "_" + IntToString(j);
                object oBookCase = GetObjectByTag(sBookCase);
                if (!GetIsObjectValid(oBookCase))
                {
                    break;
                }
                SetUseableFlag(oBookCase, FALSE);
                SetPlotFlag(oBookCase, TRUE);
                NWNX_Object_SetPlaceableIsStatic(oBookCase, TRUE);
                SetEventScript(oBookCase, EVENT_SCRIPT_PLACEABLE_ON_USED, "maker2_bookcase");
                j++;
            }
            if (j == 1)
            {
                // This room doesn't actually exist as no bookcases were found in it
                SetLocalInt(OBJECT_SELF, "num_bookcase_rooms", i-1);
                break;
            }
            SetLocalInt(OBJECT_SELF, "num_bookcases_" + IntToString(i), j-1);
            WriteTimestampedLogEntry("Bookcases: room " + IntToString(i) + " has " + IntToString(j-1) + " cases");
            i++;
        }
    }
    else
    {
        int nNumRooms = GetLocalInt(OBJECT_SELF, "num_bookcase_rooms");
        // Revert old bookcases
        for (i=1; i<=nNumRooms; i++)
        {
            object oBookCase = GetLocalObject(OBJECT_SELF, "active_bookcase_" + IntToString(i));
            SetUseableFlag(oBookCase, FALSE);
            NWNX_Object_SetPlaceableIsStatic(oBookCase, TRUE);
            DeleteLocalInt(oBookCase, "active");
        }
    }
    int nNumRooms = GetLocalInt(OBJECT_SELF, "num_bookcase_rooms");
    int nActiveRoom = Random(nNumRooms) + 1;
    WriteTimestampedLogEntry("Active bookcase: " + IntToString(nActiveRoom) + " of " + IntToString(nNumRooms));
    for (i=1; i<=nNumRooms; i++)
    {
        int nNumBookCasesInThisRoom = GetLocalInt(OBJECT_SELF, "num_bookcases_" + IntToString(nNumRooms));
        int nActiveCaseInThisRoom = Random(nNumBookCasesInThisRoom) + 1;
        object oBookCase = GetObjectByTag("maker2_bookcase" + IntToString(i) + "_" + IntToString(nActiveCaseInThisRoom));
        NWNX_Object_SetPlaceableIsStatic(oBookCase, FALSE);
        SetUseableFlag(oBookCase, TRUE);
        if (i == nActiveRoom)
        {
            SetLocalInt(oBookCase, "active", 1);
        }
        SetLocalObject(OBJECT_SELF, "active_bookcase_" + IntToString(i), oBookCase);
    }
}