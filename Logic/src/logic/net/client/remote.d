module logic.net.client.remote;

import logic.net.client.connection : Connection;
import logic.net.packet : Packet, PacketHeader, PacketType, PacketSubType;

import std.socket :
    INADDR_LOOPBACK, InternetAddress, AddressFamily, Socket, SocketType,
    SocketOptionLevel, SocketOption, SocketShutdown, ProtocolType;

import std.array : appender;
import std.bitmanip : peek, append;

class RemoteConnection : Connection
{
    /**
     * The external address.
     */
    protected const string address;

    /**
     * The external port.
     */
    protected const ushort port;

    /**
     * The connection socket.
     */
    protected Socket socket;

    /**
     * The active buffer.
     */
    protected ubyte[] buffer = [];

    /**
     * Construct the connection.
     *
     * Params:
     *      address  =      the external address
     *      port     =      the external port
     */
    public this(const string address = "127.0.0.1", const ushort port = 43594)
    {
        this.address = address;
        this.port = port;
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
        this.socket = new Socket(AddressFamily.INET, SocketType.DGRAM, ProtocolType.UDP);
        this.socket.blocking = true;

        this.socket.connect(
            this.address == "127.0.0.1" || this.address == "localhost"
                ? new InternetAddress(INADDR_LOOPBACK, this.port)
                : new InternetAddress(this.address, this.port)
        );

        if (! this.socket.isAlive) {
            this.socket.close();
            this.socket = null;

            return false;
        }

        this.handler = onPacket;

        this.socket.blocking = false;
        this.send(Packet(PacketHeader(PacketType.Connection, PacketSubType.Connection_Connected)));

        return true;
    }

    /**
     * Disconnect from the server.
     */
    public override void disconnect()
    {
        this.send(Packet(PacketHeader(PacketType.Connection, PacketSubType.Connection_Disconnected)));

        if (this.socket && this.socket.isAlive) {
            this.socket.shutdown(SocketShutdown.BOTH);
            this.socket.close();
            this.socket = null;
        }

        this.handler = null;
    }

    /**
     * Process the connection.
     */
    public override void process()
    {
        do { } while (this.read());

        this.parse();
    }

    /**
     * Reads the socket.
     *
     * Returns: whether or not more processing might be possible
     */
    protected bool read()
    {
        auto buff = new ubyte[2048];
        auto length = this.socket.receive(buff);

        if (length <= 0) {
            return false;
        }

        buff.length = length;
        this.buffer = buffer ~ buff;

        return true;
    }

    /**
     * Parse the buffer.
     */
    protected void parse()
    {
        if (this.buffer.length < PacketHeader.sizeof) {
            return;
        }

        PacketHeader header = {
            type: this.buffer.peek!ushort(0),
            subType: this.buffer.peek!ubyte(2),
            length: this.buffer.peek!ushort(3),
        };

        ubyte[] content = [];
        if (header.length != 0) {
            if (this.buffer.length < PacketHeader.sizeof + header.length) {
                return;
            }

            content = this.buffer[PacketHeader.sizeof..(PacketHeader.sizeof + header.length)];
        }

        if (this.buffer.length == PacketHeader.sizeof + header.length) {
            this.buffer = [];
        } else {
            this.buffer = this.buffer[(PacketHeader.sizeof + header.length)..this.buffer.length];
        }

        this.receive(Packet(header, content));

        if (this.buffer.length < PacketHeader.sizeof) {
            return;
        }

        this.parse();
    }

    /**
     * Send a packet to the host.
     *
     * Params:
     *      packet  =       the packet
     */
    public override void send(const Packet packet)
    {
        auto buffer = appender!(const ubyte[])();

        buffer.append!ushort(packet.header.type);
        buffer.append!ubyte(packet.header.subType);
        buffer.append!ushort(packet.header.length);

        auto data = buffer.data;

        if (packet.header.length > 0) {
            data = data ~ packet.content;
        }

        this.socket.send(data);
    }
}
