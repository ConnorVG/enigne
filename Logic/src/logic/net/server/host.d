module logic.net.server.host;

import logic.net.client : Connection;
import logic.net.packet : Packet, PacketHeader;

import std.socket :
    INADDR_LOOPBACK, InternetAddress, Address, AddressFamily, Socket, SocketType,
    SocketOptionLevel, SocketOption, SocketShutdown, ProtocolType;

import std.bitmanip : read, write;
import std.algorithm : canFind;

debug import std.stdio : writeln, writefln;

class Host
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
     * The server socket.
     */
    protected Socket socket;

    /**
     * The active connections.
     */
    protected Connection[ubyte] connections;

    /**
     * The connection map.
     */
    protected ubyte[const string] map;

    /**
     * The current index.
     */
    protected ubyte index = 0;

    /**
     * The connection count.
     */
    @property count() {
        return this.connections.length;
    }

    /**
     * Construct the host.
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
     * Start the listen server.
     */
    public void start()
    {
        debug writeln("Host::start");

        this.connections.clear();
        this.map.clear();

        this.socket = new Socket(AddressFamily.INET, SocketType.DGRAM, ProtocolType.UDP);
        this.socket.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);
        this.socket.blocking = false;

        this.socket.bind(
            this.address == "127.0.0.1" || this.address == "localhost"
                ? new InternetAddress(INADDR_LOOPBACK, this.port)
                : new InternetAddress(this.address, this.port)
        );
    }

    /**
     * Processes the host tasks.
     */
    public void process()
    {
        Address address;
        auto buffer = new ubyte[PacketHeader.sizeof];
        auto length = this.socket.receiveFrom(buffer, address);

        if (length <= 0) {
            return;
        }

        auto identifier = address.toAddrString();
        if (identifier !in this.map) {
            debug writefln("new address");

            this.map[identifier] = 1;
        }

        // Todo: actual and safe buffering lol

        PacketHeader header = {
            type: buffer.read!ushort(),
            subType: buffer.read!ubyte(),
            length: buffer.read!ushort(),
        };

        ubyte[] content = [];
        if (header.length > 0) {
            // content = ...
        }

        debug writefln("Host::process:- PacketHeader( %d, %d, %d )", header.type, header.subType, header.length);
    }

    /**
     * Stop the listen server.
     */
    public void stop()
    {
        debug writeln("Host::stop");

        this.socket.shutdown(SocketShutdown.BOTH);
        this.socket.close();
        this.socket = null;
    }

    /**
     * Connect a connection.
     *
     * Params:
     *      connection  =       the connection to connect
     *
     * Returns: whether it connects or not
     */
    public bool connect(Connection connection)
    {
        if (
            ! connection.id.isNull ||
            this.connections.length == ubyte.max ||
            canFind(this.connections.values, connection)
        ) {
            return false;
        }

        while (this.index in this.connections) this.index++;

        this.connections[this.index] = connection;
        connection.id = this.index;

        debug writefln("Host::connect( %d )", this.index);

        return true;
    }

    /**
     * Broadcast a packet.
     *
     * Params:
     *      packet  =       the packet
     */
    public void broadcast(const Packet packet)
    {
        foreach (ref connection; this.connections) {
            connection.receive(packet);
        }
    }

    /**
     * Send a packet.
     *
     * Params:
     *      connection  =       the connection
     *      packet      =       the packet
     */
    public void send(Connection connection, const Packet packet)
    {
        if (connection.id.isNull) {
            return;
        }

        connection.receive(packet);
    }

    /**
     * Receive a packet.
     *
     * Params:
     *      connection  =       the connection
     *      packet      =       the packet
     */
    public void receive(Connection connection, const Packet packet)
    {
        debug writefln("Host::receive( %d, %d, %d )", connection.id, packet.header.type, packet.header.subType);
    }
}
