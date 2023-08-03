#include "inc_xp"

int StartingConditional()
{
    // fed and no longer hungry
    if (GetLocalInt(OBJECT_SELF, "fed") == 1) return FALSE;

    object oPC = GetPCSpeaker();

    object oItem = GetFirstItemInInventory(oPC);

    string sResRef = GetScriptParam("resref");

    while (GetIsObjectValid(oItem))
    {
        if (GetResRef(oItem) == sResRef)
        {
            AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_GET_LOW));

            SetLocalInt(OBJECT_SELF, "fed", 1);
            DelayCommand(600.0, DeleteLocalInt(OBJECT_SELF, "fed"));
            DestroyObject(oItem);
            GiveXPToPC(oPC, 3.0);
            return TRUE;
        }

        oItem = GetNextItemInInventory(oPC);
    }


    return FALSE;
}
