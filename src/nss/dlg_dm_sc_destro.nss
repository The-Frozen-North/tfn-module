
// Determine whether or not to show the "Destroy DME Areas" option in the
//  wand conversation.  If there are any items in this list, then areas
//  have already been created, so we definitely want to be able to then.

#include "util_i_varlists"

int StartingConditional()
{
    if (!GetIsDM(GetPCSpeaker())) return FALSE;

    return (CountObjectList(GetModule(), "DME_AREAS"));
}
