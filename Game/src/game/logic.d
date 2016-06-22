module fiiight.game.logic;

import fiiight.game.state : State;
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
     * The local net connection.
     */
    protected Connection connection;

    debug {
        /**
         * The remote net connection.
         */
        protected Connection remote;
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
            this.state.setLogicUpdater(this);
        }
    }

    /**
     * On start handler.
     */
    public void onStart()
    {
        debug writeln("LogicUpdater::onStart");

        auto netUpdater = this.state.getNetUpdater();

        this.connection = new LocalConnection(netUpdater.host);
        this.connection.connect(&this.onPacket);

        debug {
            this.remote = new RemoteConnection();
            remote.connect(&this.onPacket);
        }
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
        pool.put(task(&this.connection.process));

        debug pool.put(task(&this.remote.process));

        // ... update state
    }

    /**
     * On stop handler.
     */
    public void onStop()
    {
        debug writeln("LogicUpdater::onStop");
    }

    /**
     * Handle a received packet.
     *
     * Params:
     *      connection  =       the connection
     *      packet      =       the received packet
     */
    protected void onPacket(Connection connection, const Packet packet)
    {
        debug {
            if (connection != this.connection) {
                return;
            }
        }
    }
}
