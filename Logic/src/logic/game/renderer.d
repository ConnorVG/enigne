module logic.game.renderer;

import logic.game.runner;
import logic.game.state;

interface IRenderer
{
    /**
     * Set the runner.
     *
     * Params:
     *      runner  =       the game runner
     */
    public void setRunner(Runner runner);

    /**
     * Set the state.
     *
     * Params:
     *      state  =        the game state
     */
    public void setState(IState state);

    /**
     * On start handler.
     */
    public void onStart();

    /**
     * Render the state.
     */
    public void run();

    /**
     * On stop handler.
     */
    public void onStop();
}
