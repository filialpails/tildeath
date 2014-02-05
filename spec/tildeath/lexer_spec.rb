describe Tildeath::Lexer do
  describe '.lex' do
    it 'tokenizes the input string' do
      script = 'import universe U;
import author Karkat;

~ATH(U) {

  ~ATH(Karkat) {
  } EXECUTE(NULL);

} EXECUTE(NULL);

THIS.DIE();'
      good_tokens = %i[IMPORT IDENT IDENT SEMI IMPORT IDENT IDENT SEMI TILDEATH LPAREN IDENT RPAREN LBRACE TILDEATH LPAREN IDENT RPAREN LBRACE RBRACE EXECUTE LPAREN NULL RPAREN SEMI RBRACE EXECUTE LPAREN NULL RPAREN SEMI THIS DOT DIE LPAREN RPAREN SEMI]
      found_tokens = Tildeath::Lexer.lex(script).map {|token| token.name}

      expect(found_tokens).to eq(good_tokens)
    end
  end
end
