#include "inc_debug"
void main()
{
    object oPC = GetPCSpeaker();

    if (GetIsDeveloper(oPC))
    {
        vector vPosition = GetPosition(oPC);
        SendMessageToPC(oPC, "x: " + FloatToString(vPosition.x) + "| y: " + FloatToString(vPosition.y) + "| z: " + FloatToString(vPosition.z));
    }
}

