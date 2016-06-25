module common.util.config.pair.string;

import common.util.config.pair.base : Pair;

class StringPair : Pair
{
    /**
     * The string value.
     */
    public string value;

    /**
     * Whether or not the value is empty.
     */
    public override @property bool isEmpty() {
        return this.value.length == 0;
    }

    /**
     * Construct the string.
     */
    public this(string key, string value = "")
    {
        this.key = key;
        this.value = value;
    }
}
