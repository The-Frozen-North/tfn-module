// Clear the "pc has been in the ruins too long flag"
// that makes the Isle of the Maker duergar hostile against PCs
// This should be given to Cavallas and functions in the conditional slot

// If this is not done, the duergar will be immediately hostile to the PC
// and will be clustered around the ruins entrance, despite the fact
// the PC is coming from the boat

#include "util_i_csvlists"

int StartingConditional()
{
    object oArea = GetObjectByTag("ud_maker3");
    string sList = GetLocalString(oArea, "pcs_entered");
    object oPC = GetPCSpeaker();
    string sPC = GetPCPublicCDKey(oPC) + GetName(oPC);
    sList = RemoveListItem(sList, sPC);
    SetLocalString(oArea, "pcs_entered", sList);
    return 1;
}
