module common.util.config.config;

import common.util.config.pair : Pair;

import core.memory : GC;

struct Config
{
    /**
     * The key value pairs.
     */
    protected Pair[] pairs;

    /**
     * The length of key value pairs.
     */
    public @property ulong length() {
        return this.pairs.length;
    }

    /**
     * Creates a config.
     *
     * Params:
     *      pairs  =        the key value pairs
     *
     * Returns: a pointer to the newly created config
     */
    public static Config* create(Pair[] pairs = [])
    {
        auto config = cast(Config*) GC.malloc(Config.sizeof);

        config.pairs = pairs;

        return config;
    }
}
