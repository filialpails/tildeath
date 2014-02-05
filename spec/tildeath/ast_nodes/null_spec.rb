describe Tildeath::ASTNodes::Null do
  describe '#execute' do
    it 'is a noop' do
      null = Tildeath::ASTNodes::Null.new
      context = {}
      expect {null.execute(context)}.not_to change {context}
    end
  end

  describe '#to_s' do
    it 'returns \'NULL\'' do
      expect(Tildeath::ASTNodes::Null.new.to_s).to eq('NULL')
    end
  end
end
