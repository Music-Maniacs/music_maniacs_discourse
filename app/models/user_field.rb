# frozen_string_literal: true

class UserField < ActiveRecord::Base
  include AnonCacheInvalidator
  include HasDeprecatedColumns
  include HasSanitizableFields

  deprecate_column :required, drop_from: "3.3"

  validates_presence_of :description, :field_type
  validates_presence_of :name, unless: -> { field_type == "confirm" }
  has_many :user_field_options, dependent: :destroy
  has_one :directory_column, dependent: :destroy
  accepts_nested_attributes_for :user_field_options

  before_save :sanitize_description
  after_save :queue_index_search

  scope :public_fields, -> { where(show_on_profile: true).or(where(show_on_user_card: true)) }

  enum :requirement, { optional: 0, for_all_users: 1, on_signup: 2 }.freeze

  def self.max_length
    2048
  end

  def required?
    !optional?
  end

  def queue_index_search
    Jobs.enqueue(:index_user_fields_for_search, user_field_id: self.id)
  end

  private

  def sanitize_description
    if description_changed?
      self.description = sanitize_field(self.description, additional_attributes: ["target"])
    end
  end
end

# == Schema Information
#
# Table name: user_fields
#
#  id                :integer          not null, primary key
#  name              :string           not null
#  field_type        :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  editable          :boolean          default(FALSE), not null
#  description       :string           not null
#  required          :boolean          default(TRUE), not null
#  show_on_profile   :boolean          default(FALSE), not null
#  position          :integer          default(0)
#  show_on_user_card :boolean          default(FALSE), not null
#  external_name     :string
#  external_type     :string
#  searchable        :boolean          default(FALSE), not null
#  requirement       :integer          default("optional"), not null
#
