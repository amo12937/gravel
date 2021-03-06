"use strict"

chai = require "chai"
expect = chai.expect
sinon = require "sinon"
sinonChai = require "sinon-chai"
chai.use sinonChai

TOKEN = require "TOKEN"
tokenizer = require "tokenizer"
t = (tag, value, line, column) -> {tag, value, line, column}
eof = (line, column) -> t TOKEN.EOF, "", line, column
c = (a, e) ->
  expect(Object.keys(a).length).to.be.equal 4
  expect(a.tag   ).to.be.equal e.tag
  expect(a.value ).to.be.equal e.value
  expect(a.line  ).to.be.equal e.line
  expect(a.column).to.be.equal e.column

examples = [
  [ 0, "", [eof 0, 0]]
  [ 1, "# comment", [eof 0, 9]]
  [ 2, "# comment\n", [t(TOKEN.LINE_BREAK, "\n", 0, 9), eof(1, 0)]]
  [ 3, "#- comment -#", [eof(0, 13)]]
  [ 4, "#- - -#", [eof 0, 7]]
  [ 5, "#- # -#", [eof 0, 7]]
  [ 6, "#-#-#", [eof 0, 5]]
  [ 7, "#- \n\n\n -#", [eof(3, 3)]]
  [ 8, "     ", [eof 0, 5]]
  [ 9, "  \n  ", [t(TOKEN.LINE_BREAK, "\n", 0, 2), eof(1, 2)]]
  [10, "  \n  \n  \n  ", [t(TOKEN.LINE_BREAK, "\n", 0, 2), eof(3, 2)]]
  [11, "\\", [t(TOKEN.LAMBDA, "\\", 0, 0), eof(0, 1)]]
  [12, ".", [t(TOKEN.LAMBDA_BODY, ".", 0, 0), eof(0, 1)]]
  [13, "(", [t(TOKEN.BRACKETS_OPEN, "(", 0, 0), eof(0, 1)]]
  [15, "()", [
    t(TOKEN.BRACKETS_OPEN, "(", 0, 0)
    t(TOKEN.BRACKETS_CLOSE, ")", 0, 1)
    eof(0, 2)
  ]]
  [16, "(\n)", [
    t(TOKEN.BRACKETS_OPEN, "(", 0, 0)
    t(TOKEN.BRACKETS_CLOSE, ")", 1, 0)
    eof(1, 1)
  ]]
  [17, ":=", [t(TOKEN.DEF_OP, ":=", 0, 0), eof(0, 2)]]
  [18, "hoge", [t(TOKEN.IDENTIFIER, "hoge", 0, 0), eof(0, 4)]]
  [19, "h_ge", [t(TOKEN.IDENTIFIER, "h_ge", 0, 0), eof(0, 4)]]
  [20, "1234", [t(TOKEN.NUMBER.NATURAL, "1234", 0, 0), eof(0, 4)]]
  [22, "h0ge", [t(TOKEN.IDENTIFIER, "h0ge", 0, 0), eof(0, 4)]]
  [23, "____", [t(TOKEN.IDENTIFIER, "____", 0, 0), eof(0, 4)]]
  [24, "hoge fuga", [
    t(TOKEN.IDENTIFIER, "hoge", 0, 0)
    t(TOKEN.IDENTIFIER, "fuga", 0, 5)
    eof(0, 9)
  ]]
  [25, "hoge\nfuga", [
    t(TOKEN.IDENTIFIER, "hoge", 0, 0)
    t(TOKEN.LINE_BREAK, "\n", 0, 4)
    t(TOKEN.IDENTIFIER, "fuga", 1, 0)
    eof(1, 4)
  ]]
  [26, "a := b", [
    t(TOKEN.IDENTIFIER, "a", 0, 0)
    t(TOKEN.DEF_OP, ":=", 0, 2)
    t(TOKEN.IDENTIFIER, "b", 0, 5)
    eof(0, 6)
  ]]
]

ex =
  symbol:
    ok: "!$%&*+/<=>?@^|-~"
    ng: "(.\\#"
    error:
      ut: "[]{},'\";:"
      ub: ")"

describe "tokenizer", ->
  it "should have tokenize function", ->
    expect(typeof tokenizer.tokenize).to.be.equal "function"

  examples.forEach ([key, code, tokens]) ->
    it "should compile church encoding[#{key}]", ->
      lexer = tokenizer.tokenize code, []
      for expected in tokens
        c lexer.next(), expected

  for s in ex.symbol.ok
    it "should compile church encoding[#{s}]", do (ss = s) -> ->
      lexer = tokenizer.tokenize ss, []
      c lexer.next(), t(TOKEN.IDENTIFIER, ss, 0, 0)
      c lexer.next(), eof(0, 1)

  for s in ex.symbol.ng
    it "should not compile church encoding[#{s}]", do (ss = s) -> ->
      lexer = tokenizer.tokenize ss, []
      expect(lexer.next().tag).not.to.be.equal TOKEN.IDENTIFIER
      c lexer.next(), eof(0, 1)
       
  for s in ex.symbol.error.ut
    it "should not compile church encoding[#{s}]", do (ss = s) -> ->
      errors = []
      lexer = tokenizer.tokenize ss, errors
      expect(errors.length).to.be.equal 1
      expect(errors[0].tag).to.be.equal TOKEN.ERROR.UNKNOWN_TOKEN
      c lexer.next(), eof(0, 1)

  for s in ex.symbol.error.ub
    it "should not compile church encoding[#{s}]", do (ss = s) -> ->
      errors = []
      lexer = tokenizer.tokenize ss, errors
      expect(errors.length).to.be.equal 1
      expect(errors[0].tag).to.be.equal TOKEN.ERROR.UNMATCHED_BRACKET
      c lexer.next(), eof(0, 1)

