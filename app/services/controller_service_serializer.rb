class ControllerServiceSerializer < Struct.new(:model)

  def to_json(methods: [], only: [], except: [])
    opts = {}
    opts[:methods] = (Array(methods) + [:errors, :to_s]).uniq
    opts[:only] = only  if Array(only).any?
    opts[:except] = except  if Array(except).any?

    opts[:methods].push(:destroyed?)  if model.destroyed?

    model.to_json(opts)
  end
end
