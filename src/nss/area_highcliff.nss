#include "inc_sql"

// Any PCs who enter Highcliff will permanently be allowed to travel there by ship.
void main()
{
    object oPC = GetEnteringObject();

    if (GetIsPC(oPC)) SQLocalsPlayer_SetInt(oPC, "highcliff", 1);
}
