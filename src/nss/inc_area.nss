#include "util_i_csvlists"

// Add oToBeCleanedUp to oArea's cleanup list.
// When it is time for the area to be cleaned up, oToBeCleanedUp will be destroyed.
// Exceptions:
// if oToBeCleanedUp is an item, it is destroyed only if not owned by a creature
// if oToBeCleanedUp is a creature, it is destroyed only if it doesn't have a master (else PC followers will get destroyed)
void AddObjectToAreaCleanupList(object oArea, object oToBeCleanedUp);

// Destroy everything in oArea's cleanup list.
void ProcessAreaCleanupList(object oArea);



void AddObjectToAreaCleanupList(object oArea, object oToBeCleanedUp)
{
    json jArr = GetLocalJson(oArea, "cleanuplist");
    if (jArr == JsonNull())
    {
        jArr = JsonArray();
        SetLocalJson(oArea, "cleanuplist", jArr);
    }
    JsonArrayInsertInplace(jArr, JsonString(ObjectToString(oToBeCleanedUp)));
}

void ProcessAreaCleanupList(object oArea)
{
    json jArr = GetLocalJson(oArea, "cleanuplist");
    int nLength = JsonGetLength(jArr);
    int i;
    for (i=0; i<nLength; i++)
    {
        object oCurrent = StringToObject(JsonGetString(JsonArrayGet(jArr, i)));
        if (GetIsObjectValid(oCurrent))
        {
            int nObjType = GetObjectType(oCurrent);
            if (nObjType == OBJECT_TYPE_CREATURE)
            {
                // This variable is set on PC followers - followers should not be deleted when their parent area refreshes
                // as they'll most likely be in a different area and just inexplicably disappear
                // The follower system's scripts handle the destruction of the object instead
                if (GetLocalString(oCurrent, "master") == "")
                {
                    // This might allow new creatures to spawn directly on top of the old ones
                    // without it, they get offset a bit, and it makes guards etc not stand in the "neat" position every other refresh
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectCutsceneGhost(), oCurrent, 6.0);
                    DestroyObject(oCurrent);
                    // Remove from the quest npc list on the area
                    RemoveLocalListItem(OBJECT_SELF, "quest_npcs", ObjectToString(oCurrent));
                }
            }
            else if (nObjType == OBJECT_TYPE_ITEM)
            {
                if (!GetIsObjectValid(GetItemPossessor(oCurrent)))
                {
                    DestroyObject(oCurrent);
                }
            }
            else if (nObjType == OBJECT_TYPE_PLACEABLE)
            {
                // Old code checked for "master" local string like for followers, but I can't see anything in the codebase that is likely to set this
                // It also destroys all items in the inventory, this change already risks breaking enough that continuing to do that seems safest
                // though it may not necessarily be needed any more due to the personal loot system
                object oItem = GetFirstItemInInventory(oCurrent);
                while (GetIsObjectValid(oItem))
                {
                    DestroyObject(oItem);
                    oItem = GetNextItemInInventory(oCurrent);
                }
                DestroyObject(oCurrent);
            }
            else
            {
                DestroyObject(oCurrent);
            }
        }
    }
    SetLocalJson(oArea, "cleanuplist", JsonArray());
}