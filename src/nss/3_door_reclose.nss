#include "1_inc_respawn"

void main()
{
     DelayCommand(SECONDS_TO_RESPAWN/2.0, ActionCloseDoor(OBJECT_SELF));
}
