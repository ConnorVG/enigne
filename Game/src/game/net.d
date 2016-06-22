module fiiight.game.net;

import fiiight.game.state : State;
import fiiight.logic : IUpdater, Runner, IState, Host, Connection, ConnectionError, Packet;

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
     * The host.
     */
    public Host host;

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
     * On start handler.
     */
    public void onStart()
    {
        debug writeln("NetUpdater::onStart");

        this.host = new Host();

        this.host.onPreConnect = &this.onPreConnect;
        this.host.onPostConnect = &this.onPostConnect;
        this.host.onDisconnect = &this.onDisconnect;
        this.host.onPacket = &this.onPacket;

        this.host.start();
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
        pool.put(task(&this.host.process));
    }

    /**
     * On stop handler.
     */
    public void onStop()
    {
        debug writeln("NetUpdater::onStop");

        this.host.stop();
        this.host = null;
    }

    /**
     * Handle a pre-connect connection.
     *
     * Params:
     *      connection  =       the connection
     */
    protected void onPreConnect(Connection connection)
    {
        debug writefln("NetUpdater::onPreConnect( %s!%d[%dms] )", connection, connection.id, connection.ping);
    }

    /**
     * Handle a post-connect connection.
     *
     * Params:
     *      connection  =       the connection
     */
    protected void onPostConnect(Connection connection)
    {
        debug writefln("NetUpdater::onPostConnect( %s!%d[%dms] )", connection, connection.id, connection.ping);
    }

    /**
     * Handle a disconnect connection.
     *
     * Params:
     *      connection  =       the connection
     */
    protected void onDisconnect(Connection connection, ConnectionError error)
    {
        debug writefln("NetUpdater::onDisconnect( %s!%d[%dms], %s )", connection, connection.id, connection.ping, error);
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
        debug writefln("NetUpdater::onPacket( %s!%d[%dms], %d:%d )", connection, connection.id, connection.ping, packet.header.type, packet.header.subType);
    }
}
