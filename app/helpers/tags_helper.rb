module TagsHelper

  def tags_list
    tags ||= Tag.list.order("name")
    tags.map { |v|
      { id: v.id, text: v.to_s, label: v.to_s, bgcolor: v.bgcolor }
    }.to_json
  end
end
