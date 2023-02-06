#include "inc_ctoken"

void main()
{
    SetCustomToken(CTOKEN_HOUSE_GOLDSTORAGE, IntToString(GetCampaignInt(GetPCPublicCDKey(GetPCSpeaker()), "gold")));
}
