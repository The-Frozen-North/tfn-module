
// Create all the DME areas from the resources put into the development folder

#include "util_i_csvlists"
#include "util_i_varlists"
#include "util_i_debug"
#include "dme_area_list"

void main()
{
    string e, sDMEArea;
    object oDMEArea;

    int i, nCount = CountList(sDMEAreas);
    for (i = 0; i < nCount; i++)
    {
        sDMEArea = GetListItem(sDMEAreas, i);
        oDMEArea = CreateArea(sDMEArea);

        if (!GetIsObjectValid(oDMEArea))
            e = AddListItem(e, sDMEArea);
        else
            AddListObject(GetModule(), oDMEArea, "DME_AREAS");
    }

    if (CountList(e))
        Debug("The following DME area" + (CountList(e) == 1 ? "" : "s") + " could not be created: " + e);
}
