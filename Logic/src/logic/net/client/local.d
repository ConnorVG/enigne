module logic.net.client.local;

import logic.net.client.connection : Connection, ConnectionError;
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
     *      onSuccess  =        the success handler
     *      onError    =        the error handler
     *      onPacket   =        the packet handler
     */
    public override void connect(
        void delegate(Connection) onSuccess,
        void delegate(Connection, ConnectionError) onError,
        void delegate(Connection, const Packet packet) onPacket
    ) {
        this.handler = onPacket;

        if (! this.host.connect(this)) {
            this.handler = null;
            onError(this, ConnectionError.RejectedByHost);

            return;
        }

        this.send(Packet(PacketHeader(PacketType.Connection, PacketSubType.Connection_Connected)));

        onSuccess(this);
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
