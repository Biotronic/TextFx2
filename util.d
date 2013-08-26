module util;

import std.exception;

immutable(wchar)* toStringz(const(wchar)[] s) pure nothrow
in
{
    // The assert below contradicts the unittests!
    //assert(memchr(s.ptr, 0, s.length) == null,
    //text(s.length, ": `", s, "'"));
}
out (result)
{
    import core.stdc.string;
    if (result)
    {
        auto slen = s.length;
        while (slen > 0 && s[slen-1] == 0) --slen;
        debug assert(wcslen(result) == slen);
        assert(memcmp(result, s.ptr, slen) == 0);
    }
}
body
{
    /+ Unfortunately, this isn't reliable.
     We could make this work if string literals are put
     in read-only memory and we test if s[] is pointing into
     that.

     /* Peek past end of s[], if it's 0, no conversion necessary.
     * Note that the compiler will put a 0 past the end of static
     * strings, and the storage allocator will put a 0 past the end
     * of newly allocated char[]'s.
     */
     char* p = &s[0] + s.length;
     if (*p == 0)
     return s;
     +/

    // Need to make a copy
    auto copy = new wchar[s.length + 1];
    copy[0..s.length] = s[];
    copy[s.length] = 0;

    return assumeUnique(copy).ptr;
}