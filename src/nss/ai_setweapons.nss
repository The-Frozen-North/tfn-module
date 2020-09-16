/************************ [Set Weapons] ****************************************
    Filename: ai_setweapons
************************* [Set Weapons] ****************************************
    Executed to re-set any weapons, or set them at spawn, using ExecuteScript.

    It isn't included in the generic AI or onspawn to try and speed it up a little
************************* [History] ********************************************
    1.3 - Added to a new file, removed from spawn include.
************************* [Workings] *******************************************
    It can be easily re-added to the spawn include, however, the generic AI calls
    it so little, that it may well be useful to keep a seperate file anyway.
************************* [Arguments] ******************************************
    Arguments: RESET_HEALING_KITS
************************* [Set Weapons] ***************************************/

#include "inc_ai_weapons"
void main()
{
    if(GetAIInteger(RESET_HEALING_KITS))
    {
        ResetHealingKits(OBJECT_SELF);
        DeleteAIInteger(RESET_HEALING_KITS);
    }
    else
    {
        // Set weapons if not
        SetWeapons(OBJECT_SELF);
    }
}
