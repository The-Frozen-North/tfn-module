// this is a hack to store the object that a PC is conversing with, seems like that function isn't present

void main()
{
    SetLocalObject(GetPCSpeaker(), "last_conversation_object", OBJECT_SELF);
}
