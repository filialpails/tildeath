require_relative 'tildeath_error'
require_relative 'ast_nodes'

module Tildeath
  module Parser
    # null: NULL
    def self.parse_null(tokens)
      # shift the NULL off the token queue
      tokens.shift
      # return a new Null object
      ASTNodes::Null.new
    end

    # import: IMPORT IDENT IDENT
    def self.parse_import(tokens)
      # Shift the IMPORT IDENT IDENT tokens off the queue, saving the type and
      #   name as symbols
      type, name = tokens.shift(3)[1..2].map{|token| token.value.to_sym}
      # return a new Import with the given type and name
      ASTNodes::Import.new(type, name)
    end

    # value: THIS | IDENT
    def self.parse_value(tokens)
      ASTNodes::Value.new(tokens.shift.value.to_sym)
    end

    # bang: BANG value
    def self.parse_bang(tokens)
      # shift off BANG
      tokens.shift
      value = parse_value(tokens)
      ASTNodes::Bang.new(operand)
    end

    # expression: bang | value
    def self.parse_expression(tokens)
      return parse_bang(tokens) if tokens[0].name == :BANG
      parse_value(tokens)
    end

    # tildeath: TILDEATH LPAREN expression RPAREN LBRACE statements RBRACE EXECUTE LPAREN statements RPAREN
    def self.parse_tildeath(tokens)
      # shift off the first five tokens, saving the IDENT
      victim = tokens.shift(5)[2]
      victim = victim == :THIS ? victim.name : victim.value.to_sym
      # parse the first statements
      tildeath_body = parse_statements(tokens)
      # shift off some punctuation
      tokens.shift(3)
      # parse the EXECUTE statements (or NULL)
      execute_body = tokens[0].name == :NULL ? parse_null(tokens) : parse_statements(tokens)
      # shift off the last RPAREN
      tokens.shift
      # return a new Tildeath with the parsed victim and statements
      ASTNodes::Tildeath.new(victim, tildeath_body, execute_body)
    end

    # array: LBRACKET expression (COMMA expression)* RBRACKET
    def self.parse_array(tokens)
      elements = []
      elements << tokens.shift(2)[1].value.to_sym
      ASTNodes::Array.new(elements)
    end

    # dot_die: expression DOT DIE LPAREN RPAREN
    def self.parse_dot_die(tokens)
      # shift off all the tokens, keeping the IDENT's value
      victim = tokens.shift(5)[0]
      victim = victim.name == :THIS ? victim.name.to_sym : victim.value.to_sym
      ASTNodes::DotDie.new(victim)
    end

    # bifurcate: BIFURC8 IDENT LBRACKET IDENT COMMA IDENT RBRACKET
    def self.parse_bifurcate(tokens)
      orig = tokens.shift(3)[1].value.to_sym
      parts = tokens.shift(4).values_at(0, 2).map do |token|
        token.value.to_sym
      end
      ASTNodes::Bifurcate.new(orig, parts)
    end

    # split: SPLIT IDENT LBRACKET IDENT (COMMA IDENT)* RBRACKET
    def self.parse_split(tokens)
      orig = tokens.shift(3)[1].value.to_sym
      parts = [tokens.shift.value.to_sym]
      while true
        part = tokens.shift
        case part.name
        when :COMMA
          parts << tokens.shift.value.to_sym
        when :RBRACKET
          break
        end
      end
      ASTNodes::Split.new(orig, parts)
    end

    # statement: (import | tildeath | dot_die | bifurcate | split) SEMI
    # TODO: make [THIS, THIS].DIE() legal
    def self.parse_statement(tokens)
      # Determine statement type based on first token, and parse it
      token = tokens[0].name
      ret = case token
            when :IMPORT then parse_import(tokens)
            when :TILDEATH then parse_tildeath(tokens)
            when :THIS, :IDENT then parse_dot_die(tokens)
            when :BIFURC8 then parse_bifucate(tokens)
            when :SPLIT then parse_split(tokens)
            when :RBRACE then return
            else fail TildeathError.new(token.line_number, token.column), "error: unexpected token #{token}"
            end
      # shift off SEMI
      fail TildeathError.new(tokens[0].line_number, tokens[0].column), 'missing semicolon' unless tokens[0].name == :SEMI
      tokens.shift
      ret
    end

    # statements: statement*
    def self.parse_statements(tokens)
      statements = []
      # while there are tokens left and parse_statement returns non-nil...
      while tokens.length > 0 && statement = parse_statement(tokens)
        # add parsed statement to list of parsed statements
        statements << statement
      end
      # return a new Statements object with the list of parsed statements
      ASTNodes::Statements.new(statements)
    end

    # program: statements
    def self.parse(tokens)
      ASTNodes::Program.new(parse_statements(tokens))
    end
  end
end
