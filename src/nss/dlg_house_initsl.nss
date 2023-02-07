#include "inc_housing"

void main()
{
    SetCustomToken(CTOKEN_HOUSE_SELLPRICE, IntToString(GetHouseSellPrice(GetPCSpeaker())));
}
