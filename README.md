[![progress-banner](https://backend.codecrafters.io/progress/grep/a5caf1d0-c7fc-4f6e-b8f7-cce4e3dc6230)](https://app.codecrafters.io/users/codecrafters-bot?r=2qF)

This is a starting point for Gleam solutions to the
["Build Your Own grep" Challenge](https://app.codecrafters.io/courses/grep/overview).

[Regular expressions](https://en.wikipedia.org/wiki/Regular_expression)
(Regexes, for short) are patterns used to match character combinations in
strings. [`grep`](https://en.wikipedia.org/wiki/Grep) is a CLI tool for
searching using Regexes.

In this challenge you'll build your own implementation of `grep`. Along the way
we'll learn about Regex syntax, how parsers/lexers work, and how regular
expressions are evaluated.

**Note**: If you're viewing this repo on GitHub, head over to
[codecrafters.io](https://codecrafters.io) to try the challenge.

# Passing the first stage

The entry point for your `grep` implementation is in `src/grep.gleam`. Study and
uncomment the relevant code, and push your changes to pass the first stage:

```sh
git add .
git commit -m "pass 1st stage" # any msg
git push origin master
```

Time to move on to the next stage!

# Stage 2 & beyond

Note: This section is for stages 2 and beyond.

1. Ensure you have `gleam (1.0)` installed locally
1. Run `./your_grep.sh` to run your program, which is implemented in
   `src/grep.gleam`.
1. Commit your changes and run `git push origin master` to submit your solution
   to CodeCrafters. Test output will be streamed to your terminal.
