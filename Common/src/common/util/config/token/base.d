module common.util.config.token.base;

abstract class Token
{
    /**
     * Check if the next token is this token.
     *
     * Params:
     *      contents  =     the contents
     *      tokens    =     the token
     *
     * Returns: whether the next token is this token
     */
    public bool has(string contents, Token[TypeInfo_Class] tokens)
    {
        return this.count(contents, tokens) > 0;
    }

    /**
     * Count the length of this token in-context.
     *
     * Params:
     *      contents  =     the contents
     *      tokens    =     the token
     *
     * Returns: the length of the token, if there is one
     */
    public abstract uint count(string contents, Token[TypeInfo_Class] tokens);

    /**
     * Parse the token.
     *
     * Params:
     *      contents  =     the contents
     *      tokens    =     the token
     *
     * Returns: the remainder of the contents
     */
    public abstract string parse(ref string contents, Token[TypeInfo_Class] tokens);
}
