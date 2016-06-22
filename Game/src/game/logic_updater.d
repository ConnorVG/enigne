module game.logic_updater;

import game.state : State;

import fiiight.logic : IUpdater, Runner, IState, Connection, LocalConnection, Packet;

import std.parallelism : TaskPool, task;

debug import fiiight.logic : RemoteConnection;

debug import std.stdio : writeln;

private const UPDATER_RATE = 1000000f / 30;
private const UPDATER_BASE_RATE = 1000000f / 30;

class LogicUpdater : IUpdater
{
    /**
     * The rate.
     */
    public @property float rate()
    {
        return UPDATER_RATE;
    }

    /**
     * The rate base.
     */
    public @property float rateBase()
    {
        return UPDATER_BASE_RATE;
    }

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
            this.state.setLogicUpdater(this);
        }
    }

    /**
     * On start handler.
     */
    public void onStart()
    {
        debug writeln("LogicUpdater::onStart");
    }

    /**
     * Update the state.
     *
     * Params:
     *      pool  =     the task pool
     *      tick  =     the tick duration
     */
    public void run(TaskPool pool, const float tick)
    {
        auto netUpdater = this.state.getNetUpdater();

        if (netUpdater) {
            netUpdater.run(pool, tick, false);
        }
    }

    /**
     * On stop handler.
     */
    public void onStop()
    {
        debug writeln("LogicUpdater::onStop");
    }
}
