#include "inc_hai_constant"

void main()
{
    if (GetIsEnemy(GetLastAttacker()))
        AISpeakString(AI_SHOUT_I_WAS_ATTACKED);
}
