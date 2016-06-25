module common.util.config.token.value;

import common.util.config.token.base : Token;

import std.string : indexOf;

class ValueToken : Token
{
    /**
     * The most recently parsed value.
     */
    public string value = "";

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
        uint length = 0;
        while (contents.length > 0 && "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -_'.!".indexOf(contents[0]) > -1) {
            length++;

            contents = contents[1..contents.length];
        }

        return length;
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
        this.value = "";
        while (contents.length > 0 && "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -_'.!".indexOf(contents[0]) > -1) {
            this.value ~= contents[0];

            contents = contents[1..contents.length];
        }

        return contents;
    }
}
