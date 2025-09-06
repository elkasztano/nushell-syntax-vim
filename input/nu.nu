#!/usr/bin/env nu
# comment
def hello [name] {
  $"Hello, ($name)!"
}

def testfunction [
  name: string
  --value: int
] {
  name: $name
  value: $value
}

let colors = [ red green ]
let colors = ($colors | prepend yellow)
let teststring = "Hello, world!"
let singlequotes = 'Hello, world!'
let nested_raw_string = r##'r#'Hello, world!'#'##
let value = 3.1415

def "my testcommand" [] {
  "my command"
}

let mb = 1024kb
let duration = 1day

"FOO" | str contains --ignore-case "foo"
("FOO" | str downcase) == ("Foo" | str downcase)

def foo_nuon [ --flag required optional? ...arguments ] {
  { flag: $flag, required: $required, optional: $optional, arguments: $arguments } | to nuon
}
