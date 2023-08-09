# FlameGraph Spell

This spell will process the an `event.log` from the data weave engine. And launch a web with the flamegraph of the execution where hotspots can be detected.

To produce an event.log the user needs to run with the `--telemetry` flag enabled.

# HOW TO RUN IT

`dw spell --eval  -i payload=<pathToEvent.log> machaval/FlameGraph`