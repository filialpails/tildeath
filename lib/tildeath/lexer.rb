require_relative 'tildeath_error'
require_relative 'token'
require 'strscan'

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
      ss = StringScanner.new(input)
      # tokens found so far
      tokens = []
      # current position in script
      line_number = 0
      column = 0
      # while there are chars left...
      while !ss.eos?
        # update position info
        if input[ss.charpos] != "\n"
          column += 1
        else
          line_number += 1
          column = 0
        end
        # for each token type...
        good = TOKENS.any? do |sym, regex|
          # scan for token type
          str = ss.scan(regex)
          # try next token type unless it matched
          next unless str
          # ignore whitespace and comments
          unless [:WS, :COMMENT].include?(sym)
            # add new token to list of found tokens
            # if it's an identifier, save the actual text found as well
            tokens << Token.new(sym,
                                line_number,
                                column,
                                sym == :IDENT ? str : nil)
          end
          true
        end
        unless good
          fail TildeathError.new(line_number, column), "error: unrecognized token #{input[pos]}"
        end
      end
      return tokens
    end
  end
end
