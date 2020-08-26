
// Determine whether or not to show the "Create DME Areas" option in the
//  wand conversation.  If there are any items in this list, then areas
//  have already been created, so we don't want to do that again.

#include "util_i_varlists"
#include "util_i_csvlists"
#include "dme_area_list"

int StartingConditional()
{
    return (!CountObjectList(GetModule(), "DME_AREAS") && CountList(sDMEAreas));
}
