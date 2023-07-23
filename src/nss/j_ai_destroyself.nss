/*/////////////////////// [Destroy Ourself] ////////////////////////////////////
    Filename: J_AI_DestroySelf
///////////////////////// [Destroy Ourself] ////////////////////////////////////
    This is executed OnDeath to clean up the corpse. It helps - clears all
    non-droppable stuff.

    It is not fired if there are corpses or whatever :-)

    Sorts destroyed things.

    Oh, if this is executed any other time when they are dead, they are
    destroyed instantly.
///////////////////////// [History] ////////////////////////////////////////////
    1.3 - Added to replace a include function for death.
        - No locals are destroyed. The game should do that anyway. Items are, though.
    1.4 -
///////////////////////// [Workings] ///////////////////////////////////////////
    this, if ever fired, will destroy the creature. It is not deleayed - there
    is a special function in the death script to check the whole "Did I get
    raised?" stuff.

    I suppose you can edit this to put a corpse in :-D
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: N/A - none needed.
///////////////////////// [Destroy Ourself] //////////////////////////////////*/


// Exectued from death, to speed things up.
#include "J_INC_CONSTANTS"

// This will delete all un-droppable items, before they fade out.
void DeleteAllThings();
// Used in DeleteAllThings.
void ClearSlot(int iSlotID);

void main()
{
    // To not crash limbo. Destroying in limbo crashes a server (1.2 bugfix)
    if(GetIsObjectValid(GetArea(OBJECT_SELF)))
    {
        // Must be dead.
        if(GetIsDead(OBJECT_SELF))
        {
            // Totally dead - no death file, no raising.
            SetAIInteger(I_AM_TOTALLY_DEAD, TRUE);
            // Ok, we are going to set we are lootable (maybe)
            if(GetSpawnInCondition(AI_FLAG_OTHER_USE_BIOWARE_LOOTING, AI_OTHER_MASTER))
            {
                // As it is now destroyable, it should destroy itself if it has
                // no inventory. SetLootable is set up on spawn.
                // 75: "[Dead] Setting to selectable/destroyable (so we go) for Bioware corpses."
                DebugActionSpeakByInt(75);
                SetIsDestroyable(TRUE, FALSE, TRUE);
            }
            else // Destroy self normally
            {
                // Debug
                // 76: "[Dead] Destroying self finally."
                DebugActionSpeakByInt(76);
                DeleteAllThings();
                // Just in case, we set destroyable, but not raiseable.
                SetIsDestroyable(TRUE, FALSE, FALSE);
                // Remove plot/immoral/lootable flags JUST in case.
                SetPlotFlag(OBJECT_SELF, FALSE);
                SetImmortal(OBJECT_SELF, FALSE);
                SetLootable(OBJECT_SELF, FALSE);
                // Destroy ourselves
                DestroyObject(OBJECT_SELF);
            }
        }
    }
    // Note: we never do more then one death removal check. DM's can re-raise and kill a NPC if they wish.
}

// Used in DeleteAllThings.
void ClearSlot(int iSlotID)
{
    object oItem = GetItemInSlot(iSlotID);
    if(GetIsObjectValid(oItem) && !GetDroppableFlag(oItem))
        DestroyObject(oItem);
}
// This will delete all un-droppable items, before they fade out.
void DeleteAllThings()
{
    // Destroy all equipped slots - 0 to 18 (18 = NUM_INVENTORY_SLOTS)
    int iSlotID;
    for(iSlotID = 0; iSlotID <= NUM_INVENTORY_SLOTS; iSlotID++)
    {
        ClearSlot(iSlotID);
    }
    // Destroy all inventory items
    object oItem = GetFirstItemInInventory();
    while(GetIsObjectValid(oItem))
    {
        if(!GetDroppableFlag(oItem))
            DestroyObject(oItem);
        oItem = GetNextItemInInventory();
    }
}
