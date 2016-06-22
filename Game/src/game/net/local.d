module game.net.local;

import game.net.connector : Connector;

import fiiight.logic : Host, Connection, LocalConnection, Packet;

import std.parallelism : TaskPool, task;

debug import std.stdio : writefln;

class LocalConnector : Connector
{
    /**
     * The active host.
     */
    protected Host host;

    /**
     * Start the connector.
     */
    public override void start()
    {
        this.host = new Host();
        this.host.onPacket = &this.receiveHost;
        this.host.start();

        this.connection = new LocalConnection(this.host);
        this.connection.connect(&this.receive);
    }

    /**
     * Stop the connector.
     */
    public override void stop()
    {
        this.host.stop();

        this.connection = null;
        this.host = null;
    }

    /**
     * Process the net buffers.
     *
     * Params:
     *      pool  =     the task pool
     *      tick  =     the tick duration
     */
    public override void processNet(TaskPool pool, const float tick)
    {
        pool.put(task(&this.host.process));

        this.Connector.processNet(pool, tick);
    }

    /**
     * Process the net logic.
     *
     * Params:
     *      pool  =     the task pool
     *      tick  =     the tick duration
     */
    public override void processLogic(TaskPool pool, const float tick)
    { /** todo */ }

    /**
     * Handle a received host packet.
     *
     * Params:
     *      connection  =       the connection
     *      packet      =       the received packet
     */
    protected void receiveHost(Connection connection, const Packet packet)
    {
        // ...
    }
}
