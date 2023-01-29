#include "inc_debug"
void main()
{
    object oPC = GetPCSpeaker();

    if (GetIsDeveloper(oPC))
    {
        SetTime(GetTimeHour() + 4, GetTimeMinute(), GetTimeSecond(), GetTimeMillisecond());
    }
}

