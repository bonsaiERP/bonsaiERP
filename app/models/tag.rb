# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Tag < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true,
            format: {with: /\A[^\s,]*\z/}

  validates :bgcolor, presence:true,
            format: {with: /\A\#[0-9abcdefABCDEF]{6}\z/}
end
