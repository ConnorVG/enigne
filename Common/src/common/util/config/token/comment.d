module common.util.config.token.comment;

import common.util.config.token.base : Token;

import std.string : indexOf;

class CommentToken : Token
{
    /**
     * The most recently parsed comment.
     */
    public string comment = "";

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
        if (contents[0] != '#') {
            return 0;
        }

        uint length = contents.indexOf('\n');

        return length >= 0 ? length : contents.length;
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
        auto length = contents.indexOf('\n');
        length = length >= 0 ? length : contents.length;

        this.comment = contents[0..length];

        return contents[length..contents.length];
    }
}
