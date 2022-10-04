// This is a script file intended to be compiled into /development for testing.
// It IS useful because it means you can change includes and get a full recompile of all dependencies
// and know that they are being called
// The NWScript debug window, as nice as it is, can't do that!
// (and there's no batch file to put .nss into development at the moment, that seems messy anyway as the whole include tree would probably have to go in)

#include "inc_adventurer"

void main()
{
    object oAdv = SpawnAdventurer(GetLocation(OBJECT_SELF), ADVENTURER_PATH_WIZARD5PM7, 12);
}