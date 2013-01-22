class IncomeQuery
  def initialize
    @rel = Income
  end

  def search(params={})
    @rel = @rel.where{} if params[:search].present?
    @rel
  end
end
