#include "inc_spells"

// True if the PC is NOT protected from evil

int StartingConditional()
{
	return !GetIsProtectedFromEvil(GetPCSpeaker());
}