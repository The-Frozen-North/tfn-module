#include "inc_webhook"
#include "inc_cdkeyvars"

void main()
{
    ServerWebhook("The Frozen North is shutting down!", "The Frozen North server is shutting down for maintenance. Once the module is ready for play again, which will be shortly, we'll let you know.");
    UpdateAllCachedCdkeyDBs();
}
