module logic.net.client.client;

import logic.net.server : Host;
import logic.net.client.connection : Connection, ConnectionError;
import logic.net.packet : Packet;

import std.socket : Address;

import std.array : appender;
import std.bitmanip : append;

class ClientConnection : Connection
{
    /**
     * The host.
     */
    protected Host host;

    /**
     * The external address.
     */
    public Address address;

    /**
     * Construct the connection.
     *
     * Params:
     *      host     =      the server host
     *      address  =      the external address
     */
    public this(Host host, Address address)
    {
        this.host = host;
        this.address = address;
    }

    /**
     * Connect to the server.
     *
     * Params:
     *      onSuccess  =        the success handler
     *      onError    =        the error handler
     *      onPacket   =        the packet handler
     */
    public override void connect(
        void delegate(Connection) onSuccess,
        void delegate(Connection, ConnectionError) onError,
        void delegate(Connection, const Packet packet) onPacket
    ) { /** */ }

    /**
     * Send a packet to the host.
     *
     * Params:
     *      packet  =       the packet
     */
    public override void send(const Packet packet)
    { /** */ }

    /**
     * Receive a packet from the host.
     *
     * Params:
     *      packet  =       the packet
     */
    public override void receive(const Packet packet)
    {
        auto buffer = appender!(const ubyte[])();

        buffer.append!ushort(packet.header.type);
        buffer.append!ubyte(packet.header.subType);
        buffer.append!ushort(packet.header.length);

        auto data = buffer.data;

        if (packet.header.length > 0) {
            data = data ~ packet.content;
        }

        this.host.socket.sendTo(data, this.address);
    }
}
