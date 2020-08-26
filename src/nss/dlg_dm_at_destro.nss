
// Determine whether or not to show the "Activate DME Portal" option in the
//  wand conversation.  If the entry waypoint "DME_Entry" does not exist,
//  then we shouldn't be able to activate the transition.

#include "util_i_varlists"
#include "util_i_csvlists"
#include "util_i_debug"

void main()
{
    object oDMEArea, oModule = GetModule();
    int i, nCount;
    string e, sDMEArea;
    
    while (i < CountObjectList(oModule, "DME_AREAS"))
    {
        oDMEArea = GetListObject(oModule, i);
        if (DestroyArea(oDMEArea) == 1)
            DeleteListObject(oModule, i, "DME_AREAS");
        else
            i++;
    }

    if (nCount = CountObjectList(oModule, "DME_AREAS"))
    {
        for (i = 0; i < nCount; i++)
        {
            sDMEArea = GetTag(GetListObject(oModule, i, "DME_AREAS"));
            e = AddListItem(e, sDMEArea);
        }

        Debug("The following DME area" + (CountList(e) == 1 ? "" : "s") + " could not be destroyed: " + e);
        DelayCommand(15.0, ExecuteScript("dlg_dm_at_destro", OBJECT_SELF));
    }
    else
        Debug("All DME areas have been destroyed.");
}
