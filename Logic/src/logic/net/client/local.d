module logic.net.client.local;

import logic.net.client.connection : Connection;
import logic.net.server : Host;
import logic.net.packet : Packet, PacketHeader, PacketType, PacketSubType;

class LocalConnection : Connection
{
    /**
     * The server host.
     */
    protected Host host;

    /**
     * Construct a connection.
     *
     * Params:
     *      host  =     the server host
     */
    public this(Host host)
    {
        this.host = host;
    }

    /**
     * Connect to the server.
     *
     * Params:
     *      onPacket  =     the packet handler
     *
     * Returns: if the connection was successful
     */
    public override bool connect(void delegate(Connection, const Packet) onPacket)
    {
        this.handler = onPacket;

        if (! this.host.connect(this)) {
            this.handler = null;

            return false;
        }

        this.send(Packet(PacketHeader(PacketType.Connection, PacketSubType.Connection_Connected)));

        return true;
    }

    /**
     * Send a packet to the host.
     *
     * Params:
     *      packet  =       the packet
     */
    public override void send(const Packet packet)
    {
        this.host.receive(this, packet);
    }
}
