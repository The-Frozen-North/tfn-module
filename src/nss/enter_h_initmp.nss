#include "inc_housing"

void main()
{
    object oPC = GetEnteringObject();

    if (GetIsPC(oPC))
        InitializeHouseMapPin(oPC);
}
