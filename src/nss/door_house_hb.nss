#include "inc_housing"

void main()
{
    if (GetIsOpen(OBJECT_SELF) && GetHouseCDKey(GetLocalString(OBJECT_SELF, "area")) == "")
    {
        int nClose = GetLocalInt(OBJECT_SELF, "close");

        if (nClose > 3)
        {
            ActionCloseDoor(OBJECT_SELF);
        }
        else
        {
            SetLocalInt(OBJECT_SELF, "close", nClose+1);
        }
    }
}
