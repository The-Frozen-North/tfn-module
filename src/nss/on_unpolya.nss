#include "inc_itemevent"

void main()
{
    // Call item equip event for all the creature's normal items to reapply their stuff
    CallEquipEventsForEquippedItems(OBJECT_SELF);
}