module common.util.config.token.key;

import common.util.config.token.base : Token;

import std.string : indexOf;

class KeyToken : Token
{
    /**
     * The most recently parsed key.
     */
    public string key = "";

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
        if ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".indexOf(contents[0]) == -1) {
            return 0;
        }

        uint length = 0;
        char last;
        while (contents.length > 0 && "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ._".indexOf(contents[0]) > -1) {
            length++;

            last = contents[0];
            contents = contents[1..contents.length];
        }

        return last == '.' || last == '_' ? 0 : length;
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
        this.key = "";
        while (contents.length > 0 && "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ._".indexOf(contents[0]) > -1) {
            this.key ~= contents[0];

            contents = contents[1..contents.length];
        }

        return contents;
    }
}
