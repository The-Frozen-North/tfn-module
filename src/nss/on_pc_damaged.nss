#include "inc_general"

void main()
{
    PlayNonMeleePainSound(GetLastDamager());

    if (GetIsEnemy(GetLastDamager()))
    {
        SpeakString("PARTY_I_WAS_ATTACKED", TALKVOLUME_SILENT_TALK);
    }
}
