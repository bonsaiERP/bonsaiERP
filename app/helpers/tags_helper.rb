module TagsHelper
  # Presents a list for json
  def tags_list
    @tags_list ||= Tag.list.order("name").map { |val|
      { id: val.id, name: val.name, label: val.to_s, bgcolor: val.bgcolor }
    }
  end

  def tags_list_hash
    @tags_list_hash ||= Hash[tags_list.map { |el|
      [el[:id], el]
    }]
  end

end
