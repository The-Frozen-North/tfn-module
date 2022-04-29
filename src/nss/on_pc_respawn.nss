#include "x0_i0_spells"

void main()
{
    object oRespawner = GetLastRespawnButtonPresser();

    //1.70: double respawn protection: if player isn't dead, dying or petrified, cancel respawn
    if (!GetIsDead(oRespawner) && !GetHasEffect(EFFECT_TYPE_PETRIFY,oRespawner))
    {
        return;
    }

    ExecuteScript("pc_respawn", oRespawner);
}
