// * Joins, takes away other people's personal items, give player his personal item
/*
Patch 1.72

- made the script compatible with increased number of henchmens via custom content
*/

#include "nw_i0_henchman"

void main()
{//DestroyAllPersonalItems(GetPCSpeaker()); DONE IN THE GIVBE ITEM FUNCTION
 // * remove previous henchman

//SpeakString("test");
 if (GetIsObjectValid(GetHenchman(GetPCSpeaker(),GetMaxHenchmen())) == TRUE)
 {  SetFormerMaster(GetPCSpeaker(), GetHenchman(GetPCSpeaker()));
    object oHench =   GetHenchman(GetPCSpeaker());
    RemoveHenchman(GetPCSpeaker(), GetHenchman(GetPCSpeaker()));
    AssignCommand(oHench, ClearAllActions());
 }

 SetWorkingForPlayer(GetPCSpeaker());
 SetBeenHired();
 SetFormerMaster(GetPCSpeaker(), OBJECT_SELF);

 ExecuteScript("NW_CH_JOIN", OBJECT_SELF);
 GivePersonalItem(GetPCSpeaker());
}
