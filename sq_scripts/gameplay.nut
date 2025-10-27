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
