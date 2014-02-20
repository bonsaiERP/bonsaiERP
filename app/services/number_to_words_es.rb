# Creates number to works in spanish
# This class has bee modified from an original class
class NumberToWordsEs
  attr_reader :number

  def initialize(number)
    @number = number.to_i
  rescue
    @number = 0
  end

  def to_words
    num = number

    if num == 0
      words << zero_string
    else
      num = num.to_s.rjust(33,'0')
      groups = num.scan(/.{3}/).reverse

      words << number_to_words(groups[0])

      create_groups(groups)
    end

    return "#{words.reverse.join(' ')}"
  end

  def words
    @words ||= []
  end

  protected

    def and_string
      "y"
    end

    def zero_string
      "cero"
    end

    def units
      %w(~ un dos tres cuatro cinco seis siete ocho nueve)
    end

    def tens
      %w[ ~ diez veinte treinta cuarenta cincuenta sesenta setenta ochenta noventa ]
    end

    def hundreds
      %w(cien ciento doscientos trescientos cuatrocientos quinientos seiscientos setecientos ochocientos novecientos)
    end

    def teens
      %w(diez once doce trece cartoce quince dieciseis diecisiete dieciocho diecinueve)
    end

    def twenties
      %w(veinte veintiun veintidos veintitres veinticuatro veinticinco veintiseis veintisiete veintiocho veintinueves)
    end

    def quantities
      %w(~ ~ mill ~ bill ~ trill ~ cuatrill ~ quintill ~)
    end

    def number_to_words(num)
      hundreds = num[0,1].to_i
      tens = num[1,1].to_i
      units = num[2,1].to_i

      text = Array.new

      if hundreds > 0
        if hundreds == 1 && (tens + units == 0)
          text << self.hundreds[0]
        else
          text << self.hundreds[hundreds]
        end
      end

      if tens > 0
        case tens
          when 1
            text << (units == 0 ? self.tens[tens] : self.teens[units])
          when 2
            text << (units == 0 ? self.tens[tens] : self.twenties[units])
          else
            text << self.tens[tens]
        end
      end

      if units > 0
        if tens == 0
          text << self.units[units]
        elsif tens > 2
          text << "#{self.and_string} #{self.units[units]}"
        end
      end

      text.join(' ')
    end

    def create_groups(groups)
      (1..10).each do |num|
        if groups[num].to_i > 0
          case num
          when 1, 3, 5, 7, 9
            words << "mil"
          else
            words << (groups[num].to_i > 1 ? "#{quantities[num]}ones" : "#{self.quantities[num]}ón")
          end
          words << number_to_words(groups[num])
        end
      end
    end
end
