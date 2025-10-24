class Beacon extends SqRootScript {
    function OnTurnOn() {
        Activate(true);
    }

    function OnTurnOff() {
        Activate(false);
    }

    function OnFireStimStimulus() {
        Activate(true);
    }

    function OnWaterStimStimulus() {
        Activate(false);
    }

    function OnKOGasStimulus() {
        Activate(false);
    }

    function Activate(active) {
        local msg = (active? "TurnOn" : "TurnOff");
        Link.BroadcastOnAllLinks(self, msg, "ControlDevice");
        Link.BroadcastOnAllLinks(self, msg, "~ParticleAttachement");
        Link.BroadcastOnAllLinks(self, msg, "~DetailAttachement");
    }
}

class BeaconFlame extends SqRootScript
{
    function OnTurnOn() {
        SetProperty("HasRefs", 1);
    }

    function OnTurnOff() {
        SetProperty("HasRefs", 0);
    }
}
