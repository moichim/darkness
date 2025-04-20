abstract class ObjectImpactableTracker extends ObjectImpactable {

    Tracker tracker;

    protected RendererParticles getRenderer() {
        return this.tracker.particleRenderer;
    }

}