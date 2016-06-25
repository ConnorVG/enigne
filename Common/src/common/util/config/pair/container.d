module common.util.config.pair.container;

import common.util.config.pair.base : Pair;

class ContainerPair : Pair
{
    /**
     * The contained pairs.
     */
    public Pair[] value;

    /**
     * Whether or not the value is empty.
     */
    public override @property bool isEmpty() {
        return this.value.length == 0;
    }

    /**
     * Construct the container.
     */
    public this(string key, Pair[] value = [])
    {
        this.key = key;
        this.value = value;
    }
}
