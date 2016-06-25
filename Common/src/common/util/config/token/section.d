module common.util.config.token.section;

import common.util.config.token.base : Token;
import common.util.config.token.key : KeyToken;
import common.util.config.pair.base : Pair;
import common.util.config.parser : Parser;

import std.string : stripLeft;

debug import std.stdio : writeln, writefln;

class SectionToken : Token
{
    /**
     * The most recently parsed pairs.
     */
    public Pair[] pairs = [];

    /**
     * Count the length of this token in-context.
     *
     * Params:
     *      contents  =     the contents
     *      tokens    =     the token
     *
     * Returns: the length of the token, if there is one
     */
    public override uint count(string contents, Token[TypeInfo_Class] tokens)
    {
        if (contents.length < 3 || contents[0] != '[') {
            return 0;
        }

        auto stripped = contents[1..contents.length].stripLeft();
        auto offset = tokens[KeyToken.classinfo].count(stripped, tokens);

        stripped = stripped[offset..stripped.length].stripLeft();
        if (stripped.length == 0 || stripped[0] != ']') {
            return 0;
        }

        return 2 + offset;
    }

    /**
     * Parse the token.
     *
     * Params:
     *      contents  =     the contents
     *      tokens    =     the token
     *
     * Returns: the remainder of the contents
     */
    public override string parse(ref string contents, Token[TypeInfo_Class] tokens)
    {
        auto keyToken = cast(KeyToken) tokens[KeyToken.classinfo];

        contents = contents[1..contents.length].stripLeft();
        contents = keyToken.parse(contents, tokens);
        contents = contents.stripLeft();
        contents = contents[1..contents.length];

        auto key = keyToken.key;
        this.pairs = Parser.from(contents, tokens, false);

        foreach (ref pair; this.pairs) {
            pair.key = key ~ "." ~ pair.key;
        }

        return contents;
    }
}
