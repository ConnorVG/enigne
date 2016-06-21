import fiiight.logic : LoadLogic = Load, Game = Runner;
import fiiight.game : State, Updater, Renderer;

void main()
{
    LoadLogic();

    auto game = new Game(
        new State(),
        new Updater(),
        new Renderer()
    );

    game.start();
}
