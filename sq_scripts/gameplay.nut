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

class SlayLinked extends SqRootScript
{
    function OnSlain() {
        // Slay our friends (unless they slayed us first)
        local slainBy = message().from;
        local friends = [];
        foreach (link in Link.GetAll("ScriptParams", self)) {
            if (LinkTools.LinkGetData(link, "")=="SlayLinked") {
                friends.append(LinkDest(link));
            }
        }
        foreach (link in Link.GetAll("~ScriptParams", self)) {
            if (LinkTools.LinkGetData(link, "")=="SlayLinked") {
                friends.append(LinkDest(link));
            }
        }
        foreach (friend in friends) {
            if (friend!=slainBy) {
                Damage.Slay(friend, message().culprit);
            }
        }
    }
}

class GlassContainer extends SqRootScript
{
    function OnSim() {
        if (message().starting) {
            // Ensure all our contents are visible and inert.
            foreach (link in Link.GetAll("Contains", self)) {
                Property.SetSimple(LinkDest(link), "HasRefs", 1);
            }
            MakeInertContents(true);
        }
    }

    function OnSlain() {
        MakeInertContents(false);
    }

    function OnTurnOn() {
        MakeInertContents(false);
    }

    function OnTurnOff() {
        MakeInertContents(true);
    }

    function MakeInertContents(inert) {
        // Make contents frobbable or not.
        foreach (link in Link.GetAll("Contains", self)) {
            local o = LinkDest(link);
            if (inert) {
                if (! Object.HasMetaProperty(o, "FrobInert")) {
                    Object.AddMetaProperty(o, "FrobInert")
                }
            } else {
                if (Object.HasMetaProperty(o, "FrobInert")) {
                    Object.RemoveMetaProperty(o, "FrobInert")
                }
            }
        }
    }
}

class GarrettDoll extends SqRootScript
{
    function OnTurnOn() {
        // Make sure we can't activate before the lid gets opened,
        // cause otherwise frobbing through the wall is possible. :(
        if (! IsDataSet("IsEnabled")) {
            SetData("IsEnabled", 1);
        }
    }

    function OnWorldSelect() {
        if (IsDataSet("IsEnabled")) {
            // Only activate the first time we are focused, as a surprise!
            if (! IsDataSet("HasActivated")) {
                SetData("HasActivated", 1);
                SetOneShotTimer("GarrettDollView", 0.5);
            }
        }
    }

    function OnTimer() {
        if (message().name=="GarrettDollView") {
            Link.BroadcastOnAllLinks(self, "TurnOn", "ControlDevice");
            // Become pick-upable.
            SetProperty("FrobInfo", "World Action", 0x1); // Move
            // Make other things pick-upable.
            foreach (link in Link.GetAll("ScriptParams", self)) {
                if (LinkTools.LinkGetData(link, "")=="FrobEnable") {
                    Object.RemoveMetaProperty(LinkDest(link), "FrobInert");
                }
            }
        }
    }
}

class CameraView extends SqRootScript
{
    function OnTurnOn() {
        Camera.DynamicAttach(self);
    }

    function OnCameraAttach() {
        Link.BroadcastOnAllLinks(self, "TurnOn", "ControlDevice");
    }

    function OnCameraDetach() {
        Link.BroadcastOnAllLinks(self, "TurnOff", "ControlDevice");
    }
}

class ToggleNotRendered extends SqRootScript
{
    function OnTurnOn() {
        SetProperty("RenderType", 0); // Normal
    }

    function OnTurnOff() {
        SetProperty("RenderType", 1); // Not Rendered
    }
}
