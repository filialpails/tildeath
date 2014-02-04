#!/usr/bin/env ruby
$VERBOSE = true

require 'optparse'

class TilDeathError < StandardError
  attr_reader :line_number, :column

  def initialize(line_number, column)
    super()
    @line_number = line_number
    @column = column
  end
end

class Token
  attr_reader :name, :value, :line_number, :column

  def initialize(name, line_number, column, value = nil)
    @name = name
    @value = value #only used by IDENT tokens, to store the actual identifier
    @line_number = line_number
    @column = column
  end
end

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
      fail TilDeathError.new(line_number, column), "error: unrecognized token #{input[pos]}" unless good
    end
    return tokens
  end
end

class ImminentlyDeceasedObject
  attr_reader :type, :name

  def initialize(type, name)
    @type = type
    @name = name
    @alive = true
  end

  def die
    @alive = false
  end

  def alive?
    @alive
  end
end

class Value
  def initialize(value)
    @value = value
  end

  def execute(context)
    context[@value].alive?
  end

  def to_s
    @value
  end
end

class Bang
  def initialize(value)
    @value = value
  end

  def execute(context)
    !@value.execute(context)
  end

  def to_s
    "!#{@value}"
  end
end

class Import
  def initialize(type, name)
    @type = type
    @name = name
  end

  def execute(context)
    return unless context[:THIS].alive?
    # Create new object of the specified type and name and store it in context
    context[@name] = ImminentlyDeceasedObject.new(@type, @name)
  end

  def to_s
    "import #{@type} #{@name}"
  end
end

class TilDeath
  def initialize(victim, tildeath_body, execute_body)
    @victim = victim
    @tildeath_body = tildeath_body
    @execute_body = execute_body
  end

  def execute(context)
    fail "error: no such object: #{@victim}" unless context[@victim]
    # loop over first set of statements while victim is alive
    while context[@victim].alive?
      return unless context[:THIS].alive?
      @tildeath_body.execute(context)
    end
    # run second set of statements when victim dies
    return unless context[:THIS].alive?
    @execute_body.execute(context)
  end

  def to_s
    "~ATH(#{@victim}) {
  #{@tildeath_body}
} EXECUTE(#{@execute_body})"
  end
end

class DotDie
  def initialize(victim)
    @victim = victim
  end

  def execute(context)
    return unless context[:THIS].alive?
    context[@victim].die
  end

  def to_s
    "#{@victim}.DIE()"
  end
end

class Null
  def execute(context); end

  def to_s
    'NULL'
  end
end

class Bifurcate
  def initialize(orig, parts)
    @orig = orig
    @parts = parts
  end

  def execute(context)
    type = context[@orig].type
    @parts.each do |part|
      context[part] = ImminentlyDeceasedObject.new(type, part)
    end
  end

  def to_s
    @parts[1..-1].reduce("bifurcate #{@orig}[#{@parts[0]}") {|memo, part|
      memo << ', ' << part.to_s
    } << ']'
  end
end

class Statements
  def initialize(statements=[])
    @statements = statements
  end

  def execute(context)
    return unless context[:THIS].alive?
    @statements.each do |statement|
      return unless context[:THIS].alive?
      statement.execute(context)
    end
  end

  def to_s
    @statements.reduce('') do |memo, stmt|
      memo << stmt.to_s << ";\n"
    end
  end
end

class Program
  def initialize(statements)
    @statements = statements
  end

  def execute
    context = {
      THIS: ImminentlyDeceasedObject.new(:program, :THIS)
    }
    @statements.execute(context)
  end

  def to_s
    @statements.to_s
  end
end

module Parser
  # null: NULL
  def self.parse_null(tokens)
    # shift the NULL off the token queue
    tokens.shift
    # return a new Null object
    Null.new
  end

  # import: IMPORT IDENT IDENT
  def self.parse_import(tokens)
    # Shift the IMPORT IDENT IDENT tokens off the queue, saving the type and
    #   name as symbols
    type, name = tokens.shift(3)[1..2].map{|token| token.value.to_sym}
    # return a new Import with the given type and name
    Import.new(type, name)
  end

  # value: THIS | IDENT
  def self.parse_value(tokens)
    Value.new(tokens.shift.value.to_sym)
  end

  # bang: BANG value
  def self.parse_bang(tokens)
    # shift off BANG
    tokens.shift
    value = parse_value(tokens)
    Bang.new(operand)
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
    # return a new TilDeath with the parsed victim and statements
    TilDeath.new(victim, tildeath_body, execute_body)
  end

  # array: LBRACKET expression (COMMA expression)* RBRACKET
  def self.parse_array(tokens)
    elements = []
    elements << tokens.shift(2)[1].value.to_sym
    Array.new(elements)
  end

  # dot_die: expression DOT DIE LPAREN RPAREN
  def self.parse_dot_die(tokens)
    # shift off all the tokens, keeping the IDENT's value
    victim = tokens.shift(5)[0]
    victim = victim.name == :THIS ? victim.name.to_sym : victim.value.to_sym
    DotDie.new(victim)
  end

  # bifurcate: BIFURC8 IDENT LBRACKET IDENT COMMA IDENT RBRACKET
  def self.parse_bifurcate(tokens)
    orig = tokens.shift(3)[1].value.to_sym
    parts = tokens.shift(4).values_at(0, 2).map do |token|
      token.value.to_sym
    end
    Bifurcate.new(orig, parts)
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
    Split.new(orig, parts)
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
          else fail TilDeathError.new(token.line_number, token.column), "error: unexpected token #{token}"
          end
    # shift off SEMI
    fail TilDeathError.new(tokens[0].line_number, tokens[0].column), 'missing semicolon' unless tokens[0].name == :SEMI
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
    Statements.new(statements)
  end

  # program: statements
  def self.parse(tokens)
    Program.new(parse_statements(tokens))
  end
end

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
  rescue TilDeathError => ex
    puts "#{filename}:#{ex.line_number}:#{ex.column}: #{ex.message}"
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [options] file"
  opts.on('-v', '--[no-]verbose', 'Verbose mode') do |v|
    options[:verbose] = v
  end
  opts.on_tail('--version', 'Show version') do
    puts '0.0.0'
    exit
  end
end.parse!

input = nil
filename = nil
if ARGV.length == 0
  puts "No file given on command line, reading from stdin... (EOF to finish)"
  input = STDIN.read
  filename = '-'
else
  filename = ARGV.first
  input = File.open(filename, 'r').read
end

Interpreter.interpret(input, filename: filename, verbose: options[:verbose])
