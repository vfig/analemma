class TrolBetter extends SqRootScript
{
    // Use a Script Message step to randomise the continuation of a pseudoscript.
    //     Arg 1: DieRoll
    //     Arg 2: <number of sides of the die> (default 2)
    //     Arg 3: <minimum roll to continue>   (default: must roll max)
    function OnDieRoll() {
        local sides = (message().data==null? 2 : message().data.tointeger());
        local min = (message().data2==null? sides : message().data2.tointeger());
        local roll = Data.RandInt(1, sides);
        Reply(roll>=min);
    }

    // Use a Script Message step to randomise the continuation of a pseudoscript.
    //     Arg 1: Randomize
    //     Arg 2: <% of success> (default 50)
    function OnRandomize() {
        local percent = (message().data==null? 50 : message().data.tointeger());
        local roll = Data.RandInt(1, 100);
        Reply(roll<=percent);
    }
}
