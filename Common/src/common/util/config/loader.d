module common.util.config.loader;

import common.util.config.config : Config;
import common.util.config.parser : Parser;
import common.util.file : Reader;

struct Loader
{
    /**
     * Load from a file.
     *
     * Params:
     *      path  =     the file path
     *
     * Returns: the loaded config
     */
    public static Config* file(const string path)
    {
        auto contents = Reader.contents(path);

        // if it's empty, skip parsing it...
        if (path.length == 0) {
            return Config.create();
        }

        return Config.create(Parser.from(contents));
    }
}
