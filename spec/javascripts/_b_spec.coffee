#= require plugins/_b.coffee
describe "_b", ->
  it "Formats correctly anydecimal", ->
    _b.ntc(12).should.equal("12,00")
    _b.ntc(1200).should.equal("1.200,00")
    _b.ntc(1200, 1).should.equal("1.200,0")
    _b.ntc(.1).should.equal("0,10")
    _b.ntc(1.01).should.equal("1,01")
    _b.ntc(0).should.equal("0,00")

  it "Formats byte sizes", ->
    _b.toByteSize(1024).should.equal("1,00 Kb")
    _b.toByteSize(2200).should.equal("2,15 Kb")

  it "Rounds values", ->
    val = 12.23232
    _b.roundVal(12.23235, 2).should.equal(12.23)
    _b.roundVal(12.5, 0).should.equal(13)
