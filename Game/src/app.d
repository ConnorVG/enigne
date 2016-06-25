import game : State, NetUpdater, LogicUpdater, Renderer;

import fiiight.common : LoadCommon = Load, Loader;
//import fiiight.rendering : LoadRenderer = Load;
import fiiight.logic : LoadLogic = Load, Game = Runner, IUpdater;

debug import std.stdio : writefln;

void main()
{
    LoadCommon();
    //LoadRendering();
    LoadLogic();

    auto conf = Loader.file("conf/game.conf");

    debug writefln("Config[%d] loaded", conf.length);

    auto game = new Game(
        new State(),
        cast(IUpdater[]) [new NetUpdater(), new LogicUpdater()],
        new Renderer()
    );

    //game.start();
}
