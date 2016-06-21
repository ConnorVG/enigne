module fiiight.game.updater;

import fiiight.game.state : State;
import fiiight.logic : Host, IUpdater, Runner, IState;

import std.parallelism : TaskPool, task;

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

    /**
     * this is just for debug fam
     */
    protected Host host;

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

        this.host = new Host();
        this.host.start();

        //import logic.net : LocalConnection;
        //auto local = new LocalConnection(this.host);

        //local.connect(
        //    &this.onSuccess,
        //    &this.onError,
        //    &this.onPacket
        //);
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

        import logic.net : RemoteConnection;
        auto remote = new RemoteConnection();

        remote.connect(
            &this.onSuccess,
            &this.onError,
            &this.onPacket
        );

        if (! this.state) {
            return;
        }

        debug writefln("Updater::run( %f )", tick);
    }

    /**
     * On stop handler.
     */
    public void onStop()
    {
        debug writeln("Updater::onStop");

        this.host.stop();
    }

    import logic.net : Connection;
    protected void onSuccess(Connection connection)
    {
        // connection.send(packet);
    }

    import logic.net : ConnectionError;
    protected void onError(Connection connection, ConnectionError error)
    {
        // ...
    }

    import logic.net : Packet;
    protected void onPacket(Connection connection, const Packet packet)
    {
        debug writeln("connection recieved packet...");
    }
}