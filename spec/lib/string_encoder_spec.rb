# encoding: utf-8
require 'spec_helper'

describe StringEncoder do
  let(:string)  {
    "\r\nMaschine:    Keg-Anlage ; bestehend aus Au\xC3\x9Fenwascher und Reiniger / F\xC3\xBCller  \r\nHersteller:    M&F Keg-Technik\r\nTyp:             Au\xC3\x9Fenwascher AW1200B\xC3\xBC; Reiniger & F\xC3\xBCller Minomat 5/4\r\nBaujahr:       1995  \r\nLeistung:      50 - 60 Keg`/h\r\nSortiment:    20l-, 30l- & 50l-Keg`s; Flachfitting\r\nfrei ab:         April 2012\r\nStandort:     Deutschland   \r\nZustand:      gut; Edelstahtausf\xC3\xBChrung\r\n \r\nDer Minomat ist eine vollautomatische Keg-Behandlungsmaschine zur Innenreinigung, D\xC3\xA4mpfung und Bef\xC3\xBCllung von Keg-F\xC3\xA4ssern mit Getr\xC3\xA4nken. Der Maschine vorgelagert ist der Au\xC3\x9Fenwascher  AW 1200 B\xC3\xBC. Ausgelegt ist sie f\xC3\xBCr das Bef\xC3\xBCllen von 20 l, 30 l und 50 l Keg\xE2\x80\x99s mit Flachfitting. Sie hat eine Nennleistung von 50 \xE2\x80\x93 60 keg/h.  \r\nDie Anlage besitzt :\r\n3 Innenreinigungsstationen\r\n1 Sterilisierstation\r\n1 F\xC3\xBCllstation.\r\n \r\nDie einzelnen Behandlungszeiten und die mehrmalige Wiederholung von Sp\xC3\xBClungen sowie Taktungen w\xC3\xA4hrend der Sp\xC3\xBClungen sind auf jeder Station individuell regelbar.\r\nIm Au\xC3\x9Fenwascher werden die  Keg\xE2\x80\x99s \xC3\xBCber D\xC3\xBCsensysteme und mit einer Schleuderb\xC3\xBCrste gereinigt. Gleichzeitig erfolgt eine Keg-Innen-Vorreinigung mit Mischwasser und Lauge.\r\nAuf Station 1 der Keg-Behandlungsmaschine erfolgt eine Laugesp\xC3\xBClung oben und unten.\r\nAuf Station 2 wird das keg mit Mischwasser oben und unten gesp\xC3\xBClt sowie im Anschluss mit S\xC3\xA4ure oben und unten gereinigt.\r\nAuf Station 3 erfolgt eine Hei\xC3\x9Fwassersp\xC3\xBClung oben und unten und eine Dampfsp\xC3\xBClung mit Dampfdruckaufbau.\r\nStation 4 dient dem Sterilisieren.\r\nAuf Station 5 erfolgt die CO2-Sp\xC3\xBClung, das Vorspannen sowie das F\xC3\xBCllen der Keg\xE2\x80\x99s. Der F\xC3\xBCllkopf wird zum Schluss mit Hei\xC3\x9Fwasser gesp\xC3\xBClt.\r\nDie Keg-Anlage ist komplett in Edelstahl ausgef\xC3\xBChrt. Zur Steuerung dient eine speicherprogrammierbare Steuerung Siemens Simatic S5.\r\nAn der Anlage sind 3 Tanks \xC3\xA0 130 l angebracht (S\xC3\xA4ure, Lauge beheizbar; Mischwassertank).\r\n  "
  }

  let(:small_string) {
    "\r\nMaschine:    Keg-Anlage ; bestehend aus Außenwascher und Reiniger / Füller  \r\nHersteller:    M&F K: 800.00 €"
  }

  it 'should encode from UTF-8 to ISO-8859-1' do
    small_string.encoding.to_s.should == "UTF-8"

    resp = StringEncoder.encode("UTF-8", "ISO-8859-1", small_string)

    resp.encoding.to_s.should == "ISO-8859-1"
    resp.should === "\r\nMaschine:    Keg-Anlage ; bestehend aus Außenwascher und Reiniger / Füller  \r\nHersteller:    M&F K: 800.00 &#8364;".encode("ISO-8859-1")
  end

  it 'should work with long strings that cannot be converted directly' do
    string.encoding.to_s.should == "UTF-8"

    resp = StringEncoder.encode("UTF-8", "ISO-8859-1", string)

    string.size.should == resp.size
  end
end
