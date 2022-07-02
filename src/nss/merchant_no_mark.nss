#include "inc_merchant"

void main()
{
    string sMerchantTag = GetLocalString(OBJECT_SELF, "merchant");

    object oStore = GetObjectByTag(sMerchantTag);
    if (ShouldRestockMerchant(oStore))
    {
        oStore = AttemptMerchantRestock(oStore);
    }
    OpenStore(oStore, GetPCSpeaker());
}
