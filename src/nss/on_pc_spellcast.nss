#include "inc_hai_constant"

void main()
{
    object oCaster = GetLastSpellCaster();

    if (GetLastSpellHarmful() && GetIsEnemy(oCaster))
        AISpeakString(AI_SHOUT_I_WAS_ATTACKED);

}
