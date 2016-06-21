module fiiight.game.renderer;

import fiiight.game.state : State;
import fiiight.logic : IRenderer, Runner, IState;

debug import std.stdio : writeln;

class Renderer : IRenderer
{
    /**
     * The current runner.
     */
    protected Runner runner;

    /**
     * The current state.
     */
    protected State state;

    /**
     * Set the runner.
     *
     * Params:
     *      runner  =       the game runner
     */
    public void setRunner(Runner runner)
    {
        this.runner = runner;
    }

    /**
     * Set the state.
     *
     * Params:
     *      state  =        the game state
     */
    public void setState(IState state)
    {
        if (auto _state = cast(State) state) {
            this.state = _state;
        }
    }

    /**
     * On start handler.
     */
    public void onStart()
    {
        debug writeln("Renderer::onStart");
    }

    /**
     * Render the state.
     */
    public void run()
    {
        if (! this.state) {
            return;
        }

        // debug writeln("Renderer::run");
    }

    /**
     * On stop handler.
     */
    public void onStop()
    {
        debug writeln("Renderer::onStop");
    }
}
