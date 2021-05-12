/*

    Henchman Inventory And Battle AI

    This file contains some modifications of the default
    associate functions.

*/

#include "inc_hai_act"


const float henchMaxScoutDistance = 50.0;

// Modified form of ResetHenchmenState
// sets the henchmen to commandable, deletes locals
// having to do with doors and clears actions
// Modified by Tony K to clear more things
void HenchResetHenchmenState();


void HenchResetHenchmenState()
{
    SetCommandable(TRUE);
    DeleteLocalObject(OBJECT_SELF, "NW_GENERIC_DOOR_TO_BASH");
    DeleteLocalInt(OBJECT_SELF, "NW_GENERIC_DOOR_TO_BASH_HP");
    DeleteLocalInt(OBJECT_SELF, henchBuffCountStr);
    DeleteLocalInt(OBJECT_SELF, henchHealCountStr);
    SetAssociateState(NW_ASC_IS_BUSY, FALSE);
    ClearForceOptions();
    ClearAllActions();
}

