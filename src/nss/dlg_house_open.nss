#include "inc_housing"

void main()
{
    if (GetHouseCDKey(GetLocalString(OBJECT_SELF, "area")) == "")
    {
        ActionOpenDoor(OBJECT_SELF);
    }
}
