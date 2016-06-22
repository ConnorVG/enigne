module logic.net.client.connection;

import logic.net.packet : Packet, PacketHeader, PacketType, PacketSubType;

import std.typecons : Nullable;

enum ConnectionError {
    None,
    Unknown,
}

abstract class Connection
{
    /**
     * The connection identifier.
     */
    public Nullable!ubyte id;

    /**
     * The connection ping;
     */
    public ushort ping = 0;

    /**
     * The packet handler.
     */
    protected void delegate(Connection, const Packet) handler;

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
        void delegate(Connection) onError,
        void delegate(Connection, const Packet) onPacket
    );

    /**
     * Process the connection.
     */
    public void process()
    {
        // ...
    }

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
        return this.send(Packet(PacketHeader(type, subType, cast(ushort) content.length), content));
    }

    /**
     * Receive a packet from the host.
     *
     * Params:
     *      packet  =       the packet
     */
    public void receive(const Packet packet)
    {
        if (packet.header.type == PacketType.Connection) {
            switch (packet.header.subType) with (PacketSubType) {
                case Connection_Ping:
                    this.send(Packet(PacketHeader(PacketType.Connection, PacketSubType.Connection_Pong, packet.header.length), packet.content));

                    break;
                default: break;
            }
        }

        if (! this.handler) {
            return;
        }

        this.handler(this, packet);
    }
}
