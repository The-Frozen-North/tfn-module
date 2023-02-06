#include "inc_general"
#include "inc_ctoken"
#include "nwnx_player"

int StartingConditional()
{
    NWNX_Player_SetCustomToken(GetPCSpeaker(), CTOKEN_ADVBOOK_RESPAWN_POINT, GetRespawnLocationName(GetPCSpeaker()));
    return 1;
}
