# encoding: utf-8
class StringEncoder
  attr_accessor :str
  attr_reader :from, :to, :new_str

  def initialize(from, to)
    @from, @to = from, to
    @new_str = "".encode(to)
  end

  def encode(string)
    string = string.gsub("’", "'").gsub("‘", "'").gsub("–", "-").gsub("€", "&#8364;")
    encode_chunck(string)

    new_str
  end

  def encode_chunck(string, chunk_size = 100)
    limit = ( string.size/chunk_size.to_f ).floor

    (0..limit).each do |v|
      pos_ini = v * chunk_size
      pos_end = (v + 1) * chunk_size

      if chunk_size === 1
        string.force_encoding(to)
      else
        begin
          if chunk_size > 1
            encoded = string[pos_ini...pos_end].encode(to)
            @new_str << encoded
          else
            @new_str << string[pos_ini...pos_end].force_encoding(to)
          end
        rescue
          if chunk_size === 4
            encode_chunck(string, 1)
          else
            encode_chunck(string[pos_ini...pos_end], chunk_size/5)
          end
        end
      end
    end
  end

  def self.encode(from, to, string)
    enc = ::StringEncoder.new(from, to)
    enc.encode(string)
  end
end
