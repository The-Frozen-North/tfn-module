#include "inc_commoner"

void main()
{
    if (!GetIsInCombat(OBJECT_SELF)) ResumeCommonerBehavior();
}
