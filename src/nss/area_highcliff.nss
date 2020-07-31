#include "nwnx_object"

// Any PCs who enter Highcliff will permanently be allowed to travel there by ship.
void main()
{
    object oPC = GetEnteringObject();

    if (GetIsPC(oPC)) NWNX_Object_SetInt(oPC, "highcliff", 1, TRUE);
}
