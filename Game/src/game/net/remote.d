module game.net.remote;

import game.net.connector : Connector;

import fiiight.logic : RemoteConnection;

class RemoteConnector : Connector
{
    /**
     * Start the connector.
     */
    public override void start()
    {
        this.connection = new RemoteConnection();
        this.connection.connect(&this.receive);
    }

    /**
     * Stop the connector.
     */
    public override void stop()
    {
        this.connection.disconnect();
        this.connection = null;
    }
}
