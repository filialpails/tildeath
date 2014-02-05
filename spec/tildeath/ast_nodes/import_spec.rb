describe Tildeath::ASTNodes::Import do
  describe '#execute' do
    it 'creates a new object and variable' do
      import = Tildeath::ASTNodes::Import.new(:moirail, :Max)
      context = {
        THIS: Tildeath::ImminentlyDeceasedObject.new(:program, :THIS)
      }
      import.execute(context)
      obj = context[import.name]
      expect(obj).to be_instance_of(Tildeath::ImminentlyDeceasedObject)
      expect(obj.name).to eq(:Max)
      expect(obj.type).to eq(:moirail)
      expect(obj).to be_alive
    end
  end

  describe '#to_s' do
    it 'returns \'import [type] [name]\'' do
      import = Tildeath::ASTNodes::Import.new(:moirail, :Max)
      expect(import.to_s).to eq('import moirail Max')
    end
  end
end
