require_relative 'tildeath_error'
require_relative 'lexer'
require_relative 'parser'

module Tildeath
  module Interpreter
    def self.interpret(script, filename:, verbose: false)
      # discard shebang line if present
      script.slice!(0, script.index("\n") + 1) if script[0..1] == "#!"
      # scan string into tokens
      tokens = Lexer.lex(script)
      # parse tokens into abstract syntax tree
      tree = Parser.parse(tokens)
      # show gussed original source based on AST
      puts tree if verbose
      # execute AST starting at its root
      tree.execute
    rescue TildeathError => ex
      puts "#{filename}:#{ex.line_number}:#{ex.column}: #{ex.message}"
    end
  end
end
