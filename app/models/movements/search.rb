# class to help search
class Movements::Search
  attr_reader :args, :model

  def initialize(args = {}, model)
    @args  = args
    @model = model
  end

  def search
    s = model.includes(:contact, :tax, :updater, :creator, :approver, :nuller)
    #.joins(:contact)
    if args[:search].present?
      s = s.where("accounts.name ILIKE :s OR accounts.description ILIKE :s OR contacts.matchcode ILIKE :s", s: "%#{ args[:search] }%")
    end
    s = get_state(s)
    s = set_dates(s)

    s
  end

  private

    def get_state(s)
      case args[:state]
      when 'draft', 'approved', 'nulled', 'paid'
        s.where(state: args[:state])
      when 'due'
        s.where("accounts.state = ? AND accounts.due_date <= ?", 'approved', Date.today)
      when 'error'
        s.where(has_error: true)
      else
        s
      end
    end

    def set_dates(s)
      s = s.where("accounts.date >= ?", args[:date_start])  if args[:date_start].present?
      s = s.where("accounts.date <= ?", args[:date_end])  if args[:date_end].present?

      s
    end

end
