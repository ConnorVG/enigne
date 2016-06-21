module logic.net.client.connection;

import logic.net.packet : Packet, PacketHeader;

import std.typecons : Nullable;

enum ConnectionError {
    Unknown,
    RejectedByHost,
}

abstract class Connection
{
    /**
     * The connection identifier.
     */
    public Nullable!ubyte id;

    /**
     * The packet handler.
     */
    protected void delegate(Connection, const Packet packet) handler;

    /**
     * Connect to the server.
     *
     * Params:
     *      onSuccess  =        the success handler
     *      onError    =        the error handler
     *      onPacket   =        the packet handler
     */
    public abstract void connect(
        void delegate(Connection) onSuccess,
        void delegate(Connection, ConnectionError) onError,
        void delegate(Connection, const Packet) onPacket
    );

    /**
     * Send a packet to the host.
     *
     * Params:
     *      packet  =       the packet
     */
    public abstract void send(const Packet packet);

    /**
     * Send a packet to the host.
     *
     * Params:
     *      type     =      the packet type
     *      subType  =      the packet sub type
     *      content  =      the packet content
     */
    public void send(const ushort type, const ubyte subType, const ubyte[] content)
    {
        PacketHeader header = {
            type: type,
            subType: subType,
            length: content.sizeof
        };

        Packet packet = {
            header: header,
            content: content
        };

        return this.send(packet);
    }

    /**
     * Receive a packet from the host.
     *
     * Params:
     *      packet  =       the packet
     */
    public void receive(const Packet packet)
    {
        if (! this.handler) {
            return;
        }

        this.handler(this, packet);
    }
}
