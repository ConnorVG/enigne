module common.util.config.token.variable;

import common.util.config.token.base : Token;
import common.util.config.token.key : KeyToken;
import common.util.config.token.value : ValueToken;
import common.util.config.pair : Pair, StringPair;

import std.string : stripLeft;

class VariableToken : Token
{
    /**
     * The most recently parsed pair.
     */
    public Pair pair;

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
        auto keyOffset = tokens[KeyToken.classinfo].count(contents, tokens);
        if (keyOffset == 0) {
            return 0;
        }

        contents = contents[keyOffset..contents.length].stripLeft();
        if (contents.length == 0 || contents[0] != '=') {
            return 0;
        }

        contents = contents[1..contents.length].stripLeft();

        auto valueOffset = tokens[ValueToken.classinfo].count(contents, tokens);

        if (keyOffset == 0) {
            return 0;
        }

        return keyOffset + 1 + valueOffset;
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
        auto valueToken = cast(ValueToken) tokens[ValueToken.classinfo];

        contents = keyToken.parse(contents, tokens);
        contents = contents.stripLeft();
        contents = contents[1..contents.length];
        contents = contents.stripLeft();
        contents = valueToken.parse(contents, tokens);

        this.pair = new StringPair(keyToken.key, valueToken.value);

        return contents;
    }
}
