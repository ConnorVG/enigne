module logic.game.runner;

import logic.game.state : IState;
import logic.game.renderer : IRenderer;
import logic.game.updater : IUpdater;

import std.parallelism : TaskPool, parallel;

import core.time : MonoTime, Duration, dur;
import core.thread : Thread;

class Runner
{
    /**
     * The current running state.
     */
    protected bool running = false;

    /**
     * The game updaters.
     */
    protected IUpdater[] updaters;

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
    public this(IState state, IUpdater[] updaters, IRenderer renderer)
    {
        this.updaters = updaters;
        this.renderer = renderer;

        this.renderer.setState(state);
        this.renderer.setRunner(this);

        foreach (ref updater; parallel(this.updaters)) {
            updater.setState(state);
            updater.setRunner(this);
        }
    }

    /**
     * Start the game runner.
     */
    public void start()
    {
        this.running = true;

        this.renderer.onStart();
        foreach (ref updater; parallel(this.updaters)) {
            updater.onStart();
        }

        this.run();
    }

    /**
     * Run the game.
     */
    public void run()
    {
        float renderRate = 1000000f / 144;
        int renderDelay = 0;
        MonoTime renderBefore = MonoTime.currTime;

        float[] rateBases = [];
        float[] rates = [];
        int[] delays = [];
        MonoTime[] befores = [];

        foreach (ref updater; this.updaters) {
            rates ~= updater.rate;
            rateBases ~= updater.rateBase;
            delays ~= 0;
            befores ~= MonoTime.currTime;
        }

        MonoTime now;
        Duration elapsed;
        long elapsedTotal;

        TaskPool taskPool = new TaskPool();
        taskPool.isDaemon = true;

        while (this.running) {
            int delay = -1000000;

            foreach (int id, ref updater; this.updaters) {
                now = MonoTime.currTime;
                elapsed = now - befores[id];
                elapsedTotal = elapsed.total!"usecs";
                befores[id] = now;

                delays[id] += elapsedTotal;
                if (delays[id] >= -1) {
                    float tick = rates[id] / rateBases[id];

                    if (delays[id] > 0) {
                        tick += (delays[id] / rates[id]) / rateBases[id];
                    }

                    updater.run(taskPool, tick);

                    delays[id] = cast(int) -rates[id];
                }

                delay = delays[id] > delay ? delays[id] : delay;
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
            delay = renderDelay > delay ? renderDelay : delay;

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
        foreach (ref updater; parallel(this.updaters)) {
            updater.onStop();
        }

        this.renderer.onStop();
    }
}
