module logic.game.updater;

import logic.game.runner;
import logic.game.state;

import std.parallelism : TaskPool;

interface IUpdater
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
     * Update the state.
     *
     * Params:
     *      pool  =     the task pool
     *      tick  =     the tick duration
     */
    public void run(TaskPool pool, const float tick);

    /**
     * On stop handler.
     */
    public void onStop();
}
