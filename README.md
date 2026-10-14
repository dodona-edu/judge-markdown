# Markdown judge

A very simple judge that takes the input, and renders it as Markdown.

## What can I do with this?

This judge can be useful if you want text (natural language) answers from students.

## Which Markdown flavour is supported?

The judge doesn't actually render anything, so see the [Dodona documentation](https://docs.dodona.be/nl/references/exercise-description/#markdown).

## Does this "judge" anything?

Yes! Empty submissions are rejected. We might also add a linter in the future.

## Testing

`tests/cases/*.md` are submissions that the judge runs on; `tests/expected/*.json` holds the feedback each should produce (a case named `<case>.nl.md` runs with Dutch as natural language). The suite runs as root inside the `dodona-java` image, like CI: `devel/run-tests-in-image.sh` starts the image and runs `devel/run-tests.sh` in it.

```
devel/run-tests-in-image.sh                    # ghcr.io/dodona-edu/dodona-java:latest
IMAGE=my-image devel/run-tests-in-image.sh     # another image
UPDATE_EXPECTED=1 devel/run-tests-in-image.sh  # rewrite the expected output
```

`devel/check.sh` runs shellcheck on `run` and the devel scripts, as CI does.

docker-images runs the suite on candidate `dodona-java` images before publishing them.
