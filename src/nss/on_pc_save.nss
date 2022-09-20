#include "nwnx_events"
#include "nwnx_creature"
#include "inc_debug"
#include "inc_persist"

void main()
{
    if (!CanSavePCInfo(OBJECT_SELF))
    {
        NWNX_Events_SkipEvent();
    }
}
