module common.util.config.pair.base;

abstract class Pair
{
    /**
     * The unique key.
     */
    public string key;

    /**
     * Whether or not the value is empty.
     */
    public abstract @property bool isEmpty();
}
