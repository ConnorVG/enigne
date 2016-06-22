import fiiight.logic : LoadLogic = Load, Game = Runner, IUpdater;
import fiiight.game : State, NetUpdater, LogicUpdater, Renderer;

void main()
{
    LoadLogic();

    auto game = new Game(
        new State(),
        cast(IUpdater[]) [new NetUpdater(), new LogicUpdater()],
        new Renderer()
    );

    game.start();
}
