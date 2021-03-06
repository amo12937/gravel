"use strict"

tokenizer = require "tokenizer"
parser = require "parser"
interpreterProvider = require "visitor/interpreter"
require "runner/reserved"
CodeHistory = require "code_history"
help = require "help"

createFragment = (d, cls, items) ->
  $fragment = d.createDocumentFragment()
  for item in items when item.trim() isnt ""
    $fragment.appendChild createP d, cls, item
  return $fragment

createP = (d, cls, text) ->
  $p = d.createElement "p"
  $p.textContent = text
  $p.classList.add cls
  return $p

Reporter = (d, $result) ->
  error:
    report: (errors) ->
      $result.appendChild createFragment d, "ce-out-error", errors
  code:
    report: (codes) ->
      $result.appendChild createFragment d, "ce-out-code", codes
  result:
    report: (results) ->
      $result.appendChild createFragment d, "ce-out-result", results

interpreter = interpreterProvider.create()

window.addEventListener "load", ->
  $input = document.getElementById "input"
  $result = document.getElementById "result"
  reporter = Reporter document, $result
  i = 0
  compile = (code) ->
    i += 1
    
    reporter.code.report code.split "\n"

    [h, k] = code.split " "
    if h is "help"
      reporter.result.report help k
      return

    console.log "[#{i}] code ="
    console.log code
    errors = []
    console.time "[#{i}] tokenizer"
    lexer = tokenizer.tokenize code, errors
    console.timeEnd "[#{i}] tokenizer"

    if errors.length > 0
      reporter.error.report errors.map (error) ->
        "#{error.tag}[#{error.line} : #{error.column}]: #{error.value}"
      return
    
    errors = []
    console.time "[#{i}] parser"
    pResult = parser.parse lexer, errors
    console.timeEnd "[#{i}] parser"
    if errors.length > 0
      reporter.error.report errors.map (error) ->
        "#{error.name}[#{error.token.line} : #{error.token.column}]: #{error.token.value} (tokenTag = #{error.token.tag})"
      return

    console.time "[#{i}] interpreter"
    try
      reporter.result.report pResult.accept(interpreter).split "\n"
    catch e
      reporter.error.report ["RUNTIME_ERROR: #{e.message}"]
    console.timeEnd "[#{i}] interpreter"

  codeHistory = CodeHistory.create([])
  K =
    ENTER: 13
    UP: 38
    DOWN: 40
  # $input
  $input.addEventListener "keydown", (e) ->
    if e.keyCode is K.UP
      $input.value = codeHistory.prev $input.value
    else if e.keyCode is K.DOWN
      $input.value = codeHistory.next $input.value

  $input.addEventListener "keypress", (e) ->
    return unless e.keyCode is K.ENTER
    return if e.shiftKey
    e.preventDefault()
    s = $input.value.trim()
    return if s is ""
    $input.value = codeHistory.save $input.value
    compile s

  $input.focus()

