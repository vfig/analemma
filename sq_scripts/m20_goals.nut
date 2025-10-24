enum eGoals {
    // Argaux and the job
    kDeliverMcGuffin        = 0,
    kDontBeStupid           = 1,
    kLightTheBeacons        = 2,
    kLootNormal             = 3,
    kLootHard               = 4,
    kLootExpert             = 5,
    kDontKillBystanders     = 6,
    kDontKillHumans         = 7,
    kLeaveTheMansion        = 8,
}

local Goal = {
    IsActive = function(goal) {
        return (Quest.Get("goal_state_" + goal) == 0);
    }
    Activate = function(goal) {
        Quest.Set("goal_state_" + goal, 0);
    }
    IsComplete = function(goal) {
        return (Quest.Get("goal_state_" + goal) == 1);
    }
    Complete = function(goal) {
        Quest.Set("goal_state_" + goal, 1);
    }
    Reset = function(goal) {
        Quest.Set("goal_state_" + goal, 0);
    }
    IsCancelled = function(goal) {
        return (Quest.Get("goal_state_" + goal) == 2);
    }
    Cancel = function(goal) {
        Quest.Set("goal_state_" + goal, 2);
    }
    IsFailed = function(goal) {
        return (Quest.Get("goal_state_" + goal) == 3);
    }
    Fail = function(goal) {
        Quest.Set("goal_state_" + goal, 3);
    }
    IsReverse = function(goal) {
        local reverse_name = ("goal_reverse_" + goal);
        return (Quest.Exists(reverse_name)
            && (Quest.Get(reverse_name) == 1));
    }
    IsVisible = function(goal) {
        return (Quest.Get("goal_visible_" + goal) == 1);
    }
    Hide = function(goal) {
        Quest.Set("goal_visible_" + goal, 0);
    }
    Show = function(goal) {
        Quest.Set("goal_visible_" + goal, 1);
    }

    IsAllDoneExcept = function(exclude_goal) {
        // Return true if all visible goals except the given one are
        // done (completed or cancelled).
        for (local goal = 0; goal < 32; goal += 1) {
            local state_name = ("goal_state_" + goal);
            local visible_name = ("goal_visible_" + goal);
            local reverse_name = ("goal_reverse_" + goal);

            if (! Quest.Exists(state_name)) break;

            if ((goal != exclude_goal)
                && (Quest.Get(visible_name) == 1))
                /* && (IsGoldilocksDifficulty(goal))) */
            {
                local state = Quest.Get(state_name);
                local reverse = (Quest.Exists(reverse_name)
                    && (Quest.Get(reverse_name) == 1));

                if (reverse) {
                    if (state != 0 /* unticked, but it's a reverse goal */) {
                        // This goal is done but shouldn't be!
                        return false;
                    }
                } else {
                    if ((state != 1 /* complete */)
                        && (state != 2 /* cancelled */))
                    {
                        // This goal isn't done!
                        return false;
                    }
                }
            }
        }
        // All active goals seem to be okay
        return true;
    }

    IsGoldilocksDifficulty = function(goal) {
        // Return true if the current difficulty is neither too high for the
        // goal, nor too low, but just right.
        local difficulty = Quest.Get("difficulty");
        if (Quest.Exists("goal_min_diff_" + goal)) {
            local min_diff = Quest.Get("goal_min_diff_" + goal);
            if (difficulty < min_diff) {
                return false;
            }
        }
        if (Quest.Exists("goal_max_diff_" + goal)) {
            local max_diff = Quest.Get("goal_max_diff_" + goal);
            if (difficulty > max_diff) {
                return false;
            }
        }
    }
};


/* -------- Delivering the McGuffin -------- */


class GoalDeliverMcGuffin extends SqRootScript
{
    /* TODO TEMP: this is on a button that the player frobs. Because I
       can't decide yet whether to have the player drop the item
       on the desk or what. */

    /* TODO: do we complete the goal before the talking starts? i dont think
       so, but not sure... */

    function Activate() {
        if (! Goal.IsFailed(eGoals.kDontBeStupid)) {
            Goal.Hide(eGoals.kDontBeStupid);
            Goal.Show(eGoals.kLightTheBeacons);
            Goal.Show(eGoals.kLootNormal);
            Goal.Show(eGoals.kLootHard);
            Goal.Show(eGoals.kLootExpert);
            Goal.Show(eGoals.kDontKillBystanders);
            Goal.Show(eGoals.kDontKillHumans);
            Goal.Complete(eGoals.kDeliverMcGuffin);
        }
    }

    function OnFrobWorldEnd() {
        // TODO: for the temp button.
        Activate();
    }

    function OnObjRoomTransit() {
        // TODO: do we want this?
        local room = message().ToObjId;
        local link = Link.GetOne("Route", self);
        if (link) {
            local targetRoom = LinkDest(link);
            if (room==targetRoom) {
                Activate();
            }
        }
    }
}

class GoalDontBeStupid extends SqRootScript
{
    /* Put this on M-DontBeStupid, which should go on all
       servants, guards, and loot at the start of the mission,
       as well as on doors you shouldn't open, and buttons
       you shouldn't press. */

    function Fail() {
        Goal.Fail(eGoals.kDontBeStupid);
        RemoveFromAll();
    }

    function RemoveFromAll() {
        Object.RemoveMetaPropertyFromMany("M-DontBeStupid", "@M-DontBeStupid");
    }

    function OnFailGoal() {
        // M-DontBeStupid will send a FailGoal message from some responses.
        print("Stupid: don't do things with response pseudo-scripts!");
        Fail();
    }

    function OnContained() {
        // We were picked up by the player.
        if (message().container==Object.Named("Player")) {
            print("Stupid: don't pick this up!");
            Fail();
        }
    }

    function OnFrobWorldBegin() {
        // The player frobbed us.
        if (message().Frobber==Object.Named("Player")) {
            print("Stupid: don't frob this!");
            Fail();
        }
    }

    function OnContainer() {
        // If we were pickpocketed. Unfortunately the link is gone by
        // the time we get this message, so we can't limit this to only
        // the belt- or alt-located items. But there's no other reason
        // an ai would be losing contained items, right? I hope not.
        if (message().event==eContainsEvent.kContainRemove) {
            print("Stupid: don't pick pockets!");
            Fail();
        }
    }


    function OnAIModeChange() {
        // We are dead now, but weren't a moment ago. This covers knockouts.
        if (message().mode==5 && message().previous_mode!=5) {
            print("Stupid: don't knockout or kill anyone!");
            Fail();
        }
    }

    function OnSlain() {
        // We were killed by the player.
        if (message().culprit==Object.Named("Player")) {
            print("Stupid: don't kill anyone!");
            Fail();
        }
    }
}


/* -------- Lighting the Beacons -------- */


// Send this a TurnOn from a RequireAllTrap when all the beacons are litten.
class GoalLightTheBeacons extends SqRootScript
{
    function OnTurnOn() {
        Goal.Complete(eGoals.kLightTheBeacons);
    }

    function OnTurnOff() {
        Goal.Reset(eGoals.kLightTheBeacons);
    }    
}
