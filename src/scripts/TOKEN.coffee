"use strict"

prefixedKV = require "prefixed_kv"

module.exports = prefixedKV "TOKEN", {
  "LAMBDA"
  "LAMBDA_BODY"
  "BRACKETS_OPEN"
  "BRACKETS_CLOSE"
  "DEF_OP"
  "IDENTIFIER"
  NUMBER: {
    "NATURAL"
  }
  "STRING"
  "LINE_BREAK"
  "INDENT"
  "EOF"
  ERROR: {
    "UNKNOWN_TOKEN"
    "UNMATCHED_BRACKET"
  }
}
