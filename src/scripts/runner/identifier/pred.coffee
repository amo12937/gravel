"use strict"

IdentifierRunner = require "runner/identifier"
NumberRunner = require "runner/number"

module.exports = class PredIdentifierRunner extends IdentifierRunner
  run: (nThunk) ->
    n = nThunk.get()
    if n instanceof NumberRunner
      return NumberRunner.create @interpreter, Math.max 0, n.value - 1
    return @interpreter.env[@name]?.get().run nThunk
IdentifierRunner.register "pred", PredIdentifierRunner

