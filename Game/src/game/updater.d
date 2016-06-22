module fiiight.game.updater;

import fiiight.game.state : State;
import fiiight.logic : IUpdater, Runner, IState;

import std.parallelism : TaskPool, task;

debug import fiiight.logic : Host, Connection, ConnectionError, Packet, LocalConnection, RemoteConnection;

debug import std.stdio : writeln, writefln;

class Updater : IUpdater
{
    /**
     * The current runner.
     */
    protected Runner runner;

    /**
     * The current state.
     */
    protected State state;

    debug {
        /**
         * this is just for debug fam
         */
        protected Host host;
        protected Connection local;
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
        }
    }

    /**
     * On start handler.
     */
    public void onStart()
    {
        debug writeln("Updater::onStart");

        debug {
            this.host = new Host();

            this.host.onPacket = &this.onHostPacket;
            this.host.onPreConnect = &this.onPreConnect;
            this.host.onPostConnect = &this.onPostConnect;
            this.host.onDisconnect = &this.onDisconnect;

            this.host.start();

            this.local = new LocalConnection(this.host);
            this.local.connect(
                &this.onSuccess,
                &this.onError,
                &this.onPacket
            );

            this.remote = new RemoteConnection();
            this.remote.connect(
                &this.onSuccess,
                &this.onError,
                &this.onPacket
            );
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
        debug writefln("Updater::run( %f )", tick);

        debug {
            pool.put(task(&this.host.process));

            // even tho this does nothing ;D
            pool.put(task(&this.local.process));

            // this is obv required
            pool.put(task(&this.remote.process));
        }

        if (! this.state) {
            return;
        }

        // ... update state
    }

    /**
     * On stop handler.
     */
    public void onStop()
    {
        debug writeln("Updater::onStop");

        debug {
            this.host.stop();
            this.local.process();
            this.remote.process();
        }
    }

    debug {
        protected void onSuccess(Connection connection)
        {
            writefln("Connection[%s]::onSuccess", connection);
        }

        protected void onError(Connection connection)
        {
            writefln("Connection[%s]::onError", connection);
        }

        protected void onPreConnect(Connection connection)
        {
            writefln("Connection[%s]::onPreConnect", connection);
        }

        protected void onPostConnect(Connection connection)
        {
            writefln("Connection[%s]::onPostConnect", connection);
        }

        protected void onDisconnect(Connection connection, ConnectionError error)
        {
            writefln("Connection[%s]::onDisconnect", connection);
        }

        protected void onHostPacket(Connection connection, const Packet packet)
        {
            writefln("Connection[%s] -> Host:- Packet( %s )", connection, packet);
        }

        protected void onPacket(Connection connection, const Packet packet)
        {
            writefln("Host -> Connection[%s]:- Packet( %s )", connection, packet);
        }
    }
}
