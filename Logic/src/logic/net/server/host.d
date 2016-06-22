module logic.net.server.host;

import logic.net.client : Connection, ConnectionError, ClientConnection;
import logic.net.packet : Packet, PacketHeader, PacketType, PacketSubType;

import std.socket :
    INADDR_LOOPBACK, InternetAddress, Address, AddressFamily, Socket, SocketType,
    SocketOptionLevel, SocketOption, SocketShutdown, ProtocolType;

import std.bitmanip : peek, write;
import std.algorithm : canFind;
import std.parallelism : parallel;

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
    public Socket socket;

    /**
     * The active connections.
     */
    protected Connection[ubyte] connections;

    /**
     * The connection map.
     */
    protected ubyte[const string] map;

    /**
     * The active buffer.
     */
    protected ubyte[][const string] buffer;

    /**
     * The current connection index.
     */
    protected ubyte index = 0;

    /**
     * The packet handler.
     */
    public void delegate(Connection, const Packet) onPacket;

    /**
     * The pre-connection handler.
     */
    public void delegate(Connection) onPreConnect;

    /**
     * The post-connection handler.
     */
    public void delegate(Connection) onPostConnect;

    /**
     * The disconnection handler.
     */
    public void delegate(Connection, ConnectionError) onDisconnect;

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
        do { } while (this.read());

        foreach (ref identifier; parallel(this.buffer.keys)) {
            this.parse(identifier);
        }
    }

    /**
     * Reads the host socket.
     *
     * Returns: whether or not more processing might be possible
     */
    protected bool read()
    {
        Address address;
        auto buff = new ubyte[2048];
        auto length = this.socket.receiveFrom(buff, address);

        if (length <= 0) {
            return false;
        }

        auto identifier = address.toString();

        buff.length = length;
        if (identifier in this.buffer) {
            buff = this.buffer[identifier] ~ buff;
        }

        this.buffer[identifier] = buff;

        if (identifier !in this.map) {
            auto connection = new ClientConnection(this, address);

            if (this.connections.length == ubyte.max) {
                this.disconnect(connection);

                return true;
            }

            this.connect(connection);

            if (! connection.id.isNull) {
                this.map[identifier] = connection.id;
            }
        }

        return true;
    }

    /**
     * Parse a buffer.
     *
     * Params:
     *      identifier  =       the identifier to parse
     */
    protected void parse(const string identifier)
    {
        auto buffer = this.buffer[identifier];

        if (buffer.length < PacketHeader.sizeof) {
            return;
        }

        PacketHeader header = {
            type: buffer.peek!ushort(0),
            subType: buffer.peek!ubyte(2),
            length: buffer.peek!ushort(3),
        };

        ubyte[] content = [];
        if (header.length != 0) {
            if (buffer.length < PacketHeader.sizeof + header.length) {
                return;
            }

            content = buffer[PacketHeader.sizeof..(PacketHeader.sizeof + header.length)];
        }

        if (buffer.length == PacketHeader.sizeof + header.length) {
            this.buffer[identifier] = [];
        } else {
            this.buffer[identifier] = buffer[(PacketHeader.sizeof + header.length)..buffer.length];
        }

        this.receive(this.connections[this.map[identifier]], Packet(header, content));

        if (this.buffer[identifier].length < PacketHeader.sizeof) {
            return;
        }

        this.parse(identifier);
    }

    /**
     * Stop the listen server.
     */
    public void stop()
    {
        this.disconnect();

        this.socket.shutdown(SocketShutdown.BOTH);
        this.socket.close();
        this.socket = null;
    }

    /**
     * Disconnect all connections.
     */
    public void disconnect()
    {
        this.broadcast(Packet(PacketHeader(PacketType.Connection, PacketSubType.Connection_Disconnected)));

        if (this.onDisconnect) {
            foreach (ref connection; parallel(this.connections.values)) {
                this.onDisconnect(connection, ConnectionError.None);
            }
        }

        this.connections.clear();
        this.map.clear();
        this.buffer.clear();
    }

    /**
     * Disconnect a connection.
     *
     * Params:
     *      connection  =       the connection to disconnect
     */
    public void disconnect(Connection connection)
    {
        if (! connection.id.isNull) {
            this.connections.remove(connection.id);
        }

        if (auto client = cast(ClientConnection) connection) {
            auto address = client.address.toString();

            this.map.remove(address);
            this.buffer.remove(address);
        }

        connection.receive(Packet(PacketHeader(PacketType.Connection, PacketSubType.Connection_Disconnected)));

        if (! this.onDisconnect) {
            return;
        }

        this.onDisconnect(connection, ConnectionError.None);
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

        if (this.onPreConnect) {
            this.onPreConnect(connection);
        }

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
        if (packet.header.type == PacketType.Connection) {
            switch (packet.header.subType) with (PacketSubType) {
                case Connection_Connected:
                    this.send(connection, Packet(PacketHeader(PacketType.Connection, PacketSubType.Connection_Connected)));

                    if (this.onPostConnect) {
                        this.onPostConnect(connection);
                    }

                    break;
                case Connection_Disconnected:
                    this.disconnect(connection);

                    return;

                default: break;
            }
        }

        if (! this.onPacket) {
            return;
        }

        this.onPacket(connection, packet);
    }
}

