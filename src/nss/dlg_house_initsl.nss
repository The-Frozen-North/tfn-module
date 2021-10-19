#include "inc_housing"

void main()
{
    SetCustomToken(23450, IntToString(GetHouseSellPrice(GetPCSpeaker())));
}
