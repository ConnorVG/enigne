module logic.net.packet.structure;

enum PacketType : ushort {
    Connection = 0,
}

enum PacketSubType : ubyte {
    Default = 0,

    Connection_Connected = 0,
    Connection_Disconnected = 1,
    Connection_Ping = 2,
    Connection_Pong = 3,
}

align(1) struct PacketHeader
{
    /**
     * The packet type.
     */
    public const ushort type;

    align(1):

    /**
     * The packet sub type.
     */
    public const ubyte subType;

    /**
     * The packet content length.
     */
    public const ushort length;
}

align(1) struct Packet
{
    /**
     * The packet header.
     */
    public const PacketHeader header;

    /**
     * The packet content.
     */
    align(1) public const ubyte[] content;
}
