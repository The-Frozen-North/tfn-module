#include "x0_inc_henai"


void main()
{
    SendForHelp();

// 1 in 3 chance of playing the sleep vfx
    if (d3() == 1)
    {
        int nSize = GetCreatureSize(OBJECT_SELF);
        float fSize = IntToFloat(nSize) * 0.33;
        effect eVis = EffectVisualEffect(VFX_IMP_SLEEP, FALSE, fSize);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF);
    }


    SetCommandable(TRUE);

    ClearAllActions();

    SetCommandable(FALSE);
}
