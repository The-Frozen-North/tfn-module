#include "x0_i0_spells"

void main()
{
	object oTarget = GetSpellTargetObject();
	int nSpellID = GetSpellId();
	DoPetrification(GetHitDice(OBJECT_SELF), OBJECT_SELF, oTarget, nSpellID, 8);
}