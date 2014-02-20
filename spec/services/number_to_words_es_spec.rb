require 'spec_helper'

describe NumberToWordsEs do
  it "#initialize NaN" do
    d = BigDecimal.new('NaN')
    ntw = NumberToWordsEs.new(d)
    expect(ntw.number).to eq(0)
  end

  it "#to_words" do
    ntw = NumberToWordsEs.new(1123)
    expect(ntw.to_words).to eq('un mil ciento veintitres')
  end

  it "#to_words millones" do
    ntw = NumberToWordsEs.new(3_975_247)
    expect(ntw.to_words).to eq('tres millones novecientos setenta y cinco mil doscientos cuarenta y siete')
  end

  it "#to_words millón" do
    ntw = NumberToWordsEs.new(1_975_247)
    expect(ntw.to_words).to eq('un millón novecientos setenta y cinco mil doscientos cuarenta y siete')
  end
end
