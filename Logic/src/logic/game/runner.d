module logic.game.runner;

import logic.game.state : IState;
import logic.game.renderer : IRenderer;
import logic.game.updater : IUpdater;

import std.parallelism : TaskPool;

import core.time : MonoTime, Duration, dur;
import core.thread : Thread;

class Runner
{
    /**
     * The current running state.
     */
    protected bool running = false;

    /**
     * The game updater.
     */
    protected IUpdater updater;

    /**
     * The game renderer.
     */
    protected IRenderer renderer;

    /**
     * Construct the runner.
     *
     * Params:
     *      state     =     the game state
     *      updater   =     the game updater
     *      renderer  =     the game renderer
     */
    public this(IState state, IUpdater updater, IRenderer renderer)
    {
        this.updater = updater;
        this.renderer = renderer;

        this.updater.setState(state);
        this.renderer.setState(state);

        this.updater.setRunner(this);
        this.renderer.setRunner(this);
    }

    /**
     * Start the game runner.
     */
    public void start()
    {
        this.running = true;

        this.updater.onStart();
        this.renderer.onStart();

        this.run();
    }

    /**
     * Run the game.
     */
    public void run()
    {
        float updateRateBase = 1000000f / 30f;
        //float updateRate = 1000000f / 30f;
        float updateRate = 1000000f / 1;
        //float renderRate = 1000000f / 144;
        float renderRate = 1000000f / 1;

        int updateDelay = 0;
        int renderDelay = 0;

        MonoTime updateBefore = MonoTime.currTime;
        MonoTime renderBefore = MonoTime.currTime;
        MonoTime now;

        Duration elapsed;
        long elapsedTotal;

        TaskPool taskPool;

        float total = 0f;

        while (this.running) {
            now = MonoTime.currTime;
            elapsed = now - updateBefore;
            elapsedTotal = elapsed.total!"usecs";
            updateBefore = now;

            updateDelay += elapsedTotal;
            if (updateDelay >= -1) {
                float updateTick = updateRate / updateRateBase;

                if (updateDelay > 0) {
                    updateTick += (updateDelay / updateRate) / updateRateBase;
                }

                total += updateTick;

                if (total > 60 * 5) {
                    this.stop();
                }

                taskPool = new TaskPool();

                this.updater.run(taskPool, updateTick);

                updateDelay = cast(int) -updateRate;
            }

            now = MonoTime.currTime;
            elapsed = now - renderBefore;
            elapsedTotal = elapsed.total!"usecs";
            renderBefore = now;

            renderDelay += elapsedTotal;
            if (renderDelay >= -1) {
                this.renderer.run();

                renderDelay = cast(int) -renderRate;
            }

            // Not sure if this should just be in the update block or not, honestly.
            if (taskPool) {
                taskPool.finish(true);

                taskPool = null;
            }

            int delay = updateDelay < renderDelay ? renderDelay : updateDelay;
            if (delay < -1) {
                Thread.sleep(dur!"usecs"(delay * -1));
            }
        }

        this.onStop();
    }

    /**
     * Stop the game runner.
     */
    public void stop()
    {
        this.running = false;
    }

    /**
     * Handle the game stop.
     */
    protected void onStop()
    {
        this.updater.onStop();
        this.renderer.onStop();
    }
}
