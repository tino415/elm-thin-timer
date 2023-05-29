# Unable to have universal create record

After migration to back4app, I found out that authorization
and authentication is not completeli straight forward.
In back4app, registration is simple create user request in
their database. I wanted to port mi wrapper of thin.dev to
this backend, but now I need to handle two kinds of decoders
for create result instead of just one for create entry.

I realize that in subscription I can use model, so I could set
some variable in modla that will tell if I'm waiting for create
user or create entry and parse result accordingly. But propably
better longterm solution would be to actually use different calls
for it? Kind of undecidable which way to go...
