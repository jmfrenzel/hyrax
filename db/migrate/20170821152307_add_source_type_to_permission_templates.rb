class AddSourceTypeToPermissionTemplates < ActiveRecord::Migration[4.2]
  def change
    add_column :permission_templates, :source_type, :string

    remove_column :permission_templates, :admin_set_id
    add_column :permission_templates, :source_id, :string

    Hyrax::PermissionTemplate.find_each do |permission_template|
      permission_template.source_type = 'admin_set'
      permission_template.save!
    end
  end
end
