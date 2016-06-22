module game.net.connector;

import fiiight.logic : Connection, Packet;

import std.parallelism : TaskPool, task;

abstract class Connector
{
    /**
     * The active connection.
     */
    public Connection connection;

    /**
     * The packet handler.
     */
    public void delegate(Connection, const Packet) onPacket;

    /**
     * Start the connector.
     */
    public abstract void start();

    /**
     * Stop the connector.
     */
    public abstract void stop();

    /**
     * Process the net buffers.
     *
     * Params:
     *      pool  =     the task pool
     *      tick  =     the tick duration
     */
    public void processNet(TaskPool pool, const float tick)
    {
        pool.put(task(&this.connection.process));
    }

    /**
     * Process the net logic.
     *
     * Params:
     *      pool  =     the task pool
     *      tick  =     the tick duration
     */
    public void processLogic(TaskPool pool, const float tick)
    { /** */ }

    /**
     * Handle a received packet.
     *
     * Params:
     *      connection  =       the connection
     *      packet      =       the received packet
     */
    protected void receive(Connection connection, const Packet packet)
    {
        if (! this.onPacket) {
            return;
        }

        this.onPacket(connection, packet);
    }
}
