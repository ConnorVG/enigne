module fiiight.game.state;

import fiiight.logic : IState;
import fiiight.game.net : NetUpdater;
import fiiight.game.logic : LogicUpdater;

class State : IState
{
    /**
     * The net updater.
     */
    protected NetUpdater netUpdater;

    /**
     * The logic updater.
     */
    protected LogicUpdater logicUpdater;

    /**
     * Set the net updater.
     *
     * Params:
     *      updater  =      the net updater
     */
    public void setNetUpdater(NetUpdater updater)
    {
        this.netUpdater = updater;
    }

    /**
     * Get the net updater.
     *
     * Returns: the net updater
     */
    public NetUpdater getNetUpdater()
    {
        return this.netUpdater;
    }

    /**
     * Set the logic updater.
     *
     * Params:
     *      updater  =      the logic updater
     */
    public void setLogicUpdater(LogicUpdater updater)
    {
        this.logicUpdater = updater;
    }

    /**
     * Get the logic updater.
     *
     * Returns: the logic updater
     */
    public LogicUpdater getLogicUpdater()
    {
        return this.logicUpdater;
    }
}
