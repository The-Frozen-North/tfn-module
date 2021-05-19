#include "inc_merchant"

void main()
{
    object oMerchant = OBJECT_SELF;

    object oStore = GetLocalObject(OBJECT_SELF, "merchant");

    OpenMerchant(oMerchant, oStore, GetPCSpeaker());
}
