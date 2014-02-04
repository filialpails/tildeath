require_relative 'tildeath_error'
require_relative 'token'

module Tildeath
  module Lexer
    # token types
    TOKENS = {
      COMMENT:  /\/\/.*$/,
      IMPORT:   /import/,
      TILDEATH: /~ATH/,
      EXECUTE:  /EXECUTE/,
      THIS:     /THIS/,
      BIFURC8:  /bifurcate/,
      SPLIT:    /split/,
      LBRACE:   /\{/,
      RBRACE:   /\}/,
      LPAREN:   /\(/,
      RPAREN:   /\)/,
      LBRACKET: /\[/,
      RBRACKET: /\]/,
      DOT:      /\./,
      DIE:      /DIE/,
      NULL:     /NULL/,
      COMMA:    /,/,
      SEMI:     /;/,
      BANG:     /!/,
      # one or more whitespace characters
      WS:       /\s+/,
      # a letter or underscore followed by zero or more letters, underscores, and digits
      IDENT:    /[a-z_][a-z_0-9]*/i
    }

    def self.lex(input)
      # tokens found so far
      tokens = []
      # current position in script
      pos = 0
      line_number = 0
      column = 0
      match = nil
      # while pos isn't outside the script...
      while pos < input.length
        if input[pos] != "\n"
          column += 1
        else
          line_number += 1
          column = 0
        end
        # for each token type...
        good = TOKENS.any? do |sym, regex|
          # try to match it at the current position in the script
          match = input.match(regex, pos)
          # skip to next token type unless it matched at the current position
          next unless match && match.begin(0) == pos
          # ignore whitespace and comments
          unless [:WS, :COMMENT].include?(sym)
            # add new token to list of found tokens
            # if it's an identifier, save the actual text found as well
            tokens << Token.new(sym, line_number, column, sym == :IDENT ? match[0] : nil)
          end
          # move current position to just after the end of the found token
          pos += match[0].length
          true
        end
        fail TildeathError.new(line_number, column), "error: unrecognized token #{input[pos]}" unless good
      end
      return tokens
    end
  end
end
