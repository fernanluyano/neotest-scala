# neotest-scala

[Neotest](https://github.com/rcarriga/neotest) adapter for Scala. Supports [utest](https://github.com/com-lihaoyi/utest), [munit](https://scalameta.org/munit/docs/getting-started.html) and [ScalaTest](https://www.scalatest.org/) (FunSuite style) test frameworks, with runners for [bloop](https://scalacenter.github.io/bloop/), sbt, and [Scala CLI](https://scala-cli.virtuslab.org/).

The runner is auto-detected from the project structure: projects with a `project.scala` file use Scala CLI, all others default to bloop.

It also supports debugging tests with [nvim-dap](https://github.com/rcarriga/nvim-dap) (requires [nvim-metals](https://github.com/scalameta/nvim-metals)). You can debug individual test cases as well, but note that utest framework doesn't support this because it doesn't implement `sbt.testing.TestSelector`. To run tests with debugger pass `strategy = "dap"` when running neotest:

```lua
require('neotest').run.run({strategy = 'dap'})
```

Requires [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) and the parser for scala.

## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use({
  "nvim-neotest/neotest",
  requires = {
    ...,
    "fernanluyano/neotest-scala",
  }
  config = function()
    require("neotest").setup({
      ...,
      adapters = {
        require("neotest-scala"),
      }
    })
  end
})
```

## Configuration

You can set optional arguments to the setup function:

```lua
require("neotest").setup({
  adapters = {
    require("neotest-scala")({
        -- Command line arguments for runner
        -- Can also be a function to return dynamic values
        args = {"--no-color"},
        -- Runner to use. Auto-detected from project structure by default:
        -- projects with project.scala use scala-cli, others use bloop.
        -- Can be a function to return dynamic value.
        -- For backwards compatibility, it also tries to read the vim-test scala config.
        -- Possible values: bloop|sbt|scala-cli.
        runner = "bloop",
        -- Test framework to use. Defaults to scalatest.
        -- Can be a function to return dynamic value.
        -- Possible values: utest|munit|scalatest.
        framework = "scalatest",
        -- Optional keymap to create or open the test file for the current source file.
        -- Derives the test path from src/main/scala/ -> src/test/scala/, appending Test to
        -- the class name, and scaffolds a new file using the configured framework if it does
        -- not exist. No keymap is registered if this option is omitted.
        create_keymap = "<leader>tc",
    })
  }
})
```

## Development

Run the test suite locally with:

```sh
make test
```
