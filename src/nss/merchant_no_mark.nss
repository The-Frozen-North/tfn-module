void main()
{
    string sMerchantTag = GetLocalString(OBJECT_SELF, "merchant");

    object oStore = GetObjectByTag(sMerchantTag);

    OpenStore(oStore, GetPCSpeaker());

}
