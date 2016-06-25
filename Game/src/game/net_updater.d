module game.net_updater;

import game.state : State;
import game.net : Connector, LocalConnector;

import fiiight.logic : IUpdater, Runner, IState, Connection;

import std.parallelism : TaskPool, task;

debug import std.stdio : writeln, writefln;

private const UPDATER_RATE = 1000000f / 2000;
private const UPDATER_BASE_RATE = 1000000f / 2000;

class NetUpdater : IUpdater
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
     * The active connector.
     */
    protected Connector connector;

    /**
     * The active connection.
     */
    public @property Connection connection() {
        return this.connector.connection;
    }

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
            this.state.setNetUpdater(this);
        }
    }

    /**
     * Set the connector.
     *
     * Params:
     *      connector  =        the active connector
     */
    public void setConnector(Connector connector)
    {
        this.connector.stop();

        this.connector = connector;
        this.connector.start();
    }

    /**
     * On start handler.
     */
    public void onStart()
    {
        debug writeln("NetUpdater::onStart");

        this.connector = new LocalConnector();
        this.connector.start();
    }

    /**
     * Update the state.
     *
     * Params:
     *      pool  =     the task pool
     *      tick  =     the tick duration
     *      net   =     whether or not this is a net tick
     */
    public void run(TaskPool pool, const float tick, const bool net)
    {
        if (net) {
            this.connector.processNet(pool, tick);

            return;
        }

        this.connector.processLogic(pool, tick);
    }

    /**
     * Update the state.
     *
     * Params:
     *      pool  =     the task pool
     *      tick  =     the tick duration
     */
    public override void run(TaskPool pool, const float tick)
    {
        this.run(pool, tick, true);
    }

    /**
     * On stop handler.
     */
    public void onStop()
    {
        debug writeln("NetUpdater::onStop");

        this.connector.stop();
        this.connector = null;
    }
}
