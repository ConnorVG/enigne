module common.util.config.parser;

import common.util.config.pair : Pair, StringPair;
import common.util.config.token :
    Token, SectionToken, VariableToken, KeyToken, ValueToken, CommentToken;

import std.string : strip;

debug import std.stdio : writeln, writefln;

struct Parser
{
    /**
     * Get all pairs from a string.
     *
     * Params:
     *      contents  =     the string to parse
     *
     * Returns: the key value pairs
     */
    public static Pair[] from(ref string contents)
    {
        Token[TypeInfo_Class] tokens;

        tokens[SectionToken.classinfo] = new SectionToken();
        tokens[VariableToken.classinfo] = new VariableToken();
        tokens[KeyToken.classinfo] = new KeyToken();
        tokens[ValueToken.classinfo] = new ValueToken();
        tokens[CommentToken.classinfo] = new CommentToken();

        return Parser.from(contents, tokens, true);
    }

    /**
     * Get all pairs from a string.
     *
     * Params:
     *      contents  =     the string to parse
     *      tokens    =     the tokens
     *
     * Returns: the key value pairs
     */
    public static Pair[] from(ref string contents, Token[TypeInfo_Class] tokens, bool root = true)
    {
        Pair[] pairs = [];
        contents = contents.dup.strip();

        while (contents.length > 0) {
            Token token;

            if (tokens[SectionToken.classinfo].has(contents, tokens)) {
                if (! root) {
                    return pairs;
                }

                token = tokens[SectionToken.classinfo];
            } else if (tokens[VariableToken.classinfo].has(contents, tokens)) {
                token = tokens[VariableToken.classinfo];
            } else if (tokens[CommentToken.classinfo].has(contents, tokens)) {
                token = tokens[CommentToken.classinfo];
            }

            if (! token) {
                if (root) {
                    writefln("Fail[%d]:\r\n%s", contents.length, contents);
                }

                break;
            }

            contents = token.parse(contents, tokens).strip();

            if (auto sectionToken = cast(SectionToken) token) {
                pairs ~= sectionToken.pairs;
            } else if (auto variableToken = cast(VariableToken) token) {
                pairs ~= variableToken.pair;
            }
        }

        if (root) {
            foreach (ref pair; pairs) {
                writefln("Key: %s", pair.key);

                if (auto stringPair = cast(StringPair) pair) {
                    writefln("Value: %s", stringPair.value);
                }

                writeln();
            }
        }

        return pairs;
    }
}
