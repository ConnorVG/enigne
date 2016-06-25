module common.util.file.reader;

import std.file : exists, isFile, read;
import std.typecons : Nullable;

struct Reader
{
    /**
     * Get the contents of a file.
     *
     * Warning: silently fails if the file doesn't exist.
     *
     * Params:
     *      path  =     the file path
     */
    public static string contents(const string path)
    {
        if (! path.exists || ! path.isFile) {
            return "";
        }

        return cast(string) read(path);
    }
}
